import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/bill_preview/data/repositories/bill_preview_repository.dart';
import 'package:advance_pos_app/features/cart/data/repositories/cart_repository.dart';
import 'package:advance_pos_app/features/edit_sale_cart/data/repositories/edit_sale_cart_repository.dart';
import 'package:advance_pos_app/features/edit_sale_cart/presentation/screens/edit_sale_cart_screen.dart';
import 'package:advance_pos_app/features/edit_sale_payment/data/repositories/edit_sale_payment_repository.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/controllers/edit_sale_payment_controller.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/screens/edit_sale_payment_screen.dart';
import 'package:advance_pos_app/features/edit_sale_payment/presentation/states/edit_sale_payment_state.dart';
import 'package:advance_pos_app/features/master_data/data/models/payment_accounts_model.dart'
as pa;
import 'package:advance_pos_app/features/master_data/presentation/controllers/master_data_controller.dart';
import 'package:advance_pos_app/features/master_data/presentation/states/master_data_state.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/payment_entry_card.dart';
import 'package:advance_pos_app/features/payment/presentation/widgets/payment_system_selector.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../cart/helpers/cart_test_host.dart' show reveal;
import '../../edit_sale_cart/helpers/edit_sale_fixtures.dart';
import '../../edit_sale_cart/helpers/edit_sale_test_host.dart'
    show editHostOpen, hostResult;
import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;

const newSaleStub = 'new-sale-stub';
const dashboardStub = 'dashboard-stub';

const _params = ApiParams(branchId: 1, employeeId: 1, salesType: 1);

/// Signed in (or not) without secure storage.
class FakeApiParamsController extends ApiParamsController {
  FakeApiParamsController(this.params);
  final ApiParams? params;

  @override
  ApiParams? build() => params;
}

/// Payment accounts only. [failFirst] starts in the error state;
/// refresh() then "loads" [accounts].
class FakePaymentMasterData extends MasterDataController {
  FakePaymentMasterData(this.accounts, {this.failFirst = false});

  final List<pa.ResultDatum> accounts;
  final bool failFirst;

  @override
  MasterDataState build() => failFirst
      ? const MasterDataState(errorMessage: 'Master data down')
      : MasterDataState(paymentAccounts: accounts);

  @override
  Future<bool> refresh() async {
    state = MasterDataState(paymentAccounts: accounts);
    return true;
  }
}

/// Host → Edit Sale cart (loaded). Call [goToPayment] next.
Future<void> pumpEditSalePaymentApp(
    WidgetTester tester, {
      required EditSaleCartRepository editRepository,
      required CartRepository cartRepository,
      required EditSalePaymentRepository paymentRepository,
      required BillPreviewRepository billRepository,
      required List<pa.ResultDatum> accounts,
      bool methodsFailFirst = false,
      bool signedIn = true,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(path: '/host', builder: (_, _) => const _FlowHost()),
      GoRoute(
        path: RouteNames.editSaleCart,
        builder: (_, state) =>
            EditSaleCartScreen(billNo: state.pathParameters['billNo']!),
      ),
      GoRoute(
        path: RouteNames.editSalePayment,
        builder: (_, state) =>
            EditSalePaymentScreen(billNo: state.pathParameters['billNo']!),
      ),
      GoRoute(
        path: RouteNames.newSale,
        builder: (_, _) => const Scaffold(body: Text(newSaleStub)),
      ),
      GoRoute(
        path: RouteNames.mainShell,
        builder: (_, _) => const Scaffold(body: Text(dashboardStub)),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        editSaleCartRepositoryProvider.overrideWithValue(editRepository),
        cartRepositoryProvider.overrideWithValue(cartRepository),
        editSalePaymentRepositoryProvider.overrideWithValue(paymentRepository),
        billPreviewRepositoryProvider.overrideWithValue(billRepository),
        // Edit Sale cart reads the branch from here...
        apiParamsProvider.overrideWithValue(_params),
        // ...while Update checks "signed in" here.
        apiParamsControllerProvider.overrideWith(
              () => FakeApiParamsController(signedIn ? _params : null),
        ),
        masterDataControllerProvider.overrideWith(
              () => FakePaymentMasterData(accounts, failFirst: methodsFailFirst),
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

/// From the loaded Edit Sale cart to the Payment screen.
Future<void> goToPayment(WidgetTester tester) async {
  await reveal(tester, find.text(AppStrings.editSaleProceedAction));
  await tester.tap(find.text(AppStrings.editSaleProceedAction));
  await pumpFor(tester);
}

class _FlowHost extends StatefulWidget {
  const _FlowHost();

  @override
  State<_FlowHost> createState() => _FlowHostState();
}

class _FlowHostState extends State<_FlowHost> {
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

EditSalePaymentState paymentState(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(EditSalePaymentScreen)),
    ).read(editSalePaymentControllerProvider(editBillNo));

// ── Finders ──

Finder systemChip(String name) => find.descendant(
  of: find.byType(PaymentSystemSelector),
  matching: find.text(name),
);

Finder entryCard(String name) => find.ancestor(
  of: find.descendant(
    of: find.byType(PaymentEntryCard),
    matching: find.text(name),
  ),
  matching: find.byType(PaymentEntryCard),
);

Finder amountField(String name) =>
    find.descendant(of: entryCard(name), matching: find.byType(TextField));

Finder accountDropdown(String name) => find.descendant(
  of: entryCard(name),
  matching: find.byType(DropdownButton<int>),
);

/// The bottom "Update Sale" button (the confirm dialog reuses the text).
Finder get updateButton => find.text(AppStrings.editSaleUpdateAction).first;