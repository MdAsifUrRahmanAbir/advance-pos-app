import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/custom_loader.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/widgets/edit_sale_add_customer_sheet.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/widgets/edit_sale_customer_row.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/widgets/edit_sale_customer_search_sheet.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart'
    show ScanOutcome;

import '../test/features/cart/helpers/cart_fixtures.dart';
import '../test/features/cart/helpers/cart_test_host.dart'
    show afterDebounce, cardOf, fieldUnder, qtyOf, reveal, stepButton, summaryValue, textOf;
import '../test/features/cart/helpers/fake_cart_repository.dart';
import '../test/features/edit_sale_cart/helpers/edit_sale_fixtures.dart';
import '../test/features/edit_sale_cart/helpers/edit_sale_test_host.dart';
import '../test/features/edit_sale_cart/helpers/fake_edit_sale_cart_repository.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart'
    show pumpFor, seedApiParams;

/// On a device the screen only redraws on pump(), and one long pump is
/// one frame. A swipe-to-delete runs two animations before
/// onDismissed, and only then does the 400 ms discount debounce start,
/// so pump short steps for long enough to cover all of it.
Future<void> pumpFrames(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeEditSaleCartRepository repo;
  late FakeCartRepository cartRepo;

  // ApiEndpoints reads the static ApiParams.current (the controller's
  // error path builds an endpoint URL), not the overridden provider.
  setUpAll(seedApiParams);

  setUp(() {
    repo = FakeEditSaleCartRepository();
    cartRepo = FakeCartRepository();
  });

  Future<void> openEditSale(WidgetTester tester) => pumpEditSaleApp(
    tester,
    repository: repo,
    cartRepository: cartRepo,
  );

  Finder customerRowText(String text) => find.descendant(
    of: find.byType(EditSaleCustomerRow),
    matching: find.text(text),
  );

  // ─────────────────────────────── Loading the invoice
  group('load', () {
    testWidgets('loader, then the invoice as an editable cart',
            (tester) async {
          repo.invoiceGate = Completer<void>();
          final gate = repo.invoiceGate!;
          await openEditSale(tester);
          expect(find.byType(CustomLoader), findsOneWidget);

          gate.complete();
          await pumpFor(tester);

          expect(find.text(AppStrings.editSaleEditingLabel), findsOneWidget);
          expect(find.text('17-10-2026'), findsOneWidget);
          expect(find.byType(CartItemCard), findsNWidgets(2));
          expect(qtyOf('Soap', 2), findsOneWidget); // two rows merged
          expect(customerRowText('Rahim'), findsOneWidget);

          await reveal(tester, find.text(AppStrings.editSaleProceedAction));
          expect(textOf(tester, summaryValue(AppStrings.subtotalLabel)), '990.00');
          expect(
            textOf(tester, summaryValue(AppStrings.vatTaxPercentLabel('5'))),
            '+ 49.50', // original VAT % carried over
          );

          final discount = cartRepo.discountCalls.single;
          expect(discount.customerId, 'C-1');
          expect(discount.salesDate, DateTime(2026, 10, 17)); // original day
          expect(discount.quantities, [2, 2]);
          expect(editState(tester).hasChanges, isFalse);
        });

    testWidgets('failed load shows ErrorState; Retry recovers',
            (tester) async {
          repo.nextInvoiceError = const ApiException(message: 'Server down');
          await openEditSale(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);

          await tester.tap(find.descendant(
            of: find.byType(ErrorState),
            matching: find.byType(OutlinedButton),
          ));
          await pumpFor(tester);
          expect(find.byType(CartItemCard), findsNWidgets(2));
          expect(repo.invoiceLoads, hasLength(2));
        });

    testWidgets('walk-in invoice: no customer lookup', (tester) async {
      repo.invoice = invoiceJson(customerName: '-', customerMobile: null);
      await openEditSale(tester);

      expect(customerRowText(AppStrings.editSaleWalkInCustomer),
          findsOneWidget);
      expect(cartRepo.customerSearches, isEmpty);
      expect(cartRepo.discountCalls.single.customerId, isNull);
    });

    testWidgets('customer not in the list keeps the invoice customer',
            (tester) async {
          repo.invoice = invoiceJson(
            customerName: 'Nasir',
            customerMobile: '01799999999',
            customerNo: 'C-99',
          );
          await openEditSale(tester);

          expect(customerRowText('Nasir'), findsOneWidget);
          expect(cartRepo.discountCalls.single.customerId, 'C-99');
        });

    testWidgets('original discount % is restored, capped by today\'s rule',
            (tester) async {
          repo.invoice = invoiceJson(discountRate: '10');
          cartRepo.discount = (_) => regularPercent(5);
          await openEditSale(tester);

          final field = fieldUnder(AppStrings.discountInputLabel);
          await reveal(tester, field);
          expect(tester.widget<TextField>(field).controller!.text, '5');
          expect(editState(tester).hasChanges, isFalse); // restore is not an edit
        });
  });

  // ─────────────────────────────── Lines
  group('lines', () {
    testWidgets('+ is capped at branch stock + originally sold',
            (tester) async {
          await openEditSale(tester); // Soap: stock 2 + sold 2 = cap 4

          await tester.tap(stepButton('Soap', Icons.add));
          await pumpFor(tester);
          await tester.tap(stepButton('Soap', Icons.add));
          await pumpFor(tester);
          expect(qtyOf('Soap', 4), findsOneWidget);

          await tester.tap(stepButton('Soap', Icons.add));
          await pumpFor(tester);
          expect(qtyOf('Soap', 4), findsOneWidget);
          expect(find.text(AppStrings.editSaleNoMoreStock('Soap')),
              findsOneWidget);
        });

    testWidgets('− at quantity 1 removes the line', (tester) async {
      await openEditSale(tester); // Rice ×2

      await tester.tap(stepButton('Rice 5kg', Icons.remove));
      await pumpFor(tester);
      expect(qtyOf('Rice 5kg', 1), findsOneWidget);

      await tester.tap(stepButton('Rice 5kg', Icons.remove));
      await pumpFor(tester, afterDebounce);

      expect(find.text('Rice 5kg'), findsNothing);
      expect(cartRepo.discountCalls.last.productIds, ['2']);
    });

    testWidgets('swipe left deletes a line', (tester) async {
      await openEditSale(tester);

      await tester.drag(cardOf('Soap'), const Offset(-600, 0));
      await pumpFrames(tester); // dismiss animations + debounce + request

      expect(find.text('Soap'), findsNothing);
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(editState(tester).cart.items.map((i) => i.id), ['1']);
      expect(cartRepo.discountCalls.last.productIds, ['1']);
    });

    testWidgets('no lines: empty state and Proceed disabled',
            (tester) async {
          await openEditSale(tester);

          await tester.drag(cardOf('Rice 5kg'), const Offset(-600, 0));
          await pumpFrames(tester);
          await tester.drag(cardOf('Soap'), const Offset(-600, 0));
          await pumpFrames(tester);

          expect(find.text(AppStrings.editSaleNoItemsTitle), findsOneWidget);
          expect(editState(tester).cart.items, isEmpty);
          expect(editState(tester).canProceed, isFalse);

          await reveal(tester, find.text(AppStrings.editSaleProceedAction));
          await tester.tap(find.text(AppStrings.editSaleProceedAction),
              warnIfMissed: false);
          await pumpFor(tester);
          expect(find.text(paymentSave), findsNothing);
        });
  });

  // ─────────────────────────────── Product search
  group('product search', () {
    testWidgets('needs 3 characters; shows available count', (tester) async {
      await openEditSale(tester);
      final searchesAfterLoad = repo.searches.length; // stock lookups

      await tester.enterText(productSearchField(), 'Ri');
      await pumpFor(tester, afterDebounce);
      expect(productResults, findsNothing);
      expect(repo.searches, hasLength(searchesAfterLoad));

      await tester.enterText(productSearchField(), 'Ric');
      await pumpFor(tester, afterDebounce);

      expect(find.text(AppStrings.editSaleSearchResultsTitle), findsOneWidget);
      // Stock 5 + sold 2 - already in cart 2 = 5 more.
      expect(find.textContaining(AppStrings.editSaleAvailableLabel(5)),
          findsOneWidget);
    });

    testWidgets('adding an existing product keeps the invoice price',
            (tester) async {
          await openEditSale(tester);
          await tester.enterText(productSearchField(), 'Ric');
          await pumpFor(tester, afterDebounce);

          await tester.tap(resultAddButton('Rice 5kg'));
          await pumpFor(tester);

          expect(find.text(AppStrings.productAddedMessage('Rice 5kg')),
              findsOneWidget);
          expect(qtyOf('Rice 5kg', 3), findsOneWidget);
          expect(find.text('1350.00'), findsOneWidget);
        });

    testWidgets('adding a new product creates a line', (tester) async {
      await openEditSale(tester);
      await tester.enterText(productSearchField(), 'Item 04');
      await pumpFor(tester, afterDebounce);

      await tester.tap(resultAddButton('Item 04'));
      await pumpFor(tester);

      expect(cardOf('Item 04'), findsOneWidget);
      expect(find.byType(CartItemCard), findsNWidgets(3));
    });

    testWidgets('out-of-stock result cannot be added', (tester) async {
      await openEditSale(tester);
      await tester.enterText(productSearchField(), 'Oil');
      await pumpFor(tester, afterDebounce);

      expect(find.textContaining(AppStrings.outOfStockLabel), findsOneWidget);
      expect(
        tester.widget<IconButton>(resultAddButton('Oil 1L')).onPressed,
        isNull,
      );
    });

    testWidgets('failed search shows Retry; Close clears it',
            (tester) async {
          await openEditSale(tester);
          repo.nextSearchError = const ApiException(message: 'Search down');
          await tester.enterText(productSearchField(), 'Ric');
          await pumpFor(tester, afterDebounce);

          expect(find.text('Search down'), findsOneWidget);
          await tester.tap(find.descendant(
            of: productResults,
            matching: find.text(AppStrings.retry),
          ));
          await pumpFor(tester);
          expect(resultAddButton('Rice 5kg'), findsOneWidget);

          await tester.tap(find.text(AppStrings.editSaleCloseResults));
          await pumpFor(tester);
          expect(productResults, findsNothing);
          expect(
            tester.widget<TextField>(productSearchField()).controller!.text,
            isEmpty,
          );
        });
  });

  // ─────────────────────────────── Scan logic (camera is manual)
  group('scan', () {
    testWidgets('known barcode adds; stock respected; unknown not found',
            (tester) async {
          await openEditSale(tester);
          final controller = editController(tester);

          final rice = await controller.handleScannedCode('8901');
          expect(rice?.outcome, ScanOutcome.added);

          final oil = await controller.handleScannedCode('8903');
          expect(oil?.outcome, ScanOutcome.outOfStock);

          final none = await controller.handleScannedCode('0000');
          expect(none?.outcome, ScanOutcome.notFound);

          await pumpFor(tester);
          expect(qtyOf('Rice 5kg', 3), findsOneWidget);
        });

    testWidgets('failed lookup returns null and clears scanning',
            (tester) async {
          await openEditSale(tester);
          repo.nextSearchError = const ApiException(message: 'down');

          final result = await editController(tester).handleScannedCode('8901');
          await pumpFor(tester);

          expect(result, isNull);
          expect(editState(tester).isScanning, isFalse);
        });
  });

  // ─────────────────────────────── Customer
  group('customer', () {
    testWidgets('pick another customer; discount re-checked',
            (tester) async {
          await openEditSale(tester);

          await reveal(tester, customerRowText('Rahim'));
          await tester.tap(customerRowText('Rahim'));
          await pumpFor(tester);
          expect(find.byType(EditSaleCustomerSearchSheet), findsOneWidget);

          await tester.tap(find.descendant(
            of: find.byType(ListTile),
            matching: find.text('Karim'),
          ));
          await pumpFor(tester);

          expect(customerRowText('Karim'), findsOneWidget);
          expect(cartRepo.discountCalls.last.customerId, 'C-2');
          expect(editState(tester).hasChanges, isTrue);
        });

    testWidgets('add a customer: created, selected, discount re-checked',
            (tester) async {
          await openEditSale(tester);

          final addIcon = find.byIcon(Icons.person_add_alt_1_outlined);
          await reveal(tester, addIcon);
          await tester.tap(addIcon);
          await pumpFor(tester);

          await tester.enterText(
            find.widgetWithText(TextFormField, AppStrings.customerNameHint),
            'Nasir',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, AppStrings.customerNumberHint),
            '01799999999',
          );
          await tester.tap(find.text(AppStrings.addCustomerTitle).last);
          await pumpFor(tester);

          expect(find.byType(EditSaleAddCustomerSheet), findsNothing);
          expect(find.text(AppStrings.customerAddedSuccessMessage('Nasir')),
              findsOneWidget);
          expect(customerRowText('Nasir'), findsOneWidget);
          expect(cartRepo.discountCalls.last.customerId, 'C-4');
        });
  });

  // ─────────────────────────────── Leaving
  group('leaving', () {
    testWidgets('no changes: Back leaves at once', (tester) async {
      await openEditSale(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await pumpFor(tester);

      expect(find.text(hostResult(null)), findsOneWidget);
    });

    testWidgets('unsaved changes: Back asks; Keep stays, Discard leaves',
            (tester) async {
          await openEditSale(tester);
          await tester.tap(stepButton('Rice 5kg', Icons.add));
          await pumpFor(tester);

          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await pumpFor(tester);
          expect(find.text(AppStrings.editSaleDiscardTitle), findsOneWidget);

          await tester.tap(find.text(AppStrings.editSaleKeepEditing));
          await pumpFor(tester);
          expect(qtyOf('Rice 5kg', 3), findsOneWidget);

          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await pumpFor(tester);
          await tester.tap(find.text(AppStrings.editSaleDiscardConfirm));
          await pumpFor(tester);

          expect(find.text(hostResult(null)), findsOneWidget);
        });

    testWidgets('saved in Payment: returns true, no discard prompt',
            (tester) async {
          await openEditSale(tester);
          await tester.tap(stepButton('Rice 5kg', Icons.add));
          await pumpFor(tester, afterDebounce);

          await reveal(tester, find.text(AppStrings.editSaleProceedAction));
          await tester.tap(find.text(AppStrings.editSaleProceedAction));
          await pumpFor(tester);
          await tester.tap(find.text(paymentSave));
          await pumpFor(tester);

          expect(find.text(AppStrings.editSaleDiscardTitle), findsNothing);
          expect(find.text(hostResult(true)), findsOneWidget);
        });

    testWidgets('back from Payment returns to the edited cart',
            (tester) async {
          await openEditSale(tester);
          await tester.tap(stepButton('Rice 5kg', Icons.add));
          await pumpFor(tester, afterDebounce);

          await reveal(tester, find.text(AppStrings.editSaleProceedAction));
          await tester.tap(find.text(AppStrings.editSaleProceedAction));
          await pumpFor(tester);
          await tester.tap(find.text(paymentBack));
          await pumpFor(tester);

          expect(qtyOf('Rice 5kg', 3), findsOneWidget);
        });
  });
}