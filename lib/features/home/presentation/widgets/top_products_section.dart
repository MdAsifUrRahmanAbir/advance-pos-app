import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_rank_badge.dart';
import 'dashboard_section_header.dart';
import 'dashboard_view_all_button.dart';

/// Top products: the #1 product as a "Best seller" highlight, then the
/// rest ranked from #2 (name, barcode · units sold, revenue). Shows the
/// first [previewCount] until "View all" is tapped.
class TopProductsSection extends StatelessWidget {
  final List<Product> products;
  final bool showAll;
  final VoidCallback onToggleShowAll;

  const TopProductsSection({
    super.key,
    required this.products,
    required this.showAll,
    required this.onToggleShowAll,
  });

  static const int previewCount = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = showAll || products.length <= previewCount
        ? products
        : products.take(previewCount).toList();
    final rest = visible.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: AppStrings.dashTopProducts,
          trailing: products.length > previewCount
              ? DashboardViewAllButton(
            total: products.length,
            expanded: showAll,
            onTap: onToggleShowAll,
          )
              : null,
        ),
        if (products.isEmpty)
          CustomCard(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              AppStrings.dashNoData,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          )
        else ...[
          _BestSellerCard(data: visible.first),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: [
                  for (var i = 0; i < rest.length; i++) ...[
                    _ProductRow(rank: i + 2, data: rest[i]),
                    if (i != rest.length - 1)
                      Divider(height: 1, color: colors.border),
                  ],
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// "barcode · 12 sold", or just "12 sold" without a barcode.
String _productMeta(Product p) {
  final sold = AppStrings.dashQtySold(p.totalQuantity);
  final barcode = p.prodBarcode.trim();
  return barcode.isEmpty ? sold : AppStrings.homeMetaJoin(barcode, sold);
}

class _BestSellerCard extends StatelessWidget {
  final Product data;

  const _BestSellerCard({required this.data});

  /// FLAG: no tile / tint tokens.
  static const double _tileSize = 48;
  static const double _bgAlpha = 0.08;
  static const double _borderAlpha = 0.24;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: _bgAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: _borderAlpha),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _tileSize,
            height: _tileSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.textWhite,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.homeBestSeller,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  data.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  _productMeta(data),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            DashboardFormat.money(data.totalAmount),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final int rank;
  final Product data;

  const _ProductRow({required this.rank, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + AppSizes.xs),
      child: Row(
        children: [
          DashboardRankBadge(rank: rank),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  _productMeta(data),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
                ),
              ],
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
    );
  }
}