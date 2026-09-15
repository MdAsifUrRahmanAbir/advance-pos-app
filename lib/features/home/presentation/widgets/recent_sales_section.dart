import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/home_state.dart';

class RecentSalesSection extends StatelessWidget {
  final List<RecentSaleData> sales;
  final ValueChanged<RecentSaleData> onTapSale;

  const RecentSalesSection({
    super.key,
    required this.sales,
    required this.onTapSale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentSales,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        ...sales.map(
          (sale) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _RecentSaleCard(data: sale, onTap: () => onTapSale(sale)),
          ),
        ),
      ],
    );
  }
}

class _RecentSaleCard extends StatelessWidget {
  final RecentSaleData data;
  final VoidCallback onTap;

  const _RecentSaleCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      Icons.attach_money_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.saleId,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: AppSizes.fontSm,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                data.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppSizes.fontXs,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppStrings.saleMetaLabel(
                            data.itemCount,
                            data.timeAgo,
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.fontXs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  data.amount,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
