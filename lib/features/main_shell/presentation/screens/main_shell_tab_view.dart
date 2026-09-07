import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../routes/route_names.dart';
import '../controllers/main_shell_controller.dart';
import '../widgets/shell_tab_body.dart';
import '../widgets/shell_navigation_item.dart';

/// Wider-viewport layout — a side [NavigationRail] instead of a
/// bottom bar, built from the same [shellNavItems] list so mobile and
/// tablet always stay in sync when a section is added or reordered.
class MainShellTabView extends ConsumerWidget {
  const MainShellTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainShellControllerProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => ref.read(mainShellControllerProvider.notifier).selectTab(index),
            backgroundColor: context.appColors.surface,
            labelType: NavigationRailLabelType.all,
            indicatorColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.lg),
              child: GestureDetector(
                onTap: () {
                  // TODO: replace with a dedicated POS/Sales screen once
                  // features/pos_sale is built.
                  context.push(RouteNames.product);
                },
                child: Container(
                  width: AppSizes.xxl - AppSizes.xs,
                  height: AppSizes.xxl - AppSizes.xs,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: AppSizes.lg, offset: const Offset(0, AppSizes.sm)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const AppSvgIcon.string(svgString: AppSvgs.plus, size: AppSizes.iconMd, color: AppColors.textWhite),
                ),
              ),
            ),
            destinations: [
              for (final item in shellNavItems)
                NavigationRailDestination(
                  icon: AppSvgIcon.string(svgString: item.svgIcon, size: AppSizes.iconMd, color: context.appColors.textSecondary),
                  selectedIcon: AppSvgIcon.string(svgString: item.svgIcon, size: AppSizes.iconMd, color: AppColors.primary),
                  label: Text(item.label),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: context.appColors.border),
          Expanded(child: ShellTabBody(selectedIndex: selectedIndex)),
        ],
      ),
    );
  }
}