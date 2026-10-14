import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/icon_button.dart';
import '../../data/models/sales_return_model.dart' show ResultDatum;
import 'sales_return_item_menu.dart';

/// One sales return row — bill number, sales bill + date, first product,
/// customer, a status indicator with a three-dot menu, and a quantity /
/// discount / payable stat row. Same dense, image-less style as the
/// Stock report card; tap opens the detail sheet.
class SalesReturnCardTile extends StatelessWidget {
  final ResultDatum item;
  final VoidCallback? onShowInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const SalesReturnCardTile({
    super.key,
    required this.item,
    this.onShowInfo,
    this.onEdit,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive == 1;
    final statusColor = isActive ? AppColors.success : AppColors.error;
    final statusLabel = isActive
        ? AppStrings.srStatusActive
        : AppStrings.srStatusInactive;
    final firstProduct = item.productNames.isEmpty
        ? AppStrings.srNoProducts
        : item.productNames.first;
    final extraProducts = item.productNames.length - 1;

    return CustomCard(
      onTap: isDeleting ? null : onShowInfo,
      padding: const EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.sm,
        top: AppSizes.sm,
        bottom: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.returnBillNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      '${AppStrings.srSalesBillPrefix}${item.salesBillNo} • ${item.returnDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: context.appColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Container(
                width: AppSizes.xs + AppSizes.xs / 2,
                height: AppSizes.xs + AppSizes.xs / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              SalesReturnItemMenu(
                onEdit: onEdit,
                onDelete: onDelete,
                isBusy: isDeleting,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  firstProduct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
              if (extraProducts > 0) ...[
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.srMoreProducts(extraProducts),
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: AppSizes.iconSm,
                color: context.appColors.textHint,
              ),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  item.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: context.appColors.textHint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Divider(height: 1, color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: AppStrings.srQuantityLabel,
                  value: item.totalReturnQuantity,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: AppStrings.srDiscountLabel,
                  value: item.returnDisAmount,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: AppStrings.srPayableLabel,
                  value: item.payableReturnAmount,
                  highlight: true,
                ),
              ),
              AppIconButton(
                icon: Icons.info_outline_rounded,
                color: AppColors.primary,
                tooltip: AppStrings.srInfoTooltip,
                onPressed: isDeleting ? null : onShowInfo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Stat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontXs,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.xs / 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            color: highlight
                ? AppColors.primary
                : context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}