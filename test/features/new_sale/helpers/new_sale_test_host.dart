import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/master_data/data/models/category_model.dart';
import 'package:advance_pos_app/features/master_data/presentation/controllers/master_data_controller.dart';
import 'package:advance_pos_app/features/master_data/presentation/states/master_data_state.dart';
import 'package:advance_pos_app/features/new_sale/data/repositories/new_sale_repository.dart';
import 'package:advance_pos_app/features/new_sale/presentation/controllers/new_sale_controller.dart';
import 'package:advance_pos_app/features/new_sale/presentation/screens/new_sale_screen.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart';
import 'package:advance_pos_app/features/new_sale/presentation/widgets/cart_review_sheet.dart';
import 'package:advance_pos_app/features/new_sale/presentation/widgets/cart_summary_bar.dart';
import 'package:advance_pos_app/features/new_sale/presentation/widgets/product_grid_card.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'new_sale_fixtures.dart';

const newSaleHostOpen = 'open-new-sale';
const newSaleCartStub = 'cart-stub';

/// NewSaleController waits this long before searching (400 ms).
const afterDebounce = Duration(milliseconds: 600);

/// Master data with only categories filled in — no API, no login.
class FakeMasterDataController extends MasterDataController {
  FakeMasterDataController(this.topCategories);

  final List<TopCategory> topCategories;

  @override
  MasterDataState build() => MasterDataState(
    categoryData: CategoryResultData(
      branch: Branch(branchId: 1, branchName: 'Dhanmondi'),
      topCategories: topCategories,
      categories: const [],
    ),
  );
}

/// Opens the real NewSaleScreen from a host page, signed in to branch 1,
/// with a fake catalog.
Future<void> pumpNewSaleApp(
    WidgetTester tester, {
      required NewSaleRepository repository,
      List<TopCategory>? topCategories,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.newSale),
              child: const Text(newSaleHostOpen),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.newSale,
        builder: (_, _) => const NewSaleScreen(),
      ),
      GoRoute(
        path: RouteNames.cart,
        builder: (_, _) => const Scaffold(body: Text(newSaleCartStub)),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        newSaleRepositoryProvider.overrideWithValue(repository),
        apiParamsProvider.overrideWithValue(
          const ApiParams(branchId: 1, employeeId: 1, salesType: 1),
        ),
        masterDataControllerProvider.overrideWith(
              () => FakeMasterDataController(
            topCategories ?? sampleTopCategories(),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester);
  await tester.tap(find.text(newSaleHostOpen));
  await pumpFor(tester);
}

// ── State access ──

NewSaleController newSaleController(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(NewSaleScreen)))
        .read(newSaleControllerProvider.notifier);

NewSaleState newSaleState(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(NewSaleScreen)))
        .read(newSaleControllerProvider);

// ── Finders ──

Finder productCard(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(ProductGridCard));

Finder addButton(String name) =>
    find.descendant(of: productCard(name), matching: find.byIcon(Icons.add));

/// The page list. The grid inside it is a non-scrolling Scrollable;
/// ancestors are nearest-first, so `.last` is the outer list.
Finder productList() => find
    .ancestor(of: find.text('Rice 5kg'), matching: find.byType(Scrollable))
    .last;

Finder get cartBar => find.byType(CartSummaryBar);

Finder cartBarCount(int count) =>
    find.descendant(of: cartBar, matching: find.text('$count'));

Finder get reviewSheet => find.byType(CartReviewSheet);

/// A line's stepper button inside the review sheet.
Finder reviewStep(String name, IconData icon) => find.descendant(
  of: find
      .ancestor(
    of: find.descendant(of: reviewSheet, matching: find.text(name)),
    matching: find.byType(Row),
  )
      .first,
  matching: find.byIcon(icon),
);