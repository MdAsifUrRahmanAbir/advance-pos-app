import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';
import 'custom_card.dart';
import 'status_badge.dart';
import 'square_icon_tile.dart';

/// General-purpose stat card. Three layouts, chosen by which params
/// are supplied:
/// 1. [icon] + [trendLabel]: icon/trend header row, label, value (Home dashboard).
/// 2. [trendLabel] only (no [icon]): label+trend row, then value
///    (+ optional [trailing] widget, e.g. a sparkline) — Analytics screen.
/// 3. Neither: compact centered label/value (was `MiniStatCard`) — Profile screen.
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? trendLabel;
  final bool isPositiveTrend;
  final Widget? trailing;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trendLabel,
    this.isPositiveTrend = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final hasTrend = trendLabel != null;
    final isCompact = !hasIcon && !hasTrend;

    final trendBadge = hasTrend
        ? StatusBadge(
      text: trendLabel!,
      type: isPositiveTrend ? StatusBadgeType.success : StatusBadgeType.error,
      compact: true,
    )
        : null;

    return CustomCard(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.md,
        horizontal: isCompact ? AppSizes.sm : AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (hasIcon) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SquareIconTile(icon: icon!, color: AppColors.primary),
                ?trendBadge,
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(label, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
            Text(value, style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
          ] else if (hasTrend) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textSecondary)),
                trendBadge!,
              ],
            ),
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
                ?trailing,
              ],
            ),
          ] else ...[
            Text(
              label,
              style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(value, style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
          ],
        ],
      ),
    );
  }
}