import 'package:advance_pos_app/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/dashboard_period_filter.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/daily_target_progress_card.dart';
import '../widgets/top_products_section.dart';
import '../widgets/recent_sales_section.dart';

class HomeMobileView extends ConsumerWidget {
  const HomeMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Column(
      children: [
        DashboardTopBar(
          isOnline: state.isOnline,
          onNotificationsTap: () => context.push(RouteNames.notifications),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              DashboardPeriodFilter(
                selectedPeriod: state.selectedPeriod,
                onPeriodChanged: controller.selectPeriod,
              ),
              const SizedBox(height: AppSizes.md),
              DashboardStatsGrid(stats: state.stats),
              const SizedBox(height: AppSizes.md),
              DailyTargetProgressCard(
                percent: state.dailyTargetPercent,
                achieved: state.dailyTargetAchieved,
                goal: state.dailyTargetGoal,
              ),
              const SizedBox(height: AppSizes.md),
              TopProductsSection(products: state.topProducts),
              const SizedBox(height: AppSizes.md),
              RecentSalesSection(
                sales: state.recentSales,
                onTapSale: (sale) {
                  // TODO: wire to order detail route once
                  // RouteNames.orderDetail exists — pass sale.saleId.
                  context.push('/orders/${sale.saleId}');
                },
              ),

              SizedBox(height: AppSizes.bottomNavBarHeight)

            ],
          ),
        ),

      ],
    );
  }
}