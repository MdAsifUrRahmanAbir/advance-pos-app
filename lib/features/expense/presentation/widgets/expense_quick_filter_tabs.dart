import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/expense_format.dart';
import '../states/expense_state.dart';

/// Quick date filter chips (All · Today · Yesterday · Last 7 Days ·
/// This Month · Last Month · Custom Range) plus a "Showing x of y" counter.
/// Single-select; tapping the active preset again goes back to All. Custom
/// Range asks the parent to open the calendar via [onCustomTap].
class ExpenseQuickFilterTabs extends StatelessWidget {
  final ExpenseDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int shownCount;
  final int totalCount;
  final bool showCount;
  final ValueChanged<ExpenseDatePreset> onPresetSelected;
  final VoidCallback onCustomTap;

  const ExpenseQuickFilterTabs({
    super.key,
    required this.datePreset,
    required this.fromDate,
    required this.toDate,
    required this.shownCount,
    required this.totalCount,
    required this.showCount,
    required this.onPresetSelected,
    required this.onCustomTap,
  });

  String _label(BuildContext context, ExpenseDatePreset preset) {
    if (preset == ExpenseDatePreset.all) return AppStrings.filterAll;
    if (preset == ExpenseDatePreset.custom &&
        datePreset == ExpenseDatePreset.custom &&
        fromDate != null &&
        toDate != null) {
      final l10n = MaterialLocalizations.of(context);
      return '${l10n.formatCompactDate(fromDate!)} - '
          '${l10n.formatCompactDate(toDate!)}';
    }
    return ExpenseFormat.presetLabel(preset);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFilterBar<ExpenseDatePreset>(
            filters: ExpenseDatePreset.values,
            selectedFilters: {datePreset},
            labelBuilder: (preset) => _label(context, preset),
            onSelected: (preset) {
              if (preset == ExpenseDatePreset.custom) {
                onCustomTap();
                return;
              }
              final isActiveFilter =
                  preset == datePreset && preset != ExpenseDatePreset.all;
              onPresetSelected(
                isActiveFilter ? ExpenseDatePreset.all : preset,
              );
            },
          ),
          if (showCount)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.xs),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppStrings.expRecordsCount(shownCount, totalCount),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}