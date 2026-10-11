import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/expense_format.dart';
import '../states/expense_state.dart';

/// Date-range filter pill + "Showing x of y" counter, on its own row below
/// the search bar. Tapping the pill opens the date sheet; the ✕ clears it.
class ExpenseDateFilterBar extends StatelessWidget {
  final ExpenseDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int shownCount;
  final int totalCount;
  final bool showCount;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;

  const ExpenseDateFilterBar({
    super.key,
    required this.datePreset,
    required this.fromDate,
    required this.toDate,
    required this.shownCount,
    required this.totalCount,
    required this.showCount,
    required this.onDateTap,
    required this.onClearDate,
  });

  bool get _isActive => datePreset != ExpenseDatePreset.all;

  String _label(BuildContext context) {
    if (datePreset == ExpenseDatePreset.custom &&
        fromDate != null &&
        toDate != null) {
      final l10n = MaterialLocalizations.of(context);
      return '${l10n.formatCompactDate(fromDate!)} - '
          '${l10n.formatCompactDate(toDate!)}';
    }
    return ExpenseFormat.presetLabel(datePreset);
  }

  @override
  Widget build(BuildContext context) {
    final color = _isActive ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.xs,
      ),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm + 2,
                  vertical: AppSizes.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: _isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: _isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: AppSizes.iconSm,
                      color: color,
                    ),
                    const SizedBox(width: AppSizes.xs + 2),
                    Flexible(
                      child: Text(
                        _label(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _isActive
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    _isActive
                        ? GestureDetector(
                      onTap: onClearDate,
                      child: Icon(
                        Icons.close_rounded,
                        size: AppSizes.iconSm,
                        color: color,
                      ),
                    )
                        : Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: AppSizes.iconSm,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (showCount)
            Text(
              AppStrings.expRecordsCount(shownCount, totalCount),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontXs,
              ),
            ),
        ],
      ),
    );
  }
}