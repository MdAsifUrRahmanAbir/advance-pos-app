import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/expense/data/repositories/expense_repository.dart';
import 'package:advance_pos_app/features/expense/presentation/controllers/expense_controller.dart';
import 'package:advance_pos_app/features/expense/presentation/screens/expense_screen.dart';
import 'package:advance_pos_app/features/expense/presentation/states/expense_state.dart';
import 'package:advance_pos_app/features/expense/presentation/widgets/expense_list_item.dart';
import 'package:advance_pos_app/features/master_data/presentation/controllers/master_data_controller.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../edit_sale_payment/helpers/edit_sale_payment_test_host.dart'
    show FakePaymentMasterData;
import '../../edit_sale_payment/helpers/payment_fixtures.dart';
import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;

const expenseHostOpen = 'open-expense';
const formSave = 'form-save';
const formCancel = 'form-cancel';

/// Text the form stub shows: which expense it was opened for.
String formOpenedFor(String? expenseNo) => 'form:${expenseNo ?? 'new'}';

/// ExpenseController waits this long before searching (400 ms).
const afterDebounce = Duration(milliseconds: 600);

/// Opens the real ExpenseScreen from a host page, with a fake backend,
/// master-data payment accounts and a stub add/edit form.
Future<void> pumpExpenseApp(
    WidgetTester tester, {
      required ExpenseRepository repository,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.expense),
              child: const Text(expenseHostOpen),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.expense,
        builder: (_, _) => const ExpenseScreen(),
      ),
      GoRoute(
        path: RouteNames.expenseForm,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formOpenedFor(state.extra as String?)),
                ElevatedButton(
                  onPressed: () => context.pop(true),
                  child: const Text(formSave),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text(formCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
        masterDataControllerProvider
            .overrideWith(() => FakePaymentMasterData(sampleAccounts())),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester);
  await tester.tap(find.text(expenseHostOpen));
  await pumpFor(tester);
}

/// On a device one long pump is one frame; pull-to-refresh and other
/// multi-step animations need a frame per step.
Future<void> pumpFrames(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ── State access ──

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ExpenseScreen)));

ExpenseState expenseState(WidgetTester tester) =>
    _container(tester).read(expenseControllerProvider);

ExpenseController expenseController(WidgetTester tester) =>
    _container(tester).read(expenseControllerProvider.notifier);

// ── Finders ──

Finder rowOf(String expenseNo) => find.ancestor(
  of: find.text(expenseNo),
  matching: find.byType(ExpenseListItem),
);

Finder rowMenu(String expenseNo) => find.descendant(
  of: rowOf(expenseNo),
  matching: find.byIcon(Icons.more_vert_rounded),
);

Finder expenseList() => find
    .ancestor(of: find.byType(ExpenseListItem).first, matching: find.byType(Scrollable))
    .first;