import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/cart/data/repositories/cart_repository.dart';
import 'package:advance_pos_app/features/edit_sale_cart/data/repositories/edit_sale_cart_repository.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/controllers/edit_sale_cart_controller.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/screens/edit_sale_cart_screen.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/states/edit_sale_cart_state.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/widgets/edit_sale_product_results.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'edit_sale_fixtures.dart';

const editHostOpen = 'open-edit-sale';
const paymentSave = 'payment-save';
const paymentBack = 'payment-back';

/// Text the host shows with what Edit Sale returned ("result:true").
String hostResult(Object? value) => 'result:$value';

/// Opens Edit Sale the way Invoices does — push and await a bool —
/// with fake backends and a stub Payment screen.
Future<void> pumpEditSaleApp(
    WidgetTester tester, {
      required EditSaleCartRepository repository,
      required CartRepository cartRepository,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(path: '/host', builder: (_, _) => const _Host()),
      GoRoute(
        path: RouteNames.editSaleCart,
        builder: (_, state) =>
            EditSaleCartScreen(billNo: state.pathParameters['billNo']!),
      ),
      GoRoute(
        path: RouteNames.editSalePayment,
        builder: (context, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => context.pop(true),
                  child: const Text(paymentSave),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text(paymentBack),
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
        editSaleCartRepositoryProvider.overrideWithValue(repository),
        cartRepositoryProvider.overrideWithValue(cartRepository),
        apiParamsProvider.overrideWithValue(
          const ApiParams(branchId: 1, employeeId: 1, salesType: 1),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester);
  await tester.tap(find.text(editHostOpen));
  await pumpFor(tester);
}

/// Test-only launcher page.
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  Object? _result = 'none';

  Future<void> _open() async {
    final result =
    await context.push<bool>(RouteNames.editSaleCartPath(editBillNo));
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: _open, child: const Text(editHostOpen)),
          Text(hostResult(_result)),
        ],
      ),
    ),
  );
}

// ── State access ──

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(EditSaleCartScreen)));

EditSaleCartState editState(WidgetTester tester) =>
    _container(tester).read(editSaleCartControllerProvider(editBillNo));

EditSaleCartController editController(WidgetTester tester) => _container(tester)
    .read(editSaleCartControllerProvider(editBillNo).notifier);

// ── Finders ──

Finder get productResults => find.byType(EditSaleProductResults);

/// The "+" of one search-result row (cart lines also use Icons.add).
Finder resultAddButton(String name) => find.descendant(
  of: find
      .ancestor(
    of: find.descendant(of: productResults, matching: find.text(name)),
    matching: find.byType(Row),
  )
      .first,
  matching: find.byType(IconButton),
);

Finder productSearchField() => find.byType(TextField).first;