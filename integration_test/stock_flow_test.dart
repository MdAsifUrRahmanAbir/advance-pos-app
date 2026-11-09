import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/empty_state.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/stock/presentation/states/stock_filter.dart';
import 'package:advance_pos_app/features/stock/presentation/widgets/stock_card_tile.dart';
import 'package:advance_pos_app/features/stock/presentation/widgets/stock_detail_sheet.dart';
import 'package:advance_pos_app/features/stock/presentation/widgets/stock_list_skeleton.dart';

import '../test/features/invoices/helpers/invoice_test_harness.dart'
    show pumpFor, seedApiParams;
import '../test/features/stock/helpers/fake_stock_repository.dart';
import '../test/features/stock/helpers/stock_fixtures.dart';
import '../test/features/stock/helpers/stock_test_host.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeStockRepository repo;

  // Error details build the endpoint URL from the static ApiParams.current.
  setUpAll(() => seedApiParams(branchId: stockBranchId));

  setUp(() => repo = FakeStockRepository());

  Future<void> openStock(WidgetTester tester) =>
      pumpStockApp(tester, repository: repo);

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.filter_alt_sharp));
    await pumpFor(tester);
  }

  Future<void> pick(WidgetTester tester, String field, String option) async {
    await tester.tap(dropdownBox(field));
    await pumpFor(tester);
    await tester.tap(sheetOption(option));
    await pumpFor(tester);
  }

  // ─────────────────────────────── Loading
  group('loading', () {
    testWidgets('skeleton, then the first page of 15', (tester) async {
      repo.gate = Completer<void>();
      final gate = repo.gate!;
      await openStock(tester);

      expect(find.byType(StockListSkeleton), findsOneWidget);

      gate.complete();
      await pumpFor(tester);

      expect(find.byType(StockListSkeleton), findsNothing);
      expect(cardOf(productName(1)), findsOneWidget);
      final call = repo.calls.single;
      expect(call.start, 0);
      expect(call.length, 15);
      expect(call.search, isEmpty);
      expect(call.categoryId, isNull);
    });

    testWidgets('quantity is this branch\'s, not the first listed',
            (tester) async {
          await openStock(tester);

          expect(inCard(productName(1), find.text('${branchQty(1)} pcs')),
              findsOneWidget);
          expect(inCard(productName(1), find.text(AppStrings.stockStatusInStock)),
              findsOneWidget);
        });

    testWidgets('no barcode: system barcode shown', (tester) async {
      await openStock(tester);

      expect(
        inCard(productName(2),
            find.text('${AppStrings.stockBarcodePrefix}SYS-02')),
        findsOneWidget,
      );
    });

    testWidgets('zero stock is Out of Stock', (tester) async {
      await openStock(tester);
      await scrollUntil(tester, cardOf(productName(5)));

      expect(inCard(productName(5), find.text('0 pcs')), findsOneWidget);
      expect(
          inCard(productName(5), find.text(AppStrings.stockStatusOutOfStock)),
          findsOneWidget);
    });

    testWidgets('first load fails: error, details link, Retry loads',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await openStock(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);
          expect(find.text('View technical details'), findsOneWidget);

          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);

          expect(find.byType(ErrorState), findsNothing);
          expect(cardOf(productName(1)), findsOneWidget);
        });

    testWidgets('nothing in stock list: empty state', (tester) async {
      repo.catalog = [];
      await openStock(tester);

      expect(find.byType(EmptyState), findsOneWidget);
    });
  });

  // ─────────────────────────────── Paging and refresh
  group('paging', () {
    testWidgets('scrolling to the end loads the next 5, then stops',
            (tester) async {
          await openStock(tester);
          expect(find.byType(StockCardTile), findsWidgets);

          await scrollUntil(tester, cardOf(productName(20)));

          expect(cardOf(productName(20)), findsOneWidget);
          expect(repo.calls, hasLength(2));
          expect(repo.calls[1].start, 15);

          // hasMore is false now: more scrolling sends nothing.
          await tester.drag(stockList, const Offset(0, -400));
          await pumpFor(tester);
          expect(repo.calls, hasLength(2));
        });

    testWidgets('pull-to-refresh reloads page one', (tester) async {
      await openStock(tester);

      await tester.fling(stockList, const Offset(0, 400), 1000);
      await pumpFrames(tester);
      await pumpFor(tester);

      expect(repo.calls, hasLength(2));
      expect(repo.lastCall.start, 0);
      expect(cardOf(productName(1)), findsOneWidget);
    });
  });

  // ─────────────────────────────── Search
  group('search', () {
    testWidgets('under 4 characters sends nothing', (tester) async {
      await openStock(tester);

      await tester.enterText(searchField, 'Pro');
      await pumpFor(tester);

      expect(repo.calls, hasLength(1));
      expect(cardOf(productName(1)), findsOneWidget); // old list stays
    });

    testWidgets('fast typing is debounced into one request',
            (tester) async {
          await openStock(tester);
          final controller = stockController(tester);

          // Three keystrokes with no real time between them (on a device,
          // enterText alone can take longer than the 400 ms debounce).
          controller.updateSearchQuery('Prod');
          controller.updateSearchQuery('Produ');
          controller.updateSearchQuery(productName(7));
          expect(repo.calls, hasLength(1)); // nothing sent yet

          await pumpFor(tester); // > 400 ms
          await pumpFor(tester);

          expect(repo.calls, hasLength(2));
          expect(repo.lastCall.search, productName(7));
          expect(find.text(productName(7)), findsWidgets); // field + card
          expect(find.byType(StockCardTile), findsOneWidget);
          expect(cardOf(productName(7)), findsOneWidget);
        });

    testWidgets('typing in the field searches after the debounce',
            (tester) async {
          await openStock(tester);

          await tester.enterText(searchField, productName(7));
          await pumpFor(tester);
          await pumpFor(tester);

          expect(repo.calls, hasLength(2));
          expect(repo.lastCall.search, productName(7));
          expect(cardOf(productName(7)), findsOneWidget);
        });

    testWidgets('clearing the search reloads everything at once',
            (tester) async {
          await openStock(tester);
          await tester.enterText(searchField, productName(7));
          await pumpFor(tester);
          await pumpFor(tester);

          await tester.enterText(searchField, '');
          await pumpFor(tester, const Duration(milliseconds: 100));

          expect(repo.lastCall.search, isEmpty);
          await pumpFor(tester);
          expect(cardOf(productName(1)), findsOneWidget);
        });

    testWidgets('a search clears the drawer filter', (tester) async {
      await openStock(tester);
      await openDrawer(tester);
      await pick(tester, 'Category', 'Beverages');
      await tester.tap(find.text('Apply'));
      await pumpFor(tester);
      expect(repo.lastCall.categoryId, beveragesId);

      await tester.enterText(searchField, productName(8)); // a Snack
      await pumpFor(tester);
      await pumpFor(tester);

      expect(repo.lastCall.categoryId, isNull);
      expect(cardOf(productName(8)), findsOneWidget);
    });
  });

  // ─────────────────────────────── Filters
  group('filters', () {
    testWidgets('Out of Stock tab filters loaded items, no request',
            (tester) async {
          await openStock(tester);

          await tester.tap(chip(AppStrings.stockStatusOutOfStock));
          await pumpFor(tester);

          // First page holds products 1–15: out of stock are 5, 10, 15.
          expect(find.byType(StockCardTile), findsNWidgets(3));
          expect(cardOf(productName(5)), findsOneWidget);
          expect(cardOf(productName(1)), findsNothing);
          expect(repo.calls, hasLength(1));

          await tester.tap(chip(AppStrings.filterAll));
          await pumpFor(tester);
          expect(cardOf(productName(1)), findsOneWidget);
          expect(repo.calls, hasLength(1));
        });

    testWidgets('top category chip loads that category; All clears it',
            (tester) async {
          await openStock(tester);

          await tester.tap(chip('Beverages'));
          await pumpFor(tester);

          expect(repo.lastCall.categoryId, beveragesId);
          expect(cardOf(productName(1)), findsOneWidget);
          expect(cardOf(productName(2)), findsNothing);

          await tester.tap(chip(AppStrings.filterAll));
          await pumpFor(tester);

          expect(repo.lastCall.categoryId, isNull);
          expect(cardOf(productName(2)), findsOneWidget);
        });

    testWidgets('status tab after a category: one reload to clear it',
            (tester) async {
          await openStock(tester);
          await tester.tap(chip('Beverages'));
          await pumpFor(tester);
          expect(repo.calls, hasLength(2));

          await tester.tap(chip(AppStrings.stockStatusOutOfStock));
          await pumpFor(tester);

          expect(repo.calls, hasLength(3));
          expect(repo.lastCall.categoryId, isNull);
          // Unfiltered first page, out of stock only: 5, 10, 15.
          expect(find.byType(StockCardTile), findsNWidgets(3));
        });

    testWidgets('drawer: Apply sends the filter, Reset clears it',
            (tester) async {
          await openStock(tester);
          await openDrawer(tester);
          expect(find.text('Filter Stock'), findsOneWidget);

          await pick(tester, 'Category', 'Snacks');
          await tester.tap(find.text('Apply'));
          await pumpFor(tester);

          expect(find.text('Filter Stock'), findsNothing); // drawer closed
          expect(repo.lastCall.categoryId, snacksId);
          expect(cardOf(productName(1)), findsNothing);
          expect(cardOf(productName(2)), findsOneWidget);

          await openDrawer(tester);
          await tester.tap(find.text('Reset'));
          await pumpFor(tester);

          expect(repo.lastCall.categoryId, isNull);
          expect(cardOf(productName(1)), findsOneWidget);
        });

    testWidgets('drawer: subcategories follow the chosen category',
            (tester) async {
          await openStock(tester);
          await openDrawer(tester);
          await pick(tester, 'Category', 'Beverages');

          await tester.tap(dropdownBox('Subcategory'));
          await pumpFor(tester);

          expect(sheetOption('Soft Drinks'), findsOneWidget);
          expect(find.text('Chips'), findsNothing);

          await tester.tap(sheetOption('Soft Drinks'));
          await pumpFor(tester);
          await tester.tap(find.text('Apply'));
          await pumpFor(tester);

          expect(repo.lastCall.categoryId, beveragesId);
          expect(repo.lastCall.subCategoryId, 51);
        });
  });

  // ─────────────────────────────── Details and scan
  group('details', () {
    testWidgets('Show Info opens the detail sheet', (tester) async {
      await openStock(tester);

      await tester.tap(inCard(productName(1), find.text(AppStrings.showInfo)));
      await pumpFor(tester);

      final sheet = find.byType(StockDetailSheet);
      expect(sheet, findsOneWidget);
      expect(find.descendant(of: sheet, matching: find.text(productName(1))),
          findsOneWidget);
      expect(find.descendant(of: sheet, matching: find.text('SKU-01')),
          findsOneWidget);
      expect(
          find.descendant(
              of: sheet, matching: find.text(AppStrings.stockOutOfStockNote)),
          findsNothing);
    });

    testWidgets('out-of-stock product shows the warning note',
            (tester) async {
          await openStock(tester);
          await scrollUntil(tester, cardOf(productName(5)));
          await Scrollable.ensureVisible(
              tester.element(cardOf(productName(5))), alignment: 0.5);
          await pumpFor(tester);

          await tester.tap(inCard(productName(5), find.text(AppStrings.showInfo)));
          await pumpFor(tester);

          expect(find.text(AppStrings.stockOutOfStockNote), findsOneWidget);
        });

    testWidgets('scanned code: searches at once and returns the match',
            (tester) async {
          await openStock(tester);

          final match = await stockController(tester).handleScannedCode('BC-07');
          await pumpFor(tester);

          expect(match?.name, productName(7));
          expect(repo.lastCall.search, 'BC-07');
          expect(find.text('BC-07'), findsOneWidget); // search field filled
          expect(cardOf(productName(7)), findsOneWidget);
        });

    testWidgets('unknown scanned code returns null', (tester) async {
      await openStock(tester);

      final match = await stockController(tester).handleScannedCode('NOPE');
      await pumpFor(tester);

      expect(match, isNull);
    });
  });

  // ─────────────────────────────── Stale responses
  testWidgets('a slower older filter response is ignored', (tester) async {
    await openStock(tester);
    final controller = stockController(tester);

    repo.gate = Completer<void>();
    final slow = repo.gate!;
    final older = controller.applyFilter(
        const StockFilter(categoryId: beveragesId)); // held
    await controller.applyFilter(const StockFilter(categoryId: snacksId));
    await pumpFor(tester);
    expect(cardOf(productName(2)), findsOneWidget);

    slow.complete();
    await older;
    await pumpFor(tester);

    expect(cardOf(productName(2)), findsOneWidget);
    expect(cardOf(productName(1)), findsNothing);
  });
}