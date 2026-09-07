import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/activity_filter_tabs.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_item.dart';

class ActivityMobileView extends ConsumerWidget {
  const ActivityMobileView({super.key});

  // TODO: replace with activityControllerProvider's fetched data once
  // features/activity/data/repositories is implemented.
  static const _items = [
    ActivityItem(
      icon: Icons.check_circle_outline_rounded,
      title: 'API Deployment Complete',
      description: 'Production cluster v2.4.0 successfully rolled out.',
      time: '10 mins ago',
      status: ActivityStatus.success,
    ),
    ActivityItem(
      icon: Icons.access_time_rounded,
      title: 'Database Migration Pending',
      description: 'Awaiting final approval from security officer.',
      time: '32 mins ago',
      status: ActivityStatus.warning,
    ),
    ActivityItem(
      icon: Icons.person_outline_rounded,
      title: 'New Team Member Invited',
      description: "Sarah Jenkins invited to workspace 'ACME Devs'.",
      time: '1 hour ago',
      status: ActivityStatus.neutral,
    ),
    ActivityItem(
      icon: Icons.credit_card_rounded,
      title: 'Invoice Finalized',
      description: 'Finalized invoice #8125 for ACME Corp.',
      time: '2 hours ago',
      status: ActivityStatus.success,
    ),
    ActivityItem(
      icon: Icons.shield_outlined,
      title: 'Cluster Scan Succeeded',
      description: 'No critical vulnerabilities found in 42 nodes.',
      time: '4 hours ago',
      status: ActivityStatus.success,
    ),
    ActivityItem(
      icon: Icons.warning_amber_rounded,
      title: 'Terminal Connection Requested',
      description: 'SSH access requested by root agent on Node 4.',
      time: '5 hours ago',
      status: ActivityStatus.warning,
    ),
    ActivityItem(
      icon: Icons.settings_outlined,
      title: 'Backup Schedule Updated',
      description: 'Database automated backups altered to daily at 02:00.',
      time: '8 hours ago',
      status: ActivityStatus.neutral,
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(activityControllerProvider).selectedFilter;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.activityLogsTitle,
          trailingIcon: Icons.filter_list_rounded,
          onTrailingTap: () {
            // TODO: open activity filter/sort options
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityFilterTabs(
                  selected: selectedFilter,
                  onChanged: (filter) =>
                      ref.read(activityControllerProvider.notifier).selectFilter(filter),
                ),
                const SizedBox(height: AppSizes.lg),
                Column(children: _items),
              ],
            ),
          ),
        ),
      ],
    );
  }
}