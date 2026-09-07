import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// Customer dropdown + "add new customer" button.
/// ⚠️ Dropdown composed manually pending DropdownField's source — same
/// caveat as SalesAgentSelector in the Payment feature.
class CustomerSelectorRow extends StatelessWidget {
  final String selectedCustomer;
  final List<String> customers;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddCustomer;

  const CustomerSelectorRow({
    super.key,
    required this.selectedCustomer,
    required this.customers,
    required this.onChanged,
    required this.onAddCustomer,
  });

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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCustomer.isEmpty ? null : selectedCustomer,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                    items: customers
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
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