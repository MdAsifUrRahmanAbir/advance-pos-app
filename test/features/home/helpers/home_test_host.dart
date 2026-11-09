import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/session/auth_session_controller.dart';
import 'package:advance_pos_app/core/session/auth_session_state.dart';
import 'package:advance_pos_app/core/session/session_profile.dart';
import 'package:advance_pos_app/core/storage/local_cache_service.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/home/data/repositories/home_repository.dart';
import 'package:advance_pos_app/features/home/presentation/controllers/home_controller.dart';
import 'package:advance_pos_app/features/home/presentation/screens/home_screen.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'fake_dashboard_cache.dart';
import 'fake_home_repository.dart';

const homeBranchId = 3;
const branchName = 'Dhanmondi';
const employeeFirstName = 'Rahim';

String cacheKeyFor(int branchId) => 'home_dashboard_$branchId';

class FakeApiParamsController extends ApiParamsController {
  FakeApiParamsController(this.branchId);
  final int branchId;

  @override
  ApiParams? build() =>
      ApiParams(branchId: branchId, employeeId: 7, salesType: 1);
}

class FakeAuthSession extends AuthSessionController {
  @override
  AuthSessionState build() => const AuthSessionState(
    status: AuthStatus.authenticated,
    profile: SessionProfile(
      sellerType: '',
      userName: '$employeeFirstName Cashier',
      userId: 7,
      employeeId: 7,
      branchName: branchName,
    ),
  );
}

/// Opens Home for a signed-in cashier of [branchId].
Future<void> pumpHomeApp(
    WidgetTester tester, {
      required FakeHomeRepository repository,
      required FakeDashboardCache cache,
      int branchId = homeBranchId,
    }) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        homeRepositoryProvider.overrideWithValue(repository),
        localCacheServiceProvider.overrideWithValue(cache),
        apiParamsControllerProvider
            .overrideWith(() => FakeApiParamsController(branchId)),
        authSessionControllerProvider.overrideWith(FakeAuthSession.new),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    ),
  );
  await pumpFor(tester);
}

HomeController homeController(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(HomeScreen)))
        .read(homeControllerProvider.notifier);

/// Skeletonizer's constructor builds a private subclass, so match by type
/// test + flag.
Finder get activeSkeleton => find.byWidgetPredicate(
      (w) => w is Skeletonizer && w.enabled,
);

Finder get dashboardList => find
    .descendant(
  of: find.byType(RefreshIndicator),
  matching: find.byType(Scrollable),
)
    .first;

/// Drags the dashboard until [finder] is built, then centres it.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
    await tester.drag(dashboardList, const Offset(0, -300));
    await pumpFor(tester, const Duration(milliseconds: 300));
  }
  await Scrollable.ensureVisible(tester.element(finder.first), alignment: 0.5);
  await pumpFor(tester);
}

/// RefreshIndicator needs several frames for its drag + spin animation.
Future<void> pumpFrames(WidgetTester tester, [int count = 20]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pullToRefresh(WidgetTester tester) async {
  await tester.fling(dashboardList, const Offset(0, 400), 1000);
  await pumpFrames(tester);
}