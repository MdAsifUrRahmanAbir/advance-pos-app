import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;
  final bool showLabels;
  final Color indicatorColor;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    this.showLabels = true,
    this.indicatorColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.bottomNavBarHeight,
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: context.appColors.surface,
          indicatorColor: indicatorColor,

          // Selected/unselected icon colors
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: AppColors.primary,
                );
              }

              return const IconThemeData(
                color: AppColors.textSecondary,
              );
            },
          ),

          // Selected/unselected label colors
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                );
              }

              return const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              );
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: destinations,
          labelBehavior: showLabels
              ? NavigationDestinationLabelBehavior.alwaysShow
              : NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}