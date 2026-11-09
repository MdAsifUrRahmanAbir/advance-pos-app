import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/storage/cache_policy.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/home/presentation/states/dashboard_format.dart';
import 'package:advance_pos_app/features/home/presentation/widgets/sales_overview_card.dart';
import 'package:advance_pos_app/features/home/presentation/widgets/sales_trend_chart_card.dart';

import '../test/features/home/helpers/fake_dashboard_cache.dart';
import '../test/features/home/helpers/fake_home_repository.dart';
import '../test/features/home/helpers/home_fixtures.dart';
import '../test/features/home/helpers/home_test_host.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart'
    show pumpFor;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeHomeRepository repo;
  late FakeDashboardCache cache;

  setUp(() {
    repo = FakeHomeRepository();
    cache = FakeDashboardCache();
  });

  Future<void> openHome(WidgetTester tester, {int branchId = homeBranchId}) =>
      pumpHomeApp(tester, repository: repo, cache: cache, branchId: branchId);

  /// Formatted money inside the Sales Overview hero card.
  Finder heroAmount(double amount) => find.descendant(
    of: find.byType(SalesOverviewCard),
    matching: find.text(DashboardFormat.money(amount)),
  );

  // ─────────────────────────────── Loading and cache
  group('loading', () {
    testWidgets('no cache: skeleton, then API data, then cached',
            (tester) async {
          repo.gate = Completer<void>();
          final gate = repo.gate!;
          await openHome(tester);

          expect(activeSkeleton, findsOneWidget);
          expect(repo.calls, 1);

          gate.complete();
          await pumpFor(tester);

          expect(activeSkeleton, findsNothing);
          expect(heroAmount(todayAmount), findsOneWidget);
          expect(cache.cachedTodayAmount(cacheKeyFor(homeBranchId)), todayAmount);
          final policy = cache.writePolicies.single;
          expect(policy.sensitivity, CacheSensitivity.sensitive);
          expect(policy.ttl, const Duration(days: 2));
        });

    testWidgets('valid cache: shown without calling the API',
            (tester) async {
          cache.seed(cacheKeyFor(homeBranchId), dashboard(today: 11111));
          await openHome(tester);

          expect(repo.calls, 0);
          expect(heroAmount(11111), findsOneWidget);
        });

    testWidgets('expired cache: API is called', (tester) async {
      cache.seed(cacheKeyFor(homeBranchId), dashboard(today: 11111));
      cache.expired.add(cacheKeyFor(homeBranchId));
      await openHome(tester);

      expect(repo.calls, 1);
      expect(heroAmount(todayAmount), findsOneWidget);
    });

    testWidgets('unreadable cache: dropped, API is called', (tester) async {
      cache.seed(cacheKeyFor(homeBranchId), dashboard(today: 11111));
      cache.corrupt.add(cacheKeyFor(homeBranchId));
      await openHome(tester);

      expect(cache.invalidated, [cacheKeyFor(homeBranchId)]);
      expect(repo.calls, 1);
      expect(heroAmount(todayAmount), findsOneWidget);
    });

    testWidgets('cache is per branch: another branch\'s copy is not used',
            (tester) async {
          cache.seed(cacheKeyFor(4), dashboard(today: 11111));
          await openHome(tester); // branch 3

          expect(repo.calls, 1);
          expect(heroAmount(11111), findsNothing);
          expect(heroAmount(todayAmount), findsOneWidget);
          expect(cache.cachedTodayAmount(cacheKeyFor(4)), 11111); // untouched
        });

    testWidgets('first load fails: error state, Retry loads',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await openHome(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);
          expect(cache.entries, isEmpty);

          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);

          expect(find.byType(ErrorState), findsNothing);
          expect(heroAmount(todayAmount), findsOneWidget);
          expect(repo.calls, 2);
        });
  });

  // ─────────────────────────────── Refresh
  group('refresh', () {
    testWidgets('pull-to-refresh always calls the API and replaces cache',
            (tester) async {
          cache.seed(cacheKeyFor(homeBranchId), dashboard(today: 11111));
          repo.respond = (_) => dashboardJson(today: 22222);
          await openHome(tester);
          expect(repo.calls, 0);

          await pullToRefresh(tester);

          expect(repo.calls, 1);
          expect(heroAmount(22222), findsOneWidget);
          expect(cache.cachedTodayAmount(cacheKeyFor(homeBranchId)), 22222);
        });

    testWidgets('failed refresh: snackbar, old data and cache kept',
            (tester) async {
          await openHome(tester);
          repo.nextError = const ApiException(message: 'Server down');

          await pullToRefresh(tester);

          expect(find.text('Server down'), findsOneWidget); // snackbar
          expect(find.byType(ErrorState), findsNothing);
          expect(heroAmount(todayAmount), findsOneWidget);
          expect(cache.cachedTodayAmount(cacheKeyFor(homeBranchId)), todayAmount);
        });

    testWidgets('a slower older response never overwrites a newer one',
            (tester) async {
          repo.respond = (call) => dashboardJson(today: 1000.0 * call);
          await openHome(tester); // call 1
          final controller = homeController(tester);

          repo.gate = Completer<void>();
          final slow = repo.gate!;
          final older = controller.getDashboard(); // call 2, held
          final newer = await controller.getDashboard(); // call 3
          await pumpFor(tester);
          expect(newer, isTrue);
          expect(heroAmount(3000), findsOneWidget);

          slow.complete();
          expect(await older, isFalse);
          await pumpFor(tester);

          expect(heroAmount(3000), findsOneWidget);
          expect(heroAmount(2000), findsNothing);
          expect(cache.cachedTodayAmount(cacheKeyFor(homeBranchId)), 3000);
        });
  });

  // ─────────────────────────────── Content
  group('content', () {
    testWidgets('header: branch, greeting with first name, online',
            (tester) async {
          await openHome(tester);

          expect(find.text(branchName), findsOneWidget);
          expect(
            find.text(AppStrings.dashGreetingWithName(
              DashboardFormat.greeting(DateTime.now()),
              employeeFirstName,
            )),
            findsOneWidget,
          );
          expect(find.text(AppStrings.statusOnline), findsOneWidget);
        });

    testWidgets('Today ↔ This Month switches the overview', (tester) async {
      await openHome(tester);

      expect(heroAmount(todayAmount), findsOneWidget);
      expect(find.text(AppStrings.dashOrdersCount(todayOrders)), findsOneWidget);
      // Discount / VAT exist for Today only.
      expect(find.text(AppStrings.invoiceDiscountLabel), findsOneWidget);

      await tester.tap(find.text(AppStrings.invoiceDatePresetThisMonth));
      await pumpFor(tester);

      expect(heroAmount(monthAmount), findsOneWidget);
      expect(find.text(AppStrings.dashOrdersCount(monthOrders)), findsOneWidget);
      expect(find.text(AppStrings.invoiceDiscountLabel), findsNothing);
      expect(repo.calls, 1); // switching never reloads

      await tester.tap(find.text(AppStrings.invoiceDatePresetToday));
      await pumpFor(tester);
      expect(heroAmount(todayAmount), findsOneWidget);
    });

    testWidgets('chart range 7 Days ↔ 12 Months', (tester) async {
      await openHome(tester);
      await scrollTo(tester, find.byType(SalesTrendChartCard));

      expect(find.text(AppStrings.dashPeakValue('Sat', '900')), findsOneWidget);

      await tester.tap(find.text(AppStrings.dashRange12Months));
      await pumpFor(tester);

      expect(find.text(AppStrings.dashPeakValue('Dec', '120k')), findsOneWidget);
      expect(find.text(AppStrings.dashPeakValue('Sat', '900')), findsNothing);
      expect(repo.calls, 1);
    });

    testWidgets('Top Categories: 5 shown, View all / Show less',
            (tester) async {
          await openHome(tester);
          await scrollTo(tester, find.text(AppStrings.dashViewAll(7)));

          expect(find.text('Category 5'), findsOneWidget);
          expect(find.text('Category 6'), findsNothing);

          await tester.tap(find.text(AppStrings.dashViewAll(7)));
          await pumpFor(tester);
          await scrollTo(tester, find.text('Category 7'));
          expect(find.text('Category 7'), findsOneWidget);

          await scrollTo(tester, find.text(AppStrings.dashShowLess));
          await tester.tap(find.text(AppStrings.dashShowLess));
          await pumpFor(tester);
          expect(find.text('Category 6'), findsNothing);
        });

    testWidgets('Top Products: 5 shown, View all shows the rest',
            (tester) async {
          await openHome(tester);
          await scrollTo(tester, find.text(AppStrings.dashViewAll(6)));

          expect(find.text('Product 6'), findsNothing);

          await tester.tap(find.text(AppStrings.dashViewAll(6)));
          await pumpFor(tester);
          await scrollTo(tester, find.text('Product 6'));

          expect(find.text('Product 6'), findsOneWidget);
          expect(
              find.text('BC-6 · ${AppStrings.dashQtySold(44)}'), findsOneWidget);
        });

    testWidgets('empty top lists show "No data", no View all',
            (tester) async {
          repo.respond =
              (_) => dashboardJson(categoryCount: 0, productCount: 0);
          await openHome(tester);
          await scrollTo(tester, find.text(AppStrings.dashTopProducts));

          expect(find.text(AppStrings.dashNoData), findsWidgets);
          expect(find.textContaining('View all'), findsNothing);
        });
  });
}