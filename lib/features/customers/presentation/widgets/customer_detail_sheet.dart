import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../data/models/customers_model.dart';
import 'customer_type_badge.dart';

/// Detail content shown in a [CustomBottomSheet] when "Show Info" is
/// tapped on a [CustomerCardItem] — every field the API returns for a
/// customer. Mirrors [StockDetailSheet]'s layout.
class CustomerDetailSheet extends StatelessWidget {
  final ResultDatum item;

  const CustomerDetailSheet({super.key, required this.item});

  static const _placeholder = '-';

  String get _purchaseStatus {
    if (item.isPurchase == null) return 'No recorded purchases';
    return 'Purchase status: ${item.isPurchase}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.customerName,
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            CustomerTypeBadge(type: item.customerType, compact: false),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _DetailRow(label: AppStrings.customerNoLabel, value: item.customerNo),
        _DetailRow(
          label: AppStrings.customerNumberLabel,
          value: item.customerMobile.isEmpty ? _placeholder : item.customerMobile,
        ),
        _DetailRow(
          label: AppStrings.customerEmailLabel,
          value: item.customerEmail.isEmpty ? _placeholder : item.customerEmail,
        ),
        item.parRemarks.isEmpty ? SizedBox.shrink(): _DetailRow(
          label: AppStrings.customerAddressLabel,
          value: item.parRemarks.isEmpty ? "" : item.parRemarks,
        ),
        _DetailRow(label: AppStrings.customerBranchLabel, value: item.branchName),
        const SizedBox(height: AppSizes.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: context.appColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Text(
            _purchaseStatus,
            style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary, height: 1.4),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs + AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}