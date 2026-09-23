import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/customers_model.dart';
import 'customer_search_sheet.dart';

/// Customer picker row — opens the searchable, paginated
/// [CustomerSearchSheet] (backed by [CartController], no new provider),
/// plus an "add new customer" button.
class CustomerSelectorRow extends StatelessWidget {
  final ResultDatum? selectedCustomer;
  final ValueChanged<ResultDatum> onChanged;
  final VoidCallback onAddCustomer;

  const CustomerSelectorRow({
    super.key,
    required this.selectedCustomer,
    required this.onChanged,
    required this.onAddCustomer,
  });

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<ResultDatum>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerSearchSheet(),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.customerLabel,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _openPicker(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs + 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedCustomer?.customerName ?? AppStrings.selectCustomerHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selectedCustomer == null ? AppColors.textHint : AppColors.textPrimary,
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            InkWell(
              onTap: onAddCustomer,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: AppSizes.iconMd - 6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}