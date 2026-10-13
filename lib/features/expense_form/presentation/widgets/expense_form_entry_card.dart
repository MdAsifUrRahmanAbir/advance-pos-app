import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/searchable_dropdown_field.dart';
import '../../../../core/widgets/common/secondary_button.dart';

/// The "new line" row: head, payment account, local narration, amount and
/// an Add line button.
class ExpenseFormEntryCard extends StatelessWidget {
  final List<(int, String)> headItems;
  final List<(int, String)> accountItems;
  final int? headId;
  final int? accountId;
  final TextEditingController narrationController;
  final TextEditingController amountController;
  final String? errorText;
  final bool enabled;
  final ValueChanged<int?> onHeadChanged;
  final ValueChanged<int?> onAccountChanged;
  final VoidCallback onAdd;

  const ExpenseFormEntryCard({
    super.key,
    required this.headItems,
    required this.accountItems,
    required this.headId,
    required this.accountId,
    required this.narrationController,
    required this.amountController,
    required this.errorText,
    required this.enabled,
    required this.onHeadChanged,
    required this.onAccountChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchableDropdownField<int>(
            label: AppStrings.expFormHead,
            hintText: AppStrings.expFormSelectHead,
            items: headItems,
            selectedId: headId,
            onChanged: onHeadChanged,
            enabled: enabled,
          ),
          const SizedBox(height: AppSizes.md),
          SearchableDropdownField<int>(
            label: AppStrings.expFormPaymentAccount,
            hintText: AppStrings.expFormSelectAccount,
            items: accountItems,
            selectedId: accountId,
            onChanged: onAccountChanged,
            enabled: enabled,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: PrimaryInputField(
                  label: AppStrings.expFormLocalNarration,
                  hint: AppStrings.expFormLocalNarrationHint,
                  controller: narrationController,
                  enabled: enabled,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                flex: 2,
                child: PrimaryInputField(
                  label: AppStrings.expFormAmountLabel,
                  hint: AppStrings.expFormAmountHint,
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: enabled,
                ),
              ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.sm),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),
          SecondaryButton(
            label: AppStrings.expFormAddLine,
            icon: Icons.add_rounded,
            onPressed: enabled ? onAdd : null,
          ),
        ],
      ),
    );
  }
}