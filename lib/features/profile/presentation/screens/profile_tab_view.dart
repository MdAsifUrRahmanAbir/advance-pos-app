import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_settings_sections.dart';

/// Same content as [ProfileMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class ProfileTabView extends ConsumerWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.xl, 0, AppSizes.xl, AppSizes.xl),
            child: Column(
              children: [
                const ProfileHeader(
                  name: 'Alex Johnson',
                  role: 'Workspace Admin',
                ),
                const SizedBox(height: AppSizes.xl),
                const ProfileStatsRow(projects: '24', tasks: '156', rating: '4.8'),
                const SizedBox(height: AppSizes.xl),
                ProfileSettingsSections(
                  onPersonalInfoTap: () => context.go(RouteNames.editProfile),
                  onSettingsTap: () => context.push(RouteNames.settings),
                  // onNotificationSettingsTap: () => context.go(RouteNames.notifications),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}