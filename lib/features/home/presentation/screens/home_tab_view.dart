import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
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
import '../widgets/dashboard_kpi_grid.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_segmented_toggle.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/sales_overview_card.dart';
import '../widgets/sales_trend_chart_card.dart';
import '../widgets/top_categories_section.dart';
import '../widgets/top_products_section.dart';

class HomeTabView extends ConsumerWidget {
  const HomeTabView({super.key});

  /// Tablet content width — inside the 480–960 project range.
  static const double _maxContentWidth = 960;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final session = watchProfileSessionInfo(ref);
    final period = state.selectedPeriod;
    final range = state.selectedChartRange;

    final isFirstLoad = state.dashboardModel == null && state.isDashboardLoading;
    final isSkeleton = state.isDashboardLoading; // first load AND refresh
    final showError = state.dashboardModel == null && !state.isDashboardLoading;
    final model = state.dashboardModel ?? DashboardSkeletonData.model;

    final greeting = DashboardFormat.greeting(DateTime.now());
    final firstName = session.employee?.userName.trim().split(' ').first ?? '';
    final title = session.headerTitle.isNotEmpty
        ? session.headerTitle
        : AppStrings.appBrandName;

    Future<void> refresh() async {
      final ok = await controller.getDashboard();
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

    final overviewHeader = DashboardSectionHeader(
      title: AppStrings.dashOverview,
      trailing: DashboardSegmentedToggle(
        labels: const [
          AppStrings.invoiceDatePresetToday,
          AppStrings.invoiceDatePresetThisMonth,
        ],
        selectedIndex: HomeState.periods.indexOf(period),
        onChanged: (i) => controller.selectPeriod(HomeState.periods[i]),
      ),
    );
    final hero = SalesOverviewCard(data: model.overviewFor(period));
    final kpis = DashboardKpiGrid(
      balance: model.balanceFor(period),
      salesReturn: model.returnFor(period),
    );
    final collection = CollectionBreakdownCard(
      collection: model.collectionFor(period),
    );
    final trend = SalesTrendChartCard(
      data: model.trendFor(range),
      selectedIndex: HomeState.chartRanges.indexOf(range),
      onRangeChanged: (i) =>
          controller.selectChartRange(HomeState.chartRanges[i]),
    );
    final categories = TopCategoriesSection(
      categories: model.message.topSelling.categories,
      showAll: state.showAllCategories,
      onToggleShowAll: controller.toggleShowAllCategories,
    );
    final products = TopProductsSection(
      products: model.message.topSelling.products,
      showAll: state.showAllProducts,
      onToggleShowAll: controller.toggleShowAllProducts,
    );

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          DashboardTopBar(
            isOnline: state.isOnline,
            onNotificationsTap: () => context.push(RouteNames.notifications),
            title: title,
            subtitle: firstName.isEmpty
                ? greeting
                : AppStrings.dashGreetingWithName(greeting, firstName),
            logoUrl: session.logoUrl,
          ),
          Expanded(
            child: showError
                ? DashboardErrorView(
                    message: state.errorMessage ?? AppStrings.dashLoadFailed,
                    onRetry: controller.getDashboard,
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: refresh,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth,
                        ),
                        child: ListView(
                          physics: isFirstLoad
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSizes.lg),
                          children: [
                            overviewHeader,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      hero,
                                      const SizedBox(height: AppSizes.md),
                                      kpis,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(child: collection),
                              ],
                            ),
                            const SizedBox(height: AppSizes.lg),
                            trend,
                            const SizedBox(height: AppSizes.lg),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: categories),
                                const SizedBox(width: AppSizes.md),
                                Expanded(child: products),
                              ],
                            ),
                            const SizedBox(height: AppSizes.lg),
                          ],
                        ).skeletonizer(enabled: isSkeleton),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
