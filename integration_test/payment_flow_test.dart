import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/widgets/sale_complete_sheet.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:advance_pos_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/change_due_banner.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/payment_entry_card.dart';

import '../test/features/bill_preview/helpers/bill_preview_fixtures.dart';
import '../test/features/bill_preview/helpers/fake_bill_preview_repository.dart';
import '../test/features/cart/helpers/cart_fixtures.dart';
import '../test/features/cart/helpers/cart_test_host.dart'
    show fieldUnder, reveal;
import '../test/features/cart/helpers/fake_cart_repository.dart';
import '../test/features/edit_sale_payment/helpers/edit_sale_payment_test_host.dart'
    show
    accountDropdown,
    amountField,
    dashboardStub,
    entryCard,
    newSaleStub,
    systemChip;
import '../test/features/edit_sale_payment/helpers/payment_fixtures.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart'
    show pumpFor, seedApiParams;
import '../test/features/payment/helpers/fake_payment_repository.dart';
import '../test/features/payment/helpers/payment_test_host.dart';

const _newBill = 'SL0002';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeCartRepository cartRepo;
  late FakePaymentRepository paymentRepo;
  late FakeBillPreviewRepository billRepo;

  setUpAll(seedApiParams);

  setUp(() {
    cartRepo = FakeCartRepository();
    paymentRepo = FakePaymentRepository(newBillNo: _newBill);
    billRepo = FakeBillPreviewRepository(bill: billJson(billNo: _newBill));
  });

  /// Opens the Cart; [editCart] runs there; then Proceed to Payment.
  Future<void> openPayment(
      WidgetTester tester, {
        bool methodsFailFirst = false,
        Future<void> Function()? editCart,
      }) async {
    await pumpPaymentFlowApp(
      tester,
      cartRepository: cartRepo,
      paymentRepository: paymentRepo,
      billRepository: billRepo,
      accounts: sampleAccounts(),
      methodsFailFirst: methodsFailFirst,
    );
    if (editCart != null) await editCart();
    await goToPaymentFromCart(tester);
  }

  Future<void> pickAccount(WidgetTester tester, String system, String label) async {
    await tester.ensureVisible(accountDropdown(system));
    await tester.tap(accountDropdown(system));
    await pumpFor(tester);
    await tester.tap(find.text(label).last);
    await pumpFor(tester);
  }

  /// Cash + bKash selected, bKash Personal (id 22) chosen.
  Future<void> selectCashAndBkash(WidgetTester tester) async {
    await tester.tap(systemChip('Cash'));
    await pumpFor(tester);
    await tester.tap(systemChip('bKash'));
    await pumpFor(tester);
    await pickAccount(
        tester, 'bKash', accountLabel('bKash Personal', '01700000002'));
  }

  Future<void> typeAmount(WidgetTester tester, String system, String value) async {
    await tester.enterText(amountField(system), value);
    await pumpFor(tester);
  }

  Future<void> complete(WidgetTester tester) async {
    await tester.tap(completeButton);
    await pumpFor(tester);
  }

  // ─────────────────────────────── Opening
  group('opening', () {
    testWidgets('payable from the cart; nothing selected yet',
            (tester) async {
          await openPayment(tester);

          final s = paymentScreenState(tester);
          expect(s.payableAmount, 990);
          expect(s.subtotal, 990);
          expect(s.receiptItems.map((i) => i.name), ['Rice 5kg', 'Soap']);
          final now = DateTime.now();
          String two(int n) => n.toString().padLeft(2, '0');
          expect(s.saleDate, '${two(now.day)}/${two(now.month)}/${now.year}');

          expect(find.text(AppStrings.selectPaymentMethodToContinue),
              findsOneWidget);
          expect(completeEnabled(tester), isFalse);
        });

    testWidgets('cart discount and VAT carry into payable', (tester) async {
      cartRepo.discount = (_) => billFixed(50);
      await openPayment(tester, editCart: () async {
        final vat = fieldUnder(AppStrings.vatInputLabel);
        await reveal(tester, vat);
        await tester.enterText(vat, '5');
        await pumpFor(tester);
      });

      final s = paymentScreenState(tester);
      expect(s.discountAmount, 50);
      expect(s.vatAmount, 47); // (990 - 50) × 5 %
      expect(s.payableAmount, 987);
    });

    testWidgets('methods failed to load: Retry shows them', (tester) async {
      await openPayment(tester, methodsFailFirst: true);

      expect(find.text(AppStrings.paymentMethodsLoadError), findsOneWidget);
      await tester.tap(find.text(AppStrings.retry));
      await pumpFor(tester);

      expect(systemChip('Cash'), findsOneWidget);
      expect(systemChip('bKash'), findsOneWidget);
    });

    testWidgets('Back returns to the cart unchanged', (tester) async {
      await openPayment(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await pumpFor(tester);

      expect(find.byType(PaymentScreen), findsNothing);
      expect(find.byType(CartItemCard), findsNWidgets(2));
    });
  });

  // ─────────────────────────────── Methods and amounts
  group('methods', () {
    testWidgets('Cash: full payable, account bound, Complete enabled',
            (tester) async {
          await openPayment(tester);

          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);

          final entry = paymentScreenState(tester).selectedEntries.single;
          expect(entry.amount, 990);
          expect(entry.account?.id, 11);
          expect(completeEnabled(tester), isTrue);
        });

    testWidgets('cash over payable: change shown, net sent',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);

          await typeAmount(tester, 'Cash', '1000');

          expect(find.text(AppStrings.returnToCustomerLabel), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(ChangeDueBanner),
              matching: find.text('10.00'),
            ),
            findsOneWidget,
          );

          await complete(tester);
          expect(paymentRepo.lastPayload['given_amount_arr'],
              {'$cashSystemId': '990.00'});
        });

    testWidgets('cash under payable: remaining shown, blocked',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);

          await typeAmount(tester, 'Cash', '900');

          expect(find.text(AppStrings.remainingAmountLabel), findsOneWidget);
          expect(completeEnabled(tester), isFalse);
        });

    testWidgets('single non-cash: locked amount, account required',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Card'));
          await pumpFor(tester);

          expect(paymentScreenState(tester).lockSingleNonCashAmount, isTrue);
          expect(amountField('Card'), findsNothing);
          expect(completeEnabled(tester), isFalse);

          await pickAccount(tester, 'Card', accountLabel('City Bank', '4111'));
          expect(completeEnabled(tester), isTrue);
        });

    testWidgets('split Cash + bKash: editing one fills the other',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);
          await tester.tap(systemChip('bKash'));
          await pumpFor(tester);

          expect(paymentScreenState(tester).selectedEntries.map((e) => e.amount),
              [0, 0]); // cash is never pre-filled
          await pickAccount(
              tester, 'bKash', accountLabel('bKash Personal', '01700000002'));

          await typeAmount(tester, 'Cash', '600');
          expect(paymentScreenState(tester).selectedEntries.last.amount, 390);

          await complete(tester);
          final p = paymentRepo.lastPayload;
          expect(p['payment_acc_id_arr'],
              {'$cashSystemId': '11', '$bkashSystemId': '22'});
          expect(p['given_amount_arr'],
              {'$cashSystemId': '600.00', '$bkashSystemId': '390.00'});
        });

    testWidgets('Cash + bKash: bKash first never fills cash; change from cash',
            (tester) async {
          await openPayment(tester);
          await selectCashAndBkash(tester);

          await typeAmount(tester, 'bKash', '500');
          var s = paymentScreenState(tester);
          expect(s.selectedEntries.map((e) => e.amount), [0, 500]);
          expect(s.shortfall, 490);
          expect(completeEnabled(tester), isFalse);

          await typeAmount(tester, 'Cash', '1000');
          s = paymentScreenState(tester);
          expect(s.selectedEntries.map((e) => e.amount), [1000, 500]);
          expect(s.cashReturn, 510);
          expect(find.text(AppStrings.returnToCustomerLabel), findsOneWidget);

          await complete(tester);
          expect(paymentRepo.lastPayload['given_amount_arr'],
              {'$cashSystemId': '490.00', '$bkashSystemId': '500.00'});
        });

    testWidgets('Cash first fills bKash; typing bKash then shows change',
            (tester) async {
          await openPayment(tester);
          await selectCashAndBkash(tester);

          await typeAmount(tester, 'Cash', '600');
          expect(paymentScreenState(tester).selectedEntries.last.amount, 390);

          await typeAmount(tester, 'bKash', '500');
          final s = paymentScreenState(tester);
          expect(s.selectedEntries.map((e) => e.amount), [600, 500]);
          expect(s.cashReturn, 110);

          await complete(tester);
          expect(paymentRepo.lastPayload['given_amount_arr'],
              {'$cashSystemId': '490.00', '$bkashSystemId': '500.00'});
        });

    testWidgets('typed bKash is kept when cash changes again',
            (tester) async {
          await openPayment(tester);
          await selectCashAndBkash(tester);

          await typeAmount(tester, 'bKash', '500');
          await typeAmount(tester, 'Cash', '700');

          expect(paymentScreenState(tester).selectedEntries.map((e) => e.amount),
              [700, 500]);
          expect(paymentScreenState(tester).cashReturn, 210);
        });

    testWidgets('bKash covers all: cash fully returned and not sent',
            (tester) async {
          await openPayment(tester);
          await selectCashAndBkash(tester);

          await typeAmount(tester, 'bKash', '990');
          await typeAmount(tester, 'Cash', '200');
          expect(paymentScreenState(tester).cashReturn, 200);

          await complete(tester);
          final p = paymentRepo.lastPayload;
          expect(p['payment_acc_id_arr'], {'$bkashSystemId': '22'});
          expect(p['given_amount_arr'], {'$bkashSystemId': '990.00'});
        });

    testWidgets('at most two methods; removing one gives full payable',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);
          await tester.tap(systemChip('bKash'));
          await pumpFor(tester);
          await tester.tap(systemChip('Card'), warnIfMissed: false);
          await pumpFor(tester);
          expect(find.byType(PaymentEntryCard), findsNWidgets(2));

          await tester.tap(find.descendant(
            of: entryCard('bKash'),
            matching: find.byIcon(Icons.close_rounded),
          ));
          await pumpFor(tester);

          final entries = paymentScreenState(tester).selectedEntries;
          expect(entries.single.system.id, cashSystemId);
          expect(entries.single.amount, 990);
        });

    testWidgets('split amounts add up exactly to the payable',
            (tester) async {
          await openPayment(tester, editCart: () async {
            final vat = fieldUnder(AppStrings.vatInputLabel);
            await reveal(tester, vat);
            await tester.enterText(vat, '3.5'); // payable 1024.65
            await pumpFor(tester);
          });
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);
          await tester.tap(systemChip('bKash'));
          await pumpFor(tester);
          await pickAccount(
              tester, 'bKash', accountLabel('bKash Merchant', '01700000001'));

          await typeAmount(tester, 'Cash', '500'); // bKash fills 524.65

          await complete(tester);
          final p = paymentRepo.lastPayload;
          final sent = (p['given_amount_arr'] as Map)
              .values
              .map((v) => double.parse(v as String))
              .fold<double>(0, (a, b) => a + b);
          expect(p['total_payable_amount'], '1024.65');
          expect(sent, closeTo(1024.65, 0.001));
        });
  });

  // ─────────────────────────────── Complete Sale
  group('complete', () {
    testWidgets('POST payload, sale-complete sheet, New Sale cart cleared',
            (tester) async {
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);

          await complete(tester);

          final p = paymentRepo.calls.single;
          expect(p.containsKey('customer_id'), isFalse); // walk-in
          expect(p['total_payable_amount'], '990.00');
          expect(p['given_amount'], '990.00');
          expect(p['total_quantity'], '4');
          expect(p['delivery_charge'], '0');
          expect(p['product_id_arr'], {'0': '1', '1': '2'});
          expect(p['product_quantity_arr'], {'0': '2', '1': '2'});
          expect(p['prod_dis_rate_arr'], {'0': '0.0000', '1': '0.0000'});
          expect(p['prod_vat_rate_arr'], {'0': '0.00', '1': '0.00'});
          expect(p['payment_acc_id_arr'], {'$cashSystemId': '11'});
          expect(p['given_amount_arr'], {'$cashSystemId': '990.00'});

          expect(find.byType(SaleCompleteSheet), findsOneWidget);
          expect(find.text(AppStrings.paymentCollectedTitle), findsOneWidget);
          expect(
            find.text(AppStrings.paymentCollectedBillSubtitle(_newBill, '990.00')),
            findsOneWidget,
          );
          expect(billRepo.requested, [_newBill]);

          expect(newSaleCart(tester), isEmpty); // can't be resold via Back
          expect(paymentScreenState(tester).isSaleCompleted, isTrue);
          expect(completeEnabled(tester), isFalse);
        });

    testWidgets('selected customer is sent', (tester) async {
      await openPayment(tester, editCart: () async {
        await reveal(tester, find.text(AppStrings.selectCustomerHint));
        await tester.tap(find.text(AppStrings.selectCustomerHint));
        await pumpFor(tester);
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Karim'),
        ));
        await pumpFor(tester);
      });
      await tester.tap(systemChip('Cash'));
      await pumpFor(tester);

      await complete(tester);
      expect(paymentRepo.lastPayload['customer_id'], 'C-2');
    });

    testWidgets('server error: snackbar, cart kept, retry works',
            (tester) async {
          paymentRepo.nextError = const ApiException(message: 'Out of stock');
          await openPayment(tester);
          await tester.tap(systemChip('Cash'));
          await pumpFor(tester);

          await complete(tester);
          expect(find.text('Out of stock'), findsOneWidget);
          expect(find.byType(SaleCompleteSheet), findsNothing);
          expect(newSaleCart(tester), hasLength(2));
          expect(completeEnabled(tester), isTrue);

          // The snackbar covers the bottom button (same issue as Edit Sale).
          ScaffoldMessenger.of(tester.element(find.byType(PaymentScreen)))
              .removeCurrentSnackBar();
          await pumpFor(tester);
          await complete(tester);

          expect(paymentRepo.calls, hasLength(2));
          expect(find.byType(SaleCompleteSheet), findsOneWidget);
        });

    testWidgets('New Sale exit restarts the sale flow', (tester) async {
      await openPayment(tester);
      await tester.tap(systemChip('Cash'));
      await pumpFor(tester);
      await complete(tester);

      await tester.ensureVisible(find.text(AppStrings.newSaleTitle));
      await pumpFor(tester);
      await tester.tap(find.text(AppStrings.newSaleTitle));
      await pumpFor(tester);

      expect(find.text(newSaleStub), findsOneWidget);
    });

    testWidgets('Dashboard exit goes to the main shell', (tester) async {
      await openPayment(tester);
      await tester.tap(systemChip('Cash'));
      await pumpFor(tester);
      await complete(tester);

      await tester.ensureVisible(find.text(AppStrings.actionGoToDashboard));
      await pumpFor(tester);
      await tester.tap(find.text(AppStrings.actionGoToDashboard));
      await pumpFor(tester);

      expect(find.text(dashboardStub), findsOneWidget);
    });
  });
}