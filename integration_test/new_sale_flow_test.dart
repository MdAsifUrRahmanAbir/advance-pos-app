import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/empty_state.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart';
import 'package:advance_pos_app/features/new_sale/presentation/widgets/product_grid_card.dart';
import 'package:advance_pos_app/features/new_sale/presentation/widgets/product_grid_skeleton.dart';

import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;
import '../test/features/new_sale/helpers/fake_new_sale_repository.dart';
import '../test/features/new_sale/helpers/new_sale_fixtures.dart';
import '../test/features/new_sale/helpers/new_sale_test_host.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeNewSaleRepository repo;

  setUp(() => repo = FakeNewSaleRepository());

  Future<void> openNewSale(WidgetTester tester) =>
      pumpNewSaleApp(tester, repository: repo);

  Finder searchField() => find.byType(TextField).first;

  // ─────────────────────────────── Catalog
  group('catalog', () {
    testWidgets('skeleton, then products with branch stock and price',
            (tester) async {
          repo.gate = Completer<void>();
          final gate = repo.gate!;
          await openNewSale(tester);

          expect(find.byType(ProductGridSkeleton), findsOneWidget);

          gate.complete();
          await pumpFor(tester);

          expect(find.byType(ProductGridSkeleton), findsNothing);
          expect(find.text('Rice 5kg'), findsOneWidget);
          expect(find.text(AppStrings.skuLabel('R5')), findsOneWidget);
          // Branch 1 has 5; branch 2's 50 must not show.
          expect(
            find.descendant(
              of: productCard('Rice 5kg'),
              matching: find.text(AppStrings.stockPcsLabel(5)),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: productCard('Rice 5kg'),
              matching: find.text('450.00'),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: productCard('Oil 1L'),
              matching: find.text(AppStrings.outOfStockLabel),
            ),
            findsOneWidget,
          );

          final first = repo.calls.single;
          expect(first.start, 0);
          expect(first.length, 20);
          expect(first.search, '');
          expect(first.categoryId, isNull);
        });

    testWidgets('scrolling down loads the next page', (tester) async {
      await openNewSale(tester);
      expect(find.byType(ProductGridCard), findsNWidgets(20));

      await tester.scrollUntilVisible(
        find.text(fillerName(25)),
        400,
        scrollable: productList(),
      );
      await pumpFor(tester);

      expect(find.text(fillerName(25)), findsOneWidget);
      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.start, 20);
    });

    testWidgets('search waits for 3 characters and the debounce',
            (tester) async {
          await openNewSale(tester);

          await tester.enterText(searchField(), 'Ri');
          await pumpFor(tester, afterDebounce);
          expect(repo.calls, hasLength(1)); // too short

          await tester.enterText(searchField(), 'Ric');
          await tester.pump(const Duration(milliseconds: 200));
          expect(repo.calls, hasLength(1)); // still debouncing
          await pumpFor(tester, afterDebounce);

          expect(repo.calls.last.search, 'Ric');
          expect(find.byType(ProductGridCard), findsOneWidget);
          expect(find.text('Rice 5kg'), findsOneWidget);

          await tester.enterText(searchField(), '');
          await pumpFor(tester);
          expect(repo.calls.last.search, '');
          expect(find.byType(ProductGridCard), findsNWidgets(20));
        });

    testWidgets('category chip filters on the server; All clears it',
            (tester) async {
          await openNewSale(tester);

          await tester.tap(find.text('Toiletries'));
          await pumpFor(tester);
          expect(repo.calls.last.categoryId, toiletriesId);
          expect(find.byType(ProductGridCard), findsOneWidget);
          expect(find.text('Soap'), findsOneWidget);

          await tester.tap(find.text(AppStrings.filterAll));
          await pumpFor(tester);
          expect(repo.calls.last.categoryId, isNull);
          expect(find.byType(ProductGridCard), findsNWidgets(20));
        });

    testWidgets('failed first load shows ErrorState; Retry recovers',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await openNewSale(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);

          await tester.tap(find.descendant(
            of: find.byType(ErrorState),
            matching: find.byType(OutlinedButton),
          ));
          await pumpFor(tester);
          expect(find.text('Rice 5kg'), findsOneWidget);
        });

    testWidgets('no products shows the empty state', (tester) async {
      repo = FakeNewSaleRepository(const []);
      await openNewSale(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(AppStrings.newSaleEmptyMessage), findsOneWidget);
    });

    testWidgets('pull to refresh reloads page 1', (tester) async {
      await openNewSale(tester);
      final before = repo.calls.length;

      await tester.fling(productList(), const Offset(0, 400), 1000);
      await pumpFor(tester, const Duration(seconds: 2));

      expect(repo.calls.length, greaterThan(before));
      expect(repo.calls.last.start, 0);
    });
  });

  // ─────────────────────────────── Add to cart
  group('add to cart', () {
    testWidgets('+ adds to the cart bar; again increases it',
            (tester) async {
          await openNewSale(tester);
          expect(cartBar, findsNothing);

          await tester.tap(addButton('Rice 5kg'));
          await pumpFor(tester);
          expect(cartBarCount(1), findsOneWidget);
          expect(find.text(AppStrings.viewCartLabel('450.00')), findsOneWidget);

          await tester.tap(addButton('Rice 5kg'));
          await pumpFor(tester);
          expect(cartBarCount(2), findsOneWidget);
          expect(find.text(AppStrings.viewCartLabel('900.00')), findsOneWidget);
        });

    testWidgets('out-of-stock product cannot be added', (tester) async {
      await openNewSale(tester);

      await tester.tap(addButton('Oil 1L'), warnIfMissed: false);
      await pumpFor(tester);

      expect(cartBar, findsNothing);
      expect(newSaleState(tester).cartItems, isEmpty);
    });

    testWidgets('adding past stock shows a message and stops',
            (tester) async {
          await openNewSale(tester);

          for (var i = 0; i < 3; i++) {
            await tester.tap(addButton('Soap')); // stock 2
            await pumpFor(tester);
          }

          expect(cartBarCount(2), findsOneWidget);
          expect(find.text(AppStrings.productOutOfStockMessage('Soap')),
              findsOneWidget);
        });
  });

  // ─────────────────────────────── Cart review sheet
  group('cart review sheet', () {
    Future<void> openReview(WidgetTester tester) async {
      await tester.tap(cartBar);
      await pumpFor(tester);
    }

    testWidgets('lists lines; steppers update count and total',
            (tester) async {
          await openNewSale(tester);
          await tester.tap(addButton('Rice 5kg'));
          await pumpFor(tester);
          await tester.tap(addButton('Soap'));
          await pumpFor(tester);

          await openReview(tester);
          expect(find.text('Cart (2)'), findsOneWidget);
          expect(find.descendant(of: reviewSheet, matching: find.text('495.00')),
              findsOneWidget);

          await tester.tap(reviewStep('Rice 5kg', Icons.add_rounded));
          await pumpFor(tester);
          expect(find.text('Cart (3)'), findsOneWidget);
          expect(find.descendant(of: reviewSheet, matching: find.text('945.00')),
              findsOneWidget);
          expect(cartBarCount(3), findsOneWidget); // bar updates live

          await tester.tap(reviewStep('Soap', Icons.remove_rounded));
          await pumpFor(tester);
          expect(find.descendant(of: reviewSheet, matching: find.text('Soap')),
              findsNothing);
        });

    testWidgets('removing the last line empties the cart', (tester) async {
      await openNewSale(tester);
      await tester.tap(addButton('Soap'));
      await pumpFor(tester);

      await openReview(tester);
      await tester.tap(reviewStep('Soap', Icons.remove_rounded));
      await pumpFor(tester);

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(newSaleState(tester).cartItems, isEmpty);
    });

    testWidgets('Next closes the sheet and opens the Cart', (tester) async {
      await openNewSale(tester);
      await tester.tap(addButton('Rice 5kg'));
      await pumpFor(tester);

      await openReview(tester);
      await tester.tap(find.text('Next'));
      await pumpFor(tester);

      expect(reviewSheet, findsNothing);
      expect(find.text(newSaleCartStub), findsOneWidget);
    });
  });

  // ─────────────────────────────── Scan logic (camera is manual)
  group('scan', () {
    testWidgets('known barcode is added to the cart', (tester) async {
      await openNewSale(tester);

      final result = await newSaleController(tester).handleScannedCode('8902');
      await pumpFor(tester);

      expect(result.outcome, ScanOutcome.added);
      expect(result.product?.name, 'Soap');
      expect(repo.calls.last.search, '8902');
      expect(cartBarCount(1), findsOneWidget);
    });

    testWidgets('scanning past stock reports outOfStock', (tester) async {
      await openNewSale(tester);
      final controller = newSaleController(tester);

      await controller.handleScannedCode('8902');
      await controller.handleScannedCode('8902');
      final third = await controller.handleScannedCode('8902');
      await pumpFor(tester);

      expect(third.outcome, ScanOutcome.outOfStock);
      expect(newSaleState(tester).cartItemCount, 2);
    });

    testWidgets('out-of-stock barcode is not added', (tester) async {
      await openNewSale(tester);

      final result = await newSaleController(tester).handleScannedCode('8903');
      await pumpFor(tester);

      expect(result.outcome, ScanOutcome.outOfStock);
      expect(cartBar, findsNothing);
    });

    testWidgets('unknown barcode reports notFound', (tester) async {
      await openNewSale(tester);

      final result = await newSaleController(tester).handleScannedCode('0000');
      await pumpFor(tester);

      expect(result.outcome, ScanOutcome.notFound);
      expect(newSaleState(tester).cartItems, isEmpty);
    });
  });

  // ─────────────────────────────── Navigation
  testWidgets('Back returns to the previous screen', (tester) async {
    await openNewSale(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await pumpFor(tester);

    expect(find.text(newSaleHostOpen), findsOneWidget);
  });
}