import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/customers/data/repositories/customers_repository.dart';
import 'package:advance_pos_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:advance_pos_app/features/customers/presentation/widgets/customer_card_item.dart';
import 'package:advance_pos_app/features/customers/presentation/widgets/customer_detail_sheet.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;

const customersHostOpen = 'open-customers';

/// CustomersController waits this long before searching (400 ms).
const afterDebounce = Duration(milliseconds: 600);

/// Opens the real CustomersScreen from a host page (so Back has
/// somewhere to go) with a fake backend.
Future<void> pumpCustomersApp(
    WidgetTester tester, {
      required CustomersRepository repository,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.customers),
              child: const Text(customersHostOpen),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.customers,
        builder: (_, _) => const CustomersScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [customersRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester);
  await tester.tap(find.text(customersHostOpen));
  await pumpFor(tester);
}

// ── Finders ──

Finder customerCard(String name) => find.ancestor(
  of: find.text(name),
  matching: find.byType(CustomerCardItem),
);

Finder inCard(String name, Finder matching) =>
    find.descendant(of: customerCard(name), matching: matching);

Finder get detailSheet => find.byType(CustomerDetailSheet);

Finder inDetail(Finder matching) =>
    find.descendant(of: detailSheet, matching: matching);

/// The page list. The mobile view nests a non-scrolling list inside it;
/// ancestors are nearest-first, so `.last` is the outer one.
Finder customerList() => find
    .ancestor(of: find.text('Rahim'), matching: find.byType(Scrollable))
    .last;

Finder searchField() => find.byType(TextField).first;