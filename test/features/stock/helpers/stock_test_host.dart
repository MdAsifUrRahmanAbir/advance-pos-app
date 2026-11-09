import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/core/widgets/common/scan_search_bar.dart';
import 'package:advance_pos_app/core/widgets/common/searchable_dropdown_field.dart';
import 'package:advance_pos_app/features/master_data/presentation/controllers/master_data_controller.dart';
import 'package:advance_pos_app/features/master_data/presentation/states/master_data_state.dart';
import 'package:advance_pos_app/features/stock/data/repositories/stock_repository.dart';
import 'package:advance_pos_app/features/stock/presentation/controllers/stock_controller.dart';
import 'package:advance_pos_app/features/stock/presentation/screens/stock_screen.dart';
import 'package:advance_pos_app/features/stock/presentation/widgets/stock_card_tile.dart';

import '../../home/helpers/home_test_host.dart' show FakeApiParamsController;
import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'fake_stock_repository.dart';
import 'stock_fixtures.dart';

class FakeStockMasterData extends MasterDataController {
  @override
  MasterDataState build() => MasterDataState(
    categoryData: sampleCategoryData(),
    groups: sampleGroups(),
    subcategories: sampleSubcategories(),
    brands: sampleBrands(),
  );
}

/// Opens Stock for branch [stockBranchId] and waits for the first page
/// and its card animations.
Future<void> pumpStockApp(
    WidgetTester tester, {
      required FakeStockRepository repository,
    }) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        stockRepositoryProvider.overrideWithValue(repository),
        apiParamsControllerProvider
            .overrideWith(() => FakeApiParamsController(stockBranchId)),
        masterDataControllerProvider.overrideWith(FakeStockMasterData.new),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const StockScreen(),
      ),
    ),
  );
  await pumpFor(tester);
}

StockController stockController(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(StockScreen)))
        .read(stockControllerProvider.notifier);

// ── Finders ──

Finder cardOf(String name) => find.ancestor(
  of: find.text(name),
  matching: find.byType(StockCardTile),
);

Finder inCard(String name, Finder matching) =>
    find.descendant(of: cardOf(name), matching: matching);

Finder get searchField => find.descendant(
  of: find.byType(ScanSearchBar),
  matching: find.byType(TextField),
);

Finder chip(String label) => find.widgetWithText(FilterChip, label);

Finder get stockList => find
    .descendant(
  of: find.byType(RefreshIndicator),
  matching: find.byType(Scrollable),
)
    .first;

/// Tappable box of the drawer's [label] dropdown.
Finder dropdownBox(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(SearchableDropdownField<int>),
  ),
  matching: find.byType(InkWell),
);

/// Option [label] in an open dropdown sheet.
Finder sheetOption(String label) => find
    .descendant(of: find.byType(ListTile), matching: find.text(label))
    .last;

/// Drags the list up until [finder] is built (or [maxDrags] runs out).
Future<void> scrollUntil(
    WidgetTester tester,
    Finder finder, {
      int maxDrags = 25,
    }) async {
  for (var i = 0; i < maxDrags && finder.evaluate().isEmpty; i++) {
    await tester.drag(stockList, const Offset(0, -400));
    await pumpFor(tester, const Duration(milliseconds: 400));
  }
}

Future<void> pumpFrames(WidgetTester tester, [int count = 20]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}