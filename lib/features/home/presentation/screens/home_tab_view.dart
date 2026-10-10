import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../../routes/route_names.dart';
import '../controllers/home_controller.dart';
import '../states/dashboard_skeleton_data.dart';
import '../states/dashboard_view_mapper.dart';
import '../states/home_state.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/collection_breakdown_card.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_segmented_toggle.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/sales_overview_card.dart';
import '../widgets/sales_return_card.dart';
import '../widgets/sales_trend_chart_card.dart';
import '../widgets/top_categories_section.dart';
import '../widgets/top_products_section.dart';

class HomeTabView extends ConsumerWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final period = state.selectedPeriod;
    final range = state.selectedChartRange;

    final isFirstLoad = state.dashboardModel == null && state.isDashboardLoading;
    final isSkeleton = state.isDashboardLoading; // first load AND refresh
    final showError = state.dashboardModel == null && !state.isDashboardLoading;
    final model = state.dashboardModel ?? DashboardSkeletonData.model;

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

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          DashboardTopBar(
            isOnline: state.isOnline,
            onNotificationsTap: () => context.push(RouteNames.notifications),
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
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: ListView(
                    physics: isFirstLoad
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.lg),
                    children: [
                      DashboardSectionHeader(
                        title: AppStrings.dashOverview,
                        trailing: DashboardSegmentedToggle(
                          labels: const [
                            AppStrings.dashToday,
                            AppStrings.dashThisMonth,
                          ],
                          selectedIndex:
                          HomeState.periods.indexOf(period),
                          onChanged: (i) => controller
                              .selectPeriod(HomeState.periods[i]),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SalesOverviewCard(
                                  data: model.overviewFor(period),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                SalesReturnCard(
                                  data: model.returnFor(period),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              children: [
                                CashFlowCard(
                                  balance: model.balanceFor(period),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                CollectionBreakdownCard(
                                  collection:
                                  model.collectionFor(period),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      SalesTrendChartCard(
                        data: model.trendFor(range),
                        selectedIndex:
                        HomeState.chartRanges.indexOf(range),
                        onRangeChanged: (i) => controller
                            .selectChartRange(HomeState.chartRanges[i]),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TopCategoriesSection(
                              categories:
                              model.message.topSelling.categories,
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: TopProductsSection(
                              products:
                              model.message.topSelling.products,
                            ),
                          ),
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