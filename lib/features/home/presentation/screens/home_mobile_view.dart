import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../../routes/route_names.dart';
import '../../../profile/presentation/screens/profile_session_info.dart';
import '../controllers/home_controller.dart';
import '../states/dashboard_format.dart';
import '../states/dashboard_skeleton_data.dart';
import '../states/dashboard_view_mapper.dart';
import '../states/home_state.dart';
import '../widgets/collection_breakdown_card.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_segmented_toggle.dart';
import '../widgets/home_header.dart';
import '../widgets/home_info_strip.dart';
import '../widgets/month_overview_card.dart';
import '../widgets/sales_trend_chart_card.dart';
import '../widgets/today_cash_flow_card.dart';
import '../widgets/today_sales_hero_card.dart';
import '../widgets/top_categories_section.dart';
import '../widgets/top_products_section.dart';

class HomeMobileView extends ConsumerWidget {
  const HomeMobileView({super.key});

  /// Brand glow behind the header — FLAG: no gradient tokens.
  static const double _glowHeight = 320;
  static const double _glowAlpha = 0.14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final session = watchProfileSessionInfo(ref);
    final period = state.selectedPeriod;
    final range = state.selectedChartRange;

    final isFirstLoad = state.dashboardModel == null && state.isDashboardLoading;
    final isSkeleton = state.isDashboardLoading; // first load AND refresh
    final showError = state.dashboardModel == null && !state.isDashboardLoading;
    final model = state.dashboardModel ?? DashboardSkeletonData.model;

    final now = DateTime.now();
    final today = HomeState.periods.first;
    final thisMonth = HomeState.periods.last;

    // ── Header data (session, not dashboard) ──
    final companyName = session.company?.name.trim() ?? '';
    final userName = session.employee?.userName.trim() ?? '';
    final name = userName.isNotEmpty
        ? userName
        : (companyName.isNotEmpty ? companyName : AppStrings.appBrandName);
    final subtitle = userName.isNotEmpty ? companyName : '';
    final employeeNo = session.employee?.employeeNo?.trim() ?? '';
    final employeeLabel = employeeNo.isNotEmpty
        ? employeeNo
        : (session.employeeId?.toString() ?? AppStrings.emptyValue);

    /// Dashboard + all master data; master-data failures are shown by the
    /// main shell, so only a dashboard failure gets a snackbar here.
    Future<void> refresh() async {
      final ok = await controller.refreshAll();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(homeControllerProvider).errorMessage ??
                  AppStrings.dashLoadFailed,
            ),
          ),
        );
      }
    }

    final header = Skeleton.ignore(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            greeting: DashboardFormat.greeting(now),
            name: name,
            subtitle: subtitle,
            logoUrl: session.logoUrl,
            isOnline: state.isOnline,
          ),
          // const SizedBox(height: AppSizes.md),
          // HomeInfoStrip(
          //   items: [
          //     HomeInfoItem(
          //       icon: Icons.store_mall_directory_outlined,
          //       label: AppStrings.homeBranchLabel,
          //       value: session.headerTitle.isNotEmpty
          //           ? session.headerTitle
          //           : AppStrings.emptyValue,
          //     ),
          //     HomeInfoItem(
          //       icon: Icons.badge_outlined,
          //       label: AppStrings.homeEmployeeIdLabel,
          //       value: employeeLabel,
          //     ),
          //   ],
          // ),
        ],
      ),
    );

    final Widget body;
    if (showError) {
      body = Column(
        children: [
          Padding(padding: const EdgeInsets.all(AppSizes.md), child: header),
          Expanded(
            child: DashboardErrorView(
              message: state.errorMessage ?? AppStrings.dashLoadFailed,
              onRetry: controller.getDashboard,
            ),
          ),
        ],
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: refresh,
        child: ListView(
          physics: isFirstLoad
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.md,
            AppSizes.md,
            AppSizes.bottomNavBarHeight,
          ),
          children: [
            header,
            const SizedBox(height: AppSizes.lg),
            TodaySalesHeroCard(data: model.overviewFor(today), date: now),
            const SizedBox(height: AppSizes.md),
            TodayCashFlowCard(balance: model.balanceFor(today)),
            const SizedBox(height: AppSizes.lg),
            MonthOverviewCard(
              title: AppStrings.homeMonthOverview(
                AppStrings.homeMonthYear(
                  AppStrings.monthShortNames[now.month - 1],
                  now.year,
                ),
              ),
              sales: model.overviewFor(thisMonth),
              salesReturn: model.returnFor(thisMonth),
              balance: model.balanceFor(thisMonth),
              onViewAll: () => context.push(RouteNames.invoices),
            ),
            const SizedBox(height: AppSizes.lg),
            DashboardSectionHeader(
              title: AppStrings.homePaymentsTitle,
              trailing: DashboardSegmentedToggle(
                labels: const [
                  AppStrings.invoiceDatePresetToday,
                  AppStrings.invoiceDatePresetThisMonth,
                ],
                selectedIndex: HomeState.periods.indexOf(period),
                onChanged: (i) => controller.selectPeriod(HomeState.periods[i]),
              ),
            ),
            CollectionBreakdownCard(collection: model.collectionFor(period)),
            const SizedBox(height: AppSizes.lg),
            SalesTrendChartCard(
              data: model.trendFor(range),
              selectedIndex: HomeState.chartRanges.indexOf(range),
              onRangeChanged: (i) =>
                  controller.selectChartRange(HomeState.chartRanges[i]),
            ),
            const SizedBox(height: AppSizes.lg),
            TopCategoriesSection(
              categories: model.message.topSelling.categories,
              showAll: state.showAllCategories,
              onToggleShowAll: controller.toggleShowAllCategories,
            ),
            const SizedBox(height: AppSizes.lg),
            TopProductsSection(
              products: model.message.topSelling.products,
              showAll: state.showAllProducts,
              onToggleShowAll: controller.toggleShowAllProducts,
            ),
          ],
        ).skeletonizer(enabled: isSkeleton),
      );
    }

    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _glowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: _glowAlpha),
                    colors.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(bottom: false, child: body),
        ],
      ),
    );
  }
}