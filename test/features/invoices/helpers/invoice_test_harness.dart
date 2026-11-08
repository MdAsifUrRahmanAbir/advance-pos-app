import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:advance_pos_app/core/network/api_client.dart';
import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/storage/secure_storage_service.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/invoices/data/model/invoices_model.dart';
import 'package:advance_pos_app/features/invoices/data/repositories/invoices_repository.dart';
import 'package:advance_pos_app/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:advance_pos_app/routes/route_names.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockInvoicesRepository extends Mock implements InvoicesRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

/// ApiEndpoints reads ApiParams.current, which throws until someone is
/// signed in. Seeds it through the real controller — no app code change.
Future<void> seedApiParams({int branchId = 1}) async {
  final storage = MockSecureStorageService();
  when(() => storage.saveApiParams(any())).thenAnswer((_) async {});
  final container = ProviderContainer(
    overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
  );
  await container
      .read(apiParamsControllerProvider.notifier)
      .cacheFromLogin(branchId: branchId);
  container.dispose();
}

/// Matches every InvoicesRepository.getInvoices call (all named args).
Future<InvoicesModel> anyGetInvoices(MockInvoicesRepository repo) =>
    repo.getInvoices(
      start: any(named: 'start'),
      length: any(named: 'length'),
      search: any(named: 'search'),
      groupId: any(named: 'groupId'),
      categoryId: any(named: 'categoryId'),
      subCategoryId: any(named: 'subCategoryId'),
      brandId: any(named: 'brandId'),
      customerId: any(named: 'customerId'),
      employeeId: any(named: 'employeeId'),
      startDate: any(named: 'startDate'),
      endDate: any(named: 'endDate'),
    );

/// Lets the microtask load and zero-delay futures finish (unit tests).
Future<void> flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// pumpAndSettle never settles while a skeleton or the load-more spinner
/// is on screen, so widget tests advance a fixed time instead.
Future<void> pumpFor(
    WidgetTester tester, [
      Duration duration = const Duration(seconds: 1),
    ]) async {
  await tester.pump();
  await tester.pump(duration);
}

const phoneSize = Size(400, 860);
const tabletSize = Size(1000, 800);

/// Pumps InvoicesScreen with a fake repository and stub routes for the
/// screens it navigates to.
///
/// [size] fixes the logical screen size for widget tests. Pass null on a
/// real device (integration tests) to keep the device's own size.
Future<void> pumpInvoicesApp(
    WidgetTester tester, {
      required InvoicesRepository repository,
      Size? size = phoneSize,
    }) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  final router = GoRouter(
    initialLocation: RouteNames.invoices,
    routes: [
      GoRoute(
        path: RouteNames.invoices,
        builder: (_, _) => const InvoicesScreen(),
      ),
      GoRoute(
        path: RouteNames.invoiceDetail,
        builder: (_, state) => Scaffold(body: Text('detail:${state.extra}')),
      ),
      GoRoute(
        path: RouteNames.editSaleCart,
        builder: (_, state) =>
            Scaffold(body: Text('edit:${state.pathParameters['billNo']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [invoicesRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
}