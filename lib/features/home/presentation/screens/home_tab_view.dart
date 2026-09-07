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

/// Wider-viewport layout for the home dashboard — same content as
/// [HomeMobileView], stat cards and quick actions expand into a
/// 4-column row instead of stacking, centered in a max-width column.
class HomeTabView extends ConsumerWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        HomeHeader(
          userName: 'Alex Carter',
          hasUnreadNotifications: true,
          onNotificationTap: () => context.go(RouteNames.notifications),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Stat cards: single 4-column row on wider screens ----
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
                        SizedBox(width: AppSizes.sm + AppSizes.xs),
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
                    const SizedBox(height: AppSizes.xl),

                    // ---- Quick Actions ----
                     Text(
                      AppStrings.quickActions,
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionItem(
                            icon: Icons.add_rounded,
                            label: 'New Order',
                            onTap: () => context.go(RouteNames.orderList),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Expanded(
                          child: QuickActionItem(icon: Icons.description_outlined, label: 'Reports'),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: QuickActionItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Inventory',
                            onTap: () => context.go(RouteNames.product),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Expanded(
                          child: QuickActionItem(icon: Icons.mail_outline_rounded, label: 'Messages'),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Expanded(
                          child: QuickActionItem(icon: Icons.calendar_today_outlined, label: 'Calendar'),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Expanded(
                          child: QuickActionItem(icon: Icons.check_rounded, label: 'Tasks'),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: QuickActionItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Invoices',
                            onTap: () => context.go(RouteNames.orderList),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: QuickActionItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () => context.go(RouteNames.settings),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ---- Recent Activity ----
                     Text(
                      AppStrings.recentActivity,
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomCard(
                      padding: const EdgeInsets.all(AppSizes.lg),
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
          ),
        ),
      ],
    );
  }
}