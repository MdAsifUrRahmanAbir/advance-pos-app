import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/home_state.dart';

class TopProductsSection extends StatelessWidget {
  final List<TopProductData> products;

  const TopProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.topProductsToday,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        ...products.asMap().entries.map(
              (entry) => _TopProductRow(
            data: entry.value,
            isAlt: entry.key.isOdd,
          ),
        ),
      ],
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final TopProductData data;
  final bool isAlt;

  const _TopProductRow({required this.data, required this.isAlt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isAlt ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: AppSizes.md,
                  child: Text(
                    '${data.rank}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AppStrings.unitsSoldLabel(data.unitsSold),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.revenue,
            style: TextStyle(
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