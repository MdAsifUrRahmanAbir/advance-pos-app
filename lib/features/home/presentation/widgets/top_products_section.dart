import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_rank_badge.dart';
import 'dashboard_section_header.dart';

/// All top products: rank, name, barcode · units sold, revenue.
class TopProductsSection extends StatelessWidget {
  final List<Product> products;

  const TopProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(title: AppStrings.dashTopProducts),
        CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: products.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Text(
              AppStrings.dashNoData,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          )
              : Column(
            children: [
              for (var i = 0; i < products.length; i++) ...[
                _ProductRow(rank: i + 1, data: products[i]),
                if (i != products.length - 1)
                  const Divider(height: 1, color: AppColors.border),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
      child: Row(
        children: [
          DashboardRankBadge(rank: rank),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.prodBarcode} · ${AppStrings.dashQtySold(data.totalQuantity)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            DashboardFormat.money(data.totalAmount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}