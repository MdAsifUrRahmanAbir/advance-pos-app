import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../states/home_state.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  final List<StatCardData> stats;

  const DashboardStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.md,
        crossAxisSpacing: AppSizes.md,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) => DashboardStatCard(data: stats[index]),
    );
  }
}