import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/expense_format.dart';
import '../states/expense_state.dart';

/// Opens the preset sheet; "Custom Range" then opens the system date range
/// picker. Reports the result through the callbacks.
/// TODO: swap showModalBottomSheet for CustomBottomSheet if its API fits.
Future<void> showExpenseDateRangeSheet({
  required BuildContext context,
  required ExpenseDatePreset selected,
  required DateTimeRange? currentRange,
  required ValueChanged<ExpenseDatePreset> onPresetSelected,
  required ValueChanged<DateTimeRange> onCustomRange,
}) async {
  final choice = await showModalBottomSheet<ExpenseDatePreset>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
    ),
    builder: (sheetContext) => ExpenseDateRangeSheet(
      selected: selected,
      onSelected: (preset) => Navigator.of(sheetContext).pop(preset),
    ),
  );

  if (choice == null) return;
  if (choice != ExpenseDatePreset.custom) {
    onPresetSelected(choice);
    return;
  }
  if (!context.mounted) return;

  final now = DateTime.now();
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 5),
    lastDate: DateTime(now.year + 1, 12, 31),
    initialDateRange: currentRange,
  );
  if (range != null) onCustomRange(range);
}

class ExpenseDateRangeSheet extends StatelessWidget {
  final ExpenseDatePreset selected;
  final ValueChanged<ExpenseDatePreset> onSelected;

  const ExpenseDateRangeSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.expFilterByDate,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final preset in ExpenseDatePreset.values)
                ChoiceChip(
                  label: Text(ExpenseFormat.presetLabel(preset)),
                  selected: preset == selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: preset == selected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: preset == selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => onSelected(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }
}