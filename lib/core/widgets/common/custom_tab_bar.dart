import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

class CustomTabBar extends StatelessWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    this.controller,
    required this.tabs,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      dividerColor: Colors.transparent,
      controller: controller,
      tabs: tabs,
      isScrollable: isScrollable,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: AppSizes.xs,
      labelStyle: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
    );
  }
}
