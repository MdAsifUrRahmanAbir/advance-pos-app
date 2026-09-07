import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../routes/route_names.dart';
import '../widgets/home_header.dart';
import '../../../../core/widgets/common/summary_card.dart';
import '../widgets/quick_action_item.dart';
import '../widgets/recent_activity_item.dart';

class HomeMobileView extends ConsumerWidget {
  const HomeMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // TODO: replace hardcoded name/avatar with homeControllerProvider
        // once features/home/data/repositories is wired to the auth user.
        HomeHeader(
          userName: 'Alex Carter',
          hasUnreadNotifications: true,
          onNotificationTap: () => context.push(RouteNames.notifications),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Stat cards ----
                Row(
                  children: const [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.credit_card_rounded,
                        label: 'Revenue',
                        value: '\$45.8K',
                        trendLabel: '+12.5%',
                        isPositiveTrend: true,
                      ),
                    ),
                    SizedBox(width: AppSizes.sm + AppSizes.xs),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Orders',
                        value: '1,248',
                        trendLabel: '-3.1%',
                        isPositiveTrend: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                Row(
                  children: const [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.person_outline_rounded,
                        label: 'Users',
                        value: '8,924',
                        trendLabel: '+8.4%',
                        isPositiveTrend: true,
                      ),
                    ),
                    SizedBox(width: AppSizes.sm + AppSizes.xs),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Growth',
                        value: '24.3%',
                        trendLabel: '+4.2%',
                        isPositiveTrend: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // ---- Quick Actions ----
                Text(
                  AppStrings.quickActions,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionItem(
                        icon: Icons.add_rounded,
                        label: AppStrings.newOrder,
                        onTap: () => context.push(RouteNames.orderList),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      // TODO: wire to a reports route once that feature exists
                      child: QuickActionItem(
                          icon: Icons.description_outlined,
                        label: AppStrings.reports,
                        onTap: () => context.push(RouteNames.notFound),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: QuickActionItem(
                        icon: Icons.inventory_2_outlined,
                        label: AppStrings.inventory,
                        onTap: () => context.push(RouteNames.error),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      // TODO: wire to a messages route once that feature exists
                      child: QuickActionItem(
                          icon: Icons.mail_outline_rounded,
                        label: AppStrings.auditLogTitle,
                        onTap: () => context.push(RouteNames.auditLog),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                Row(
                  children: [
                    Expanded(
                      // TODO: wire to a calendar route once that feature exists
                      child: QuickActionItem(
                          icon: Icons.calendar_today_outlined,
                        label: AppStrings.calender,
                        onTap: () => context.push(RouteNames.product),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      // TODO: wire to a tasks route once that feature exists
                      child: QuickActionItem(
                          icon: Icons.check_rounded,
                        label: AppStrings.tasks,
                        onTap: () => context.push(RouteNames.maintenance),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      // TODO: point to a dedicated invoices route once available
                      child: QuickActionItem(
                        icon: Icons.receipt_long_outlined,
                          label: AppStrings.invoices,
                        onTap: () => context.push(RouteNames.noInternet)
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: QuickActionItem(
                        icon: Icons.settings_outlined,
                        label: AppStrings.settingsTitle,
                        onTap: () => context.push(RouteNames.settings),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // ---- Recent Activity ----
                Text(
                  AppStrings.recentActivity,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                CustomCard(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: const Column(
                    children: [
                      RecentActivityItem(
                        icon: Icons.person_outline_rounded,
                        title: 'New node user registered: John Smith',
                        time: '2 mins ago',
                      ),
                      RecentActivityItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Order #9421 dispatched to main server',
                        time: '15 mins ago',
                      ),
                      RecentActivityItem(
                        icon: Icons.settings_outlined,
                        title: 'Secure cluster database backed up successfully',
                        time: '1 hour ago',
                      ),
                      RecentActivityItem(
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.error,
                        title: 'Unauthorized terminal access attempt detected',
                        time: '3 hours ago',
                      ),
                      RecentActivityItem(
                        icon: Icons.credit_card_rounded,
                        title: 'Invoice #8125 finalized for ACME Corp',
                        time: '5 hours ago',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}