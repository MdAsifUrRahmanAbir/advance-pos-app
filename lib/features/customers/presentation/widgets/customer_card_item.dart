import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/customers_model.dart';
import 'customer_type_badge.dart';

/// Single customer row — name + customer no. on the left, type badge on
/// the right, mobile + branch beneath, and a "Show Info" action.
/// Mirrors [StockCardTile]'s layout so it reads as the same family of UI.
class CustomerCardItem extends StatelessWidget {
  final ResultDatum item;
  final VoidCallback? onShowInfo;

  const CustomerCardItem({super.key, required this.item, this.onShowInfo});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onShowInfo,
      padding: const EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.lg,
        bottom: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      item.customerNo,
                      style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              CustomerTypeBadge(type: item.customerType),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Row(
            children: [
              Icon(Icons.call_outlined, size: AppSizes.iconSm, color: context.appColors.textSecondary),
              const SizedBox(width: AppSizes.xs),
              Text(
                item.customerMobile,
                style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: AppSizes.iconSm, color: context.appColors.textSecondary),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  item.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          // Divider(height: 1, color: context.appColors.divider),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton.icon(
          //     onPressed: onShowInfo,
          //     icon: const Icon(Icons.info_outline_rounded, size: AppSizes.iconSm),
          //     label: const Text(AppStrings.showInfo),
          //     style: TextButton.styleFrom(
          //       foregroundColor: context.appColors.primary,
          //       padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}