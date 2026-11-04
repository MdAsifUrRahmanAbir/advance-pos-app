import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_rank_badge.dart';
import 'dashboard_section_header.dart';
import 'dashboard_view_all_button.dart';

/// Top products: rank, name, barcode · units sold, revenue. Shows the first
/// [previewCount] until "View all" is tapped.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    AppStrings.dashNoData,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      _ProductRow(rank: i + 1, data: visible[i]),
                      if (i != visible.length - 1)
                        Divider(height: 1, color: colors.border),
                    ],
                  ],
                ),
        ),
      ],
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
                  '${data.prodBarcode} · ${AppStrings.dashQtySold(data.totalQuantity)}',
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
