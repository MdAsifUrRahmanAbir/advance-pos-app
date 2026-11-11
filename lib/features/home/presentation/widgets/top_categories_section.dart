import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_section_header.dart';
import 'dashboard_view_all_button.dart';

/// Top categories: a coloured initial tile, name and revenue, a bar scaled
/// to the best seller with its share of all category revenue, and units
/// sold. Shows the first [previewCount] until "View all" is tapped.
class TopCategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final bool showAll;
  final VoidCallback onToggleShowAll;

  const TopCategoriesSection({
    super.key,
    required this.categories,
    required this.showAll,
    required this.onToggleShowAll,
  });

  static const int previewCount = 5;

  /// Row colours, in rank order (repeats after the last).
  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    AppColors.accent,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = showAll || categories.length <= previewCount
        ? categories
        : categories.take(previewCount).toList();
    final maxQty = categories.fold<int>(
      0,
          (max, c) => c.totalQuantity > max ? c.totalQuantity : max,
    );
    final totalAmount =
    categories.fold<double>(0, (sum, c) => sum + c.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: AppStrings.dashTopCategories,
          trailing: categories.length > previewCount
              ? DashboardViewAllButton(
            total: categories.length,
            expanded: showAll,
            onTap: onToggleShowAll,
          )
              : null,
        ),
        CustomCard(
          padding: const EdgeInsets.all(AppSizes.md),
          child: categories.isEmpty
              ? Text(
            AppStrings.dashNoData,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          )
              : Column(
            children: [
              for (var i = 0; i < visible.length; i++)
                _CategoryRow(
                  data: visible[i],
                  color: _palette[i % _palette.length],
                  fraction: maxQty > 0
                      ? visible[i].totalQuantity / maxQty
                      : 0,
                  sharePercent: totalAmount > 0
                      ? (visible[i].totalAmount / totalAmount * 100).round()
                      : 0,
                  isLast: i == visible.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category data;
  final Color color;
  final double fraction; // 0.0–1.0 of the best seller's units
  final int sharePercent; // of all category revenue
  final bool isLast;

  const _CategoryRow({
    required this.data,
    required this.color,
    required this.fraction,
    required this.sharePercent,
    required this.isLast,
  });

  /// FLAG: no tile / bar / tint tokens.
  static const double _tileSize = 40;
  static const double _barHeight = 6;
  static const double _tintAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = data.catName.trim();
    final initial = name.isEmpty ? AppStrings.emptyValue : name[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _tileSize,
            height: _tileSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: _tintAlpha),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: color,
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.catName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      DashboardFormat.money(data.totalAmount),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs + AppSizes.xs / 2),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        child: LinearProgressIndicator(
                          value: fraction.clamp(0.0, 1.0),
                          minHeight: _barHeight,
                          backgroundColor: color.withValues(alpha: _tintAlpha),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      AppStrings.homeSharePercent(sharePercent),
                      style: TextStyle(
                        color: color,
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.dashQtySold(data.totalQuantity),
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}