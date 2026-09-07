import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../../../../core/widgets/utility/info_tip_banner.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsTabView extends ConsumerWidget {
  const NotificationsTabView({super.key});

  // TODO: replace with notificationControllerProvider's fetched data once
  // features/notifications/data/repositories is implemented.
  static const _items = [
    NotificationTile(
      category: NotificationCategory.alert,
      title: 'Multiple SSH Failures Detected',
      description: 'Unauthorized terminal access attempts detected on cluster Node 2.',
      time: '2m ago',
      isUnread: true,
    ),
    NotificationTile(
      category: NotificationCategory.order,
      title: 'Enterprise Invoice Paid',
      description: 'ACME Corp completed payment for Invoice #8125 (\$4,500.00).',
      time: '1h ago',
      isUnread: true,
    ),
    NotificationTile(
      category: NotificationCategory.system,
      title: 'Database cluster state synchronized',
      description: 'Secure master replicated metadata sync completed.',
      time: '3h ago',
    ),
    NotificationTile(
      category: NotificationCategory.alert,
      title: 'Node 12 Latency Spike',
      description: 'System latency is above 240ms in region US-East.',
      time: '5h ago',
    ),
    NotificationTile(
      category: NotificationCategory.system,
      title: 'Subscription renewed successfully',
      description: 'Next payment scheduled for March 2026.',
      time: '1d ago',
    ),
    NotificationTile(
      category: NotificationCategory.order,
      title: 'New Enterprise Plan upgrade',
      description: "Workspace 'Apex Global' upgraded to high-performance tier.",
      time: '2d ago',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(notificationControllerProvider).selectedFilter;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.notificationsTitle,
          trailingLabel: AppStrings.markAllAsRead,
          backStyle: HeaderBackStyle.chevron,
          onTrailingTap: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFilterBar<String>(
                      // TODO: replace hardcoded (12) / (2) counts with real
                      // unread/total counts once notification data is fetched.
                      filters: const ['all', 'unread'],
                      selectedFilters: {selectedFilter},
                      labelBuilder: (filter) => filter == 'all'
                          ? '${AppStrings.filterAll} (12)'
                          : '${AppStrings.filterUnread} (2)',
                      onSelected: (filter) =>
                          ref.read(notificationControllerProvider.notifier).selectFilter(filter),
                    ),
                    const SizedBox(height: AppSizes.md),
                    const InfoTipBanner(text: AppStrings.notificationsTip),
                    const SizedBox(height: AppSizes.md),
                    Column(
                      children: [
                        for (final item in _items) ...[
                          item,
                          if (item != _items.last) const SizedBox(height: AppSizes.md),
                        ],
                      ],
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