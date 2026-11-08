import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/core/widgets/common/primary_button.dart';
import 'package:advance_pos_app/features/bill_preview/data/repositories/bill_preview_repository.dart';
import 'package:advance_pos_app/features/cart/data/repositories/cart_repository.dart';
import 'package:advance_pos_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:advance_pos_app/features/master_data/data/models/payment_accounts_model.dart'
as pa;
import 'package:advance_pos_app/features/master_data/presentation/controllers/master_data_controller.dart';
import 'package:advance_pos_app/features/new_sale/presentation/controllers/new_sale_controller.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart';
import 'package:advance_pos_app/features/payment/data/repositories/payment_repository.dart';
import 'package:advance_pos_app/features/payment/presentation/controllers/payment_controller.dart';
import 'package:advance_pos_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:advance_pos_app/features/payment/presentation/states/payment_state.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../cart/helpers/cart_fixtures.dart';
import '../../cart/helpers/cart_test_host.dart' show reveal;
import '../../cart/helpers/seeded_new_sale_controller.dart';
import '../../edit_sale_payment/helpers/edit_sale_payment_test_host.dart'
    show FakePaymentMasterData, dashboardStub, newSaleStub;
import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;

const paymentHostOpen = 'open-cart-flow';

/// Host → Cart (seeded with Rice ×2 + Soap ×2 = 990.00). Call
/// [goToPaymentFromCart] next.
Future<void> pumpPaymentFlowApp(
    WidgetTester tester, {
      required CartRepository cartRepository,
      required PaymentRepository paymentRepository,
      required BillPreviewRepository billRepository,
      required List<pa.ResultDatum> accounts,
      bool methodsFailFirst = false,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.cart),
              child: const Text(paymentHostOpen),
            ),
          ),
        ),
      ),
      GoRoute(path: RouteNames.cart, builder: (_, _) => const CartScreen()),
      GoRoute(
        path: RouteNames.payment,
        builder: (_, _) => const PaymentScreen(),
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
        cartRepositoryProvider.overrideWithValue(cartRepository),
        paymentRepositoryProvider.overrideWithValue(paymentRepository),
        billPreviewRepositoryProvider.overrideWithValue(billRepository),
        newSaleControllerProvider
            .overrideWith(() => SeededNewSaleController(sampleCart())),
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
  await tester.tap(find.text(paymentHostOpen));
  await pumpFor(tester);
}

Future<void> goToPaymentFromCart(WidgetTester tester) async {
  await reveal(tester, find.text(AppStrings.proceedToPaymentAction));
  await tester.tap(find.text(AppStrings.proceedToPaymentAction));
  await pumpFor(tester);
}

// ── State access ──

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PaymentScreen)));

PaymentState paymentScreenState(WidgetTester tester) =>
    _container(tester).read(paymentControllerProvider);

List<CartLineItem> newSaleCart(WidgetTester tester) =>
    _container(tester).read(newSaleControllerProvider).cartItems;

// ── Finders ──

Finder get completeButton => find.text(AppStrings.completeSaleAction);

bool completeEnabled(WidgetTester tester) =>
    tester
        .widget<PrimaryButton>(
      find.ancestor(of: completeButton, matching: find.byType(PrimaryButton)),
    )
        .onPressed !=
        null;