import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../cart/data/models/customers_model.dart';

/// Customer picker row for Edit Sale. Purely presentational — the view
/// opens the search / add-customer sheets via [onPick] / [onAdd].
/// Shows a notice when the invoice's original customer couldn't be
/// matched, and a spinner while matching is in progress.
class EditSaleCustomerRow extends StatelessWidget {
  final ResultDatum? selectedCustomer;
  final bool isResolving;
  final bool unmatched;
  final VoidCallback onPick;
  final VoidCallback onAdd;

  const EditSaleCustomerRow({
    super.key,
    required this.selectedCustomer,
    required this.isResolving,
    required this.unmatched,
    required this.onPick,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final customer = selectedCustomer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.customerLabel,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: isResolving ? null : onPick,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm + AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: unmatched ? AppColors.warning : colors.border),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer?.customerName ?? AppStrings.editSaleWalkInCustomer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: customer == null ? colors.textHint : colors.textPrimary,
                                fontSize: AppSizes.fontSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (customer != null && customer.customerMobile.isNotEmpty)
                              Text(
                                customer.customerMobile,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: AppSizes.fontXs,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isResolving)
                        const SizedBox.square(
                          dimension: AppSizes.iconSm,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            IconButton.filledTonal(
              onPressed: isResolving ? null : onAdd,
              icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
            ),
          ],
        ),
        if (unmatched) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.editSaleCustomerNotMatched,
            style: const TextStyle(color: AppColors.warning, fontSize: AppSizes.fontXs),
          ),
        ],
      ],
    );
  }
}