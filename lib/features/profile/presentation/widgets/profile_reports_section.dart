import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';
import '../../../../core/widgets/common/settings_tile.dart';

/// Reports group on the Profile ("More") screen — quick links to the
/// Stock, Sales, and combined report screens. Same thin-wrapper pattern
/// as the other Profile sections ([SettingsGroup] + [SettingsTile]s).
class ProfileReportsSection extends StatelessWidget {
  final VoidCallback? onStockReportTap;
  final VoidCallback? onSalesReportTap;
  final VoidCallback? onAllReportTap;

  const ProfileReportsSection({
    super.key,
    this.onStockReportTap,
    this.onSalesReportTap,
    this.onAllReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: AppStrings.reportsSection,
      children: [
        SettingsTile(
          icon: Icons.bar_chart_rounded,
          title: AppStrings.allReportTitle,
          subtitle: AppStrings.allReportSubtitle,
          onTap: onAllReportTap,
        ),
        SettingsTile(
          icon: Icons.inventory_2_outlined,
          title: AppStrings.stockReportTitle,
          subtitle: AppStrings.stockReportSubtitle,
          onTap: onStockReportTap,
        ),
        SettingsTile(
          icon: Icons.trending_up_rounded,
          title: AppStrings.salesReportTitle,
          subtitle: AppStrings.salesReportSubtitle,
          onTap: onSalesReportTap,
        ),
      ],
    );
  }
}
