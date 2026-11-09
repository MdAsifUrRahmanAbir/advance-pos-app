import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/common/primary_button.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/widgets/sale_complete_sheet.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/screens/edit_sale_payment_screen.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/widgets/edit_sale_add_due_bar.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/widgets/edit_sale_payment_changes_list.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/widgets/edit_sale_previous_payment_card.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/change_due_banner.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/payment_entry_card.dart';

import '../test/features/bill_preview/helpers/bill_preview_fixtures.dart';
import '../test/features/bill_preview/helpers/fake_bill_preview_repository.dart';
import '../test/features/cart/helpers/cart_test_host.dart'
    show afterDebounce, qtyOf, stepButton;
import '../test/features/cart/helpers/fake_cart_repository.dart';
import '../test/features/edit_sale_cart/helpers/edit_sale_fixtures.dart';
import '../test/features/edit_sale_cart/helpers/edit_sale_test_host.dart'
    show hostResult;
import '../test/features/edit_sale_cart/helpers/fake_edit_sale_cart_repository.dart';
import '../test/features/edit_sale_payment/helpers/edit_sale_payment_test_host.dart';
import '../test/features/edit_sale_payment/helpers/fake_edit_sale_payment_repository.dart';
import '../test/features/edit_sale_payment/helpers/payment_fixtures.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart'
    show pumpFor, seedApiParams;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeEditSaleCartRepository editRepo;
  late FakeCartRepository cartRepo;
  late FakeEditSalePaymentRepository paymentRepo;
  late FakeBillPreviewRepository billRepo;

  // Error paths build endpoint URLs from the static ApiParams.current.
  setUpAll(seedApiParams);

  setUp(() {
    editRepo = FakeEditSaleCartRepository();
    cartRepo = FakeCartRepository();
    paymentRepo = FakeEditSalePaymentRepository();
    billRepo = FakeBillPreviewRepository(bill: billJson(billNo: editBillNo));
  });

  /// Opens Edit Sale (invoice paid 1039.50 in Cash). [editCart] runs on
  /// the cart before Proceed.
  Future<void> openPayment(
      WidgetTester tester, {
        bool signedIn = true,
        bool methodsFailFirst = false,
        Future<void> Function()? editCart,
      }) async {
    await pumpEditSalePaymentApp(
      tester,
      editRepository: editRepo,
      cartRepository: cartRepo,
      paymentRepository: paymentRepo,
      billRepository: billRepo,
      accounts: sampleAccounts(),
      signedIn: signedIn,
      methodsFailFirst: methodsFailFirst,
    );
    if (editCart != null) await editCart();
    await goToPayment(tester);
  }

  /// Scrolls [finder] to the middle of the list and lets the frame land,
  /// so a tap can't hit the bottom Update bar or miss off-screen.
  Future<void> revealCenter(WidgetTester tester, Finder finder) async {
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await pumpFor(tester);
  }

  /// Opens [system]'s account dropdown and picks [label].
  Future<void> pickAccount(
      WidgetTester tester,
      String system,
      String label,
      ) async {
    await revealCenter(tester, accountDropdown(system));
    await tester.tap(accountDropdown(system));
    await pumpFor(tester);
    await tester.tap(find.text(label).last);
    await pumpFor(tester);
  }

  bool updateEnabled(WidgetTester tester) => tester
      .widget<PrimaryButton>(
    find.ancestor(of: updateButton, matching: find.byType(PrimaryButton)),
  )
      .onPressed !=
      null;

  Future<void> tapUpdateAndConfirm(WidgetTester tester) async {
    await tester.tap(updateButton);
    await pumpFor(tester);
    await tester.tap(find.text(AppStrings.editSaleUpdateAction).last);
    await pumpFor(tester);
  }

  /// Adds bKash with bKash Merchant (id 21).
  Future<void> addBkash(WidgetTester tester) async {
    await revealCenter(tester, systemChip('bKash'));
    await tester.tap(systemChip('bKash'));
    await pumpFor(tester);
    await pickAccount(
        tester, 'bKash', accountLabel('bKash Merchant', '01700000001'));
  }

  /// The error snackbar sits on top of the bottom Update button, so a
  /// retry tap would land on the snackbar (flagged as a UX issue).
  Future<void> dismissSnackBar(WidgetTester tester) async {
    ScaffoldMessenger.of(tester.element(find.byType(EditSalePaymentScreen)))
        .removeCurrentSnackBar();
    await pumpFor(tester);
  }

  // ─────────────────────────────── Opening
  group('opening', () {
    testWidgets('cart totals, previous payment and its method',
            (tester) async {
          await openPayment(tester); // 990 + 5 % VAT

          expect(find.byType(EditSalePaymentScreen), findsOneWidget);
          expect(find.text('1039.50'), findsWidgets); // payable card
          expect(find.byType(EditSalePreviousPaymentCard), findsOneWidget);
          expect(find.text(AppStrings.editSalePreviousPaymentTitle), findsOneWidget);
          expect(find.text(AppStrings.editSaleOriginalTotalLabel), findsOneWidget);
          expect(find.text(AppStrings.editSaleNoDifferenceLabel), findsOneWidget);

          final state = paymentState(tester);
          expect(state.payableAmount, 1039.5);
          expect(state.previousPayments.single.amount, 1039.5);
          expect(state.prefilledFromInvoice, isTrue);
          expect(state.selectedEntries.single.system.id, cashSystemId);
          expect(state.selectedEntries.single.amount, 1039.5);
          expect(entryCard('Cash'), findsOneWidget);
          expect(updateEnabled(tester), isTrue);
        });

    testWidgets('an edited cart shows the difference to the original',
            (tester) async {
          await openPayment(tester, editCart: () async {
            await tester.tap(stepButton('Rice 5kg', Icons.add)); // +450
            await pumpFor(tester, afterDebounce);
          });

          expect(paymentState(tester).payableAmount, 1512); // 1440 × 1.05
          expect(find.text('+472.50'), findsOneWidget);
          expect(find.text(AppStrings.editSaleCollectMoreLabel), findsOneWidget);
        });

    testWidgets('methods failed to load: Retry loads and pre-fills',
            (tester) async {
          await openPayment(tester, methodsFailFirst: true);

          expect(find.text(AppStrings.paymentMethodsLoadError), findsOneWidget);
          expect(updateEnabled(tester), isFalse);

          await revealCenter(tester, find.text(AppStrings.retry));
          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);

          expect(systemChip('Cash'), findsOneWidget);
          expect(entryCard('Cash'), findsOneWidget);
          expect(updateEnabled(tester), isTrue);
        });

    testWidgets('Back returns to the cart with edits intact',
            (tester) async {
          await openPayment(tester, editCart: () async {
            await tester.tap(stepButton('Rice 5kg', Icons.add));
            await pumpFor(tester, afterDebounce);
          });

          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await pumpFor(tester);

          expect(find.byType(EditSalePaymentScreen), findsNothing);
          expect(qtyOf('Rice 5kg', 3), findsOneWidget);
        });
  });

  // ─────────────────────────────── Amounts and methods
  group('amounts', () {
    testWidgets('cash above payable shows change; payload sends net',
            (tester) async {
          await openPayment(tester);

          await tester.enterText(amountField('Cash'), '1100');
          await pumpFor(tester);

          expect(find.text(AppStrings.returnToCustomerLabel), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(ChangeDueBanner),
              matching: find.text('60.50'),
            ),
            findsOneWidget,
          );

          await tapUpdateAndConfirm(tester);
          final payload = paymentRepo.lastPayload;
          expect(payload['given_amount'], '1039.50');
          expect(payload['given_amount_arr'], {'$cashSystemId': '1039.50'});
        });

    testWidgets('cash below payable blocks Update', (tester) async {
      await openPayment(tester);

      await tester.enterText(amountField('Cash'), '1000');
      await pumpFor(tester);

      expect(find.text(AppStrings.remainingAmountLabel), findsOneWidget);
      expect(updateEnabled(tester), isFalse);
    });

    testWidgets('split Cash + bKash: account required, other side fills',
            (tester) async {
          await openPayment(tester);

          await revealCenter(tester, systemChip('bKash'));
          await tester.tap(systemChip('bKash'));
          await pumpFor(tester);
          // The previous cash payment stays; bKash starts empty.
          expect(paymentState(tester).selectedEntries.map((e) => e.amount),
              [1039.5, 0]);
          expect(updateEnabled(tester), isFalse); // bKash has no account yet

          await pickAccount(
              tester, 'bKash', accountLabel('bKash Merchant', '01700000001'));

          await tester.enterText(amountField('Cash'), '600');
          await pumpFor(tester);
          expect(paymentState(tester).selectedEntries.last.amount, 439.5);
          expect(updateEnabled(tester), isTrue);

          await tapUpdateAndConfirm(tester);
          final payload = paymentRepo.lastPayload;
          expect(payload['payment_acc_id_arr'],
              {'$cashSystemId': '11', '$bkashSystemId': '21'});
          expect(payload['given_amount_arr'],
              {'$cashSystemId': '600.00', '$bkashSystemId': '439.50'});
        });

    testWidgets('bKash typed: cash kept, extra returned from cash',
            (tester) async {
          await openPayment(tester);
          await addBkash(tester);

          await tester.enterText(amountField('bKash'), '500');
          await pumpFor(tester);
          final s = paymentState(tester);
          expect(s.selectedEntries.map((e) => e.amount), [1039.5, 500]);
          expect(s.cashReturn, 500);
          expect(find.byType(EditSalePaymentChangesList), findsOneWidget);

          await tapUpdateAndConfirm(tester);
          final payload = paymentRepo.lastPayload;
          expect(payload['given_amount'], '1039.50');
          expect(payload['given_amount_arr'],
              {'$cashSystemId': '539.50', '$bkashSystemId': '500.00'});
        });

    testWidgets('more to pay: Add to bKash collects the rest there',
            (tester) async {
          await openPayment(tester, editCart: () async {
            await tester.tap(stepButton('Rice 5kg', Icons.add)); // 1512
            await pumpFor(tester, afterDebounce);
          });
          expect(paymentState(tester).shortfall, closeTo(472.5, 0.001));
          expect(updateEnabled(tester), isFalse);

          await addBkash(tester);
          final addBkashChip = find.descendant(
            of: find.byType(EditSaleAddDueBar),
            matching: find.byType(ActionChip),
          ).last; // chips follow the entry order: Cash, bKash
          await revealCenter(tester, addBkashChip);
          await tester.tap(addBkashChip);
          await pumpFor(tester);

          final s = paymentState(tester);
          expect(s.selectedEntries.map((e) => e.amount), [1039.5, 472.5]);
          expect(s.shortfall, 0);
          expect(find.byType(EditSaleAddDueBar), findsNothing);
          expect(updateEnabled(tester), isTrue);

          await tapUpdateAndConfirm(tester);
          final payload = paymentRepo.lastPayload;
          expect(payload['given_amount'], '1512.00');
          expect(payload['given_amount_arr'],
              {'$cashSystemId': '1039.50', '$bkashSystemId': '472.50'});
        });

    testWidgets('less to pay: difference returned from Cash',
            (tester) async {
          await openPayment(tester, editCart: () async {
            await tester.tap(stepButton('Rice 5kg', Icons.remove)); // 567
            await pumpFor(tester, afterDebounce);
          });

          final s = paymentState(tester);
          expect(s.payableAmount, 567);
          expect(s.cashReturn, closeTo(472.5, 0.001));
          expect(find.text('-472.50'), findsWidgets); // pill + changes row
          expect(find.text(AppStrings.editSaleReturnFromCashNote), findsOneWidget);
          expect(updateEnabled(tester), isTrue);

          await tapUpdateAndConfirm(tester);
          final payload = paymentRepo.lastPayload;
          expect(payload['given_amount'], '567.00');
          expect(payload['given_amount_arr'], {'$cashSystemId': '567.00'});
        });

    testWidgets('at most two methods', (tester) async {
      await openPayment(tester);

      await revealCenter(tester, systemChip('bKash'));
      await tester.tap(systemChip('bKash'));
      await pumpFor(tester);
      await tester.tap(systemChip('Card'), warnIfMissed: false);
      await pumpFor(tester);

      expect(find.byType(PaymentEntryCard), findsNWidgets(2));
      expect(entryCard('Card'), findsNothing);
    });

    testWidgets('single non-cash method: amount locked to payable',
            (tester) async {
          await openPayment(tester);

          await revealCenter(tester, systemChip('Cash'));
          await tester.tap(systemChip('Cash')); // deselect
          await pumpFor(tester);
          expect(find.text(AppStrings.selectPaymentMethodToContinue),
              findsOneWidget);

          await tester.tap(systemChip('Card'));
          await pumpFor(tester);
          final state = paymentState(tester);
          expect(state.lockSingleNonCashAmount, isTrue);
          expect(state.selectedEntries.single.amount, 1039.5);
          expect(amountField('Card'), findsNothing); // read-only
          expect(updateEnabled(tester), isFalse); // account not chosen yet

          await pickAccount(tester, 'Card', accountLabel('City Bank', '4111'));
          expect(updateEnabled(tester), isTrue);
        });
  });

  // ─────────────────────────────── Update Sale
  group('update', () {
    testWidgets('confirm, PUT payload, then the sale-complete sheet',
            (tester) async {
          await openPayment(tester);

          await tester.tap(updateButton);
          await pumpFor(tester);
          expect(find.text(AppStrings.editSaleConfirmTitle), findsOneWidget);

          await tester.tap(find.text(AppStrings.editSaleUpdateAction).last);
          await pumpFor(tester);

          final call = paymentRepo.calls.single;
          expect(call.billNo, editBillNo);
          final p = call.data;
          expect(p['customer_id'], 'C-1');
          expect(p['total_payable_amount'], '1039.50');
          expect(p['given_amount'], '1039.50');
          expect(p['total_quantity'], '4');
          expect(p['delivery_charge'], '0');
          expect(p['product_id_arr'], {'0': '1', '1': '2'});
          expect(p['product_quantity_arr'], {'0': '2', '1': '2'});
          expect(p['prod_vat_rate_arr'], {'0': '5.00', '1': '5.00'});
          expect(p['payment_acc_id_arr'], {'$cashSystemId': '11'});
          expect(p['given_amount_arr'], {'$cashSystemId': '1039.50'});

          expect(find.byType(SaleCompleteSheet), findsOneWidget);
          expect(find.text(AppStrings.editSaleUpdatedTitle), findsOneWidget);
          expect(find.text(AppStrings.editSaleUpdatedSubtitle(editBillNo)),
              findsOneWidget);
          expect(billRepo.requested, [editBillNo]);
          expect(paymentState(tester).isUpdated, isTrue);
          expect(updateEnabled(tester), isFalse); // no double submit
        });

    testWidgets('Done unwinds to Invoices with true', (tester) async {
      await openPayment(tester);
      await tapUpdateAndConfirm(tester);

      await tester.ensureVisible(find.text(AppStrings.done));
      await tester.tap(find.text(AppStrings.done));
      await pumpFor(tester);
      await pumpFor(tester); // cart pops itself on the next frame

      expect(find.text(hostResult(true)), findsOneWidget);
    });

    testWidgets('New Sale exit restarts the sale flow', (tester) async {
      await openPayment(tester);
      await tapUpdateAndConfirm(tester);

      // Below the fold on a phone-sized screen — scroll the sheet first.
      await tester.ensureVisible(find.text(AppStrings.newSaleTitle));
      await pumpFor(tester);
      await tester.tap(find.text(AppStrings.newSaleTitle));
      await pumpFor(tester);

      expect(find.text(newSaleStub), findsOneWidget);
    });

    testWidgets('Dashboard exit goes to the main shell', (tester) async {
      await openPayment(tester);
      await tapUpdateAndConfirm(tester);

      await tester.ensureVisible(find.text(AppStrings.saleDoneDashboardAction));
      await tester.tap(find.text(AppStrings.saleDoneDashboardAction));
      await pumpFor(tester);

      expect(find.text(dashboardStub), findsOneWidget);
    });

    testWidgets('cancelling the confirm sends nothing', (tester) async {
      await openPayment(tester);

      await tester.tap(updateButton);
      await pumpFor(tester);
      await tester.tap(find.text(AppStrings.cancel));
      await pumpFor(tester);

      expect(paymentRepo.calls, isEmpty);
      expect(find.byType(SaleCompleteSheet), findsNothing);
    });

    testWidgets('server error: snackbar, stay, can retry', (tester) async {
      paymentRepo.nextError =
      const ApiException(message: 'Stock changed, try again');
      await openPayment(tester);

      await tapUpdateAndConfirm(tester);

      expect(find.text('Stock changed, try again'), findsOneWidget);
      expect(find.byType(SaleCompleteSheet), findsNothing);
      expect(updateEnabled(tester), isTrue);

      await dismissSnackBar(tester);
      await tapUpdateAndConfirm(tester);
      expect(paymentRepo.calls, hasLength(2));
      expect(find.byType(SaleCompleteSheet), findsOneWidget);
    });

    testWidgets('signed out: no request, explains why', (tester) async {
      await openPayment(tester, signedIn: false);

      await tapUpdateAndConfirm(tester);

      expect(paymentRepo.calls, isEmpty);
      expect(find.text(AppStrings.editSaleNotSignedIn), findsOneWidget);
    });
  });
}