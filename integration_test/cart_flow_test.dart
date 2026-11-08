import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/empty_state.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/cart/presentation/states/cart_state.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/add_customer_sheet.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/customer_search_sheet.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/customer_selector_row.dart';

import '../test/features/cart/helpers/cart_fixtures.dart';
import '../test/features/cart/helpers/cart_test_host.dart';
import '../test/features/cart/helpers/fake_cart_repository.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeCartRepository repo;

  setUp(() => repo = FakeCartRepository());

  Future<void> openCart(WidgetTester tester) =>
      pumpCartApp(tester, repository: repo);

  void expectTotals(
      WidgetTester tester, {
        required String subtotal,
        required String total,
      }) {
    expect(textOf(tester, summaryValue(AppStrings.subtotalLabel)), subtotal);
    expect(textOf(tester, summaryValue(AppStrings.totalPayableLabel)), total);
  }

  // ─────────────────────────────── Lines
  group('cart lines', () {
    testWidgets('shows lines and totals; checks discounts once on open',
            (tester) async {
          await openCart(tester);

          expect(find.byType(CartItemCard), findsNWidgets(2));
          expect(find.text(AppStrings.eachPriceLabel('450.00')), findsOneWidget);
          expect(find.text('900.00'), findsOneWidget);

          await reveal(tester, find.text(AppStrings.totalPayableLabel));
          expectTotals(tester, subtotal: '990.00', total: '990.00');
          expect(find.text(AppStrings.discountNotAvailable), findsOneWidget);

          final call = repo.discountCalls.single;
          expect(call.productIds, ['1', '2']);
          expect(call.quantities, [2, 2]);
          expect(call.amounts, [900.0, 90.0]); // line totals, not unit prices
          expect(call.customerId, isNull);
        });

    testWidgets('+ updates line and subtotal, then re-checks discounts',
            (tester) async {
          await openCart(tester);

          await tester.tap(stepButton('Rice 5kg', Icons.add));
          await pumpFor(tester, afterDebounce);

          expect(qtyOf('Rice 5kg', 3), findsOneWidget);
          expect(find.text('1350.00'), findsOneWidget);
          expect(cartState(tester).subtotal, 1440);
          expect(repo.discountCalls, hasLength(2));
          expect(repo.discountCalls.last.quantities, [3, 2]);
          expect(repo.discountCalls.last.amounts, [1350.0, 90.0]);
        });

    testWidgets('+ stops at available stock', (tester) async {
      await openCart(tester);

      await tester.tap(stepButton('Soap', Icons.add)); // stock 2, qty 2
      await pumpFor(tester, afterDebounce);

      expect(qtyOf('Soap', 2), findsOneWidget);
      expect(cartState(tester).subtotal, 990);
      expect(repo.discountCalls, hasLength(1)); // nothing changed
    });

    testWidgets('− at quantity 1 removes the line', (tester) async {
      await openCart(tester);

      await tester.tap(stepButton('Soap', Icons.remove));
      await pumpFor(tester);
      expect(qtyOf('Soap', 1), findsOneWidget);

      await tester.tap(stepButton('Soap', Icons.remove));
      await pumpFor(tester, afterDebounce);
      expect(find.text('Soap'), findsNothing);
      expect(repo.discountCalls.last.productIds, ['1']);
    });

    testWidgets('swipe left deletes a line', (tester) async {
      await openCart(tester);

      await tester.drag(cardOf('Soap'), const Offset(-600, 0));
      await pumpFor(tester);

      expect(find.text('Soap'), findsNothing);
      expect(find.byType(CartItemCard), findsOneWidget);
    });

    testWidgets('Clear All empties the cart without a discount call',
            (tester) async {
          await openCart(tester);

          await tester.tap(find.text(AppStrings.clearAllAction));
          await pumpFor(tester, afterDebounce);

          expect(find.byType(CartItemCard), findsNothing);
          expect(find.text(AppStrings.swipeToDeleteHint), findsNothing);
          expectTotals(tester, subtotal: '0.00', total: '0.00');
          expect(repo.discountCalls, hasLength(1)); // only the opening check
        });
  });

  // ─────────────────────────────── Discount rules
  group('discounts', () {
    testWidgets('regular: typed % is capped by the server rule',
            (tester) async {
          repo.discount = (_) => regularPercent(10);
          await openCart(tester);

          final field = fieldUnder(AppStrings.discountInputLabel);
          await reveal(tester, field);
          await tester.enterText(field, '50');
          await pumpFor(tester);

          // Re-created with the capped value.
          expect(
            tester
                .widget<TextField>(fieldUnder(AppStrings.discountInputLabel))
                .controller!
                .text,
            '10',
          );
          expect(find.textContaining(AppStrings.discountMaxHint('10%')),
              findsOneWidget);

          await reveal(tester, find.text(AppStrings.totalPayableLabel));
          expect(
            textOf(tester, summaryValue(AppStrings.discountPercentLabel('10'))),
            '- 99.00',
          );
          expectTotals(tester, subtotal: '990.00', total: '891.00');
        });

    testWidgets('regular: switching to ৳ converts the value',
            (tester) async {
          repo.discount = (_) => regularPercent(10);
          await openCart(tester);

          final field = fieldUnder(AppStrings.discountInputLabel);
          await reveal(tester, field);
          await tester.enterText(field, '10');
          await pumpFor(tester);
          await tester.tap(find.text('৳'));
          await pumpFor(tester);

          expect(cartState(tester).discountType, DiscountType.amount);
          expect(
            tester
                .widget<TextField>(fieldUnder(AppStrings.discountInputLabel))
                .controller!
                .text,
            '99',
          );
          expect(cartState(tester).discountAmount, 99);
        });

    testWidgets('bill: fixed amount, read-only, codes shown', (tester) async {
      repo.discount = (_) => billFixed(50, codes: ['BILL50']);
      await openCart(tester);
      await reveal(tester, find.text(AppStrings.totalPayableLabel));

      expect(find.text(AppStrings.discountInputLabel), findsNothing);
      expect(find.text('50.00'), findsOneWidget); // locked box
      expect(find.text(AppStrings.discountCodesLabel('BILL50')),
          findsOneWidget);
      expect(
        textOf(
          tester,
          summaryValue(
            AppStrings.discountPercentLabel(trimDecimal(50 / 990 * 100)),
          ),
        ),
        '- 50.00',
      );
      expectTotals(tester, subtotal: '990.00', total: '940.00');
    });

    testWidgets('product: discount shown on its line', (tester) async {
      repo.discount = (_) => productWise({'1': 100});
      await openCart(tester);

      expect(find.text(AppStrings.lineDiscountLabel('100.00')),
          findsOneWidget);
      expect(
        find.descendant(of: cardOf('Rice 5kg'), matching: find.text('800.00')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cardOf('Rice 5kg'), matching: find.text('900.00')),
        findsOneWidget, // struck-through original
      );

      await reveal(tester, find.text(AppStrings.totalPayableLabel));
      expectTotals(tester, subtotal: '990.00', total: '890.00');
    });

    testWidgets('both: seller picks Bill wise, cart re-checks with it',
            (tester) async {
          repo.discount = (call) => call.discountType == 'bill'
              ? billFixed(50)
              : bothRules(perLine: {'1': 100}, bill: 50);
          await openCart(tester);

          await reveal(tester, find.text(AppStrings.discountBillWise));
          expect(find.text(AppStrings.discountProductWise), findsOneWidget);
          expect(cartState(tester).discountAmount, 100); // product by default

          await tester.tap(find.text(AppStrings.discountBillWise));
          await pumpFor(tester);

          expect(repo.discountCalls.last.discountType, 'bill');
          expect(find.text(AppStrings.discountBillWise), findsOneWidget);
          expect(cartState(tester).discountAmount, 50);

          await reveal(tester, find.text(AppStrings.totalPayableLabel));
          expectTotals(tester, subtotal: '990.00', total: '940.00');
        });

    testWidgets('failed check leaves no discount and shows why',
            (tester) async {
          repo.nextDiscountError =
          const ApiException(message: 'Discount service down');
          await openCart(tester);
          await reveal(tester, find.text(AppStrings.totalPayableLabel));

          expect(find.text(AppStrings.discountNotAvailable), findsOneWidget);
          expect(find.text('Discount service down'), findsOneWidget);
          expectTotals(tester, subtotal: '990.00', total: '990.00');
        });

    testWidgets('VAT % is added after discount', (tester) async {
      await openCart(tester);

      final field = fieldUnder(AppStrings.vatInputLabel);
      await reveal(tester, field);
      await tester.enterText(field, '5');
      await pumpFor(tester);

      await reveal(tester, find.text(AppStrings.totalPayableLabel));
      expect(
        textOf(tester, summaryValue(AppStrings.vatTaxPercentLabel('5'))),
        '+ 49.50',
      );
      expectTotals(tester, subtotal: '990.00', total: '1039.50');
    });
  });

  // ─────────────────────────────── Customer
  group('customer', () {
    Future<void> openPicker(WidgetTester tester) async {
      await reveal(tester, find.text(AppStrings.selectCustomerHint));
      await tester.tap(find.text(AppStrings.selectCustomerHint));
      await pumpFor(tester);
    }

    Finder sheetSearch() => find.descendant(
      of: find.byType(CustomerSearchSheet),
      matching: find.byType(TextField),
    );

    /// A result row — not the search box, which may hold the same text.
    Finder customerRow(String name) => find.descendant(
      of: find.byType(ListTile),
      matching: find.text(name),
    );

    testWidgets('pick a customer; discount re-checked for them',
            (tester) async {
          await openCart(tester);
          await openPicker(tester);

          expect(customerRow('Rahim'), findsOneWidget);
          expect(customerRow('Karim'), findsOneWidget);

          // Under 4 characters: no request.
          await tester.enterText(sheetSearch(), 'Ka');
          await pumpFor(tester, afterDebounce);
          expect(repo.customerSearches, ['']);

          await tester.enterText(sheetSearch(), 'Karim');
          await pumpFor(tester, afterDebounce);
          expect(repo.customerSearches.last, 'Karim');
          expect(customerRow('Rahim'), findsNothing);

          await tester.tap(customerRow('Karim'));
          await pumpFor(tester);

          expect(find.byType(CustomerSearchSheet), findsNothing);
          expect(
            find.descendant(
              of: find.byType(CustomerSelectorRow),
              matching: find.text('Karim'),
            ),
            findsOneWidget,
          );
          expect(repo.discountCalls.last.customerId, 'C-2');
        });

    testWidgets('no match shows the empty state', (tester) async {
      await openCart(tester);
      await openPicker(tester);

      await tester.enterText(sheetSearch(), 'Nobody');
      await pumpFor(tester, afterDebounce);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(AppStrings.noCustomersFoundTitle), findsOneWidget);
    });

    testWidgets('failed load shows ErrorState; Retry recovers',
            (tester) async {
          repo.nextCustomersError = const ApiException(message: 'Server down');
          await openCart(tester);
          await openPicker(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          await tester.tap(find.descendant(
            of: find.byType(ErrorState),
            matching: find.byType(OutlinedButton),
          ));
          await pumpFor(tester);
          expect(customerRow('Rahim'), findsOneWidget);
        });
  });

  // ─────────────────────────────── Add customer
  group('add customer', () {
    Future<void> openAddSheet(WidgetTester tester) async {
      final plus = find.descendant(
        of: find.byType(CustomerSelectorRow),
        matching: find.byIcon(Icons.add),
      );
      await reveal(tester, plus);
      await tester.tap(plus);
      await pumpFor(tester);
    }

    Finder submit() => find.text(AppStrings.addCustomerTitle).last;

    Future<void> fill(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, AppStrings.customerNameHint),
        'Nasir',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, AppStrings.customerNumberHint),
        '01799999999',
      );
      await pumpFor(tester);
    }

    testWidgets('empty form shows required errors', (tester) async {
      await openCart(tester);
      await openAddSheet(tester);

      await tester.tap(submit());
      await pumpFor(tester);

      expect(find.text(AppStrings.customerNameRequiredError), findsOneWidget);
      expect(
          find.text(AppStrings.customerNumberRequiredError), findsOneWidget);
      expect(repo.created, isEmpty);
    });

    testWidgets('creates, selects and confirms the new customer',
            (tester) async {
          await openCart(tester);
          await openAddSheet(tester);
          await fill(tester);

          await tester.tap(submit());
          await pumpFor(tester);

          expect(find.byType(AddCustomerSheet), findsNothing);
          expect(repo.created.single['name'], 'Nasir');
          expect(repo.created.single['mobile'], '01799999999');
          expect(find.text(AppStrings.customerAddedSuccessMessage('Nasir')),
              findsOneWidget);
          expect(cartState(tester).selectedCustomer?.customerName, 'Nasir');
        });

    testWidgets('server error stays on the form with the message',
            (tester) async {
          repo.nextCreateError =
          const ApiException(message: 'Mobile already exists');
          await openCart(tester);
          await openAddSheet(tester);
          await fill(tester);

          await tester.tap(submit());
          await pumpFor(tester);

          expect(find.byType(AddCustomerSheet), findsOneWidget);
          expect(find.text('Mobile already exists'), findsOneWidget);
          expect(cartState(tester).selectedCustomer, isNull);
        });
  });

  // ─────────────────────────────── Navigation
  group('navigation', () {
    testWidgets('Proceed to Payment opens Payment', (tester) async {
      await openCart(tester);

      await reveal(tester, find.text(AppStrings.proceedToPaymentAction));
      await tester.tap(find.text(AppStrings.proceedToPaymentAction));
      await pumpFor(tester);

      expect(find.text(cartPaymentStub), findsOneWidget);
    });

    testWidgets('Back returns to the previous screen', (tester) async {
      await openCart(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await pumpFor(tester);

      expect(find.text(cartHostOpen), findsOneWidget);
      expect(find.byType(CartItemCard), findsNothing);
    });
  });
}