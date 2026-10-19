import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/icon_button.dart';
import '../controllers/expense_form_payment_accounts_provider.dart';
import '../states/expense_form_format.dart';
import '../states/expense_form_state.dart';

/// Added lines (newest first, numbered like the web table) plus the total.
class ExpenseFormLinesSection extends StatelessWidget {
  final List<ExpenseFormLine> lines;
  final Map<int, String> headNames;
  final List<ExpenseFormAccountOption> accountOptions;
  final num total;
  final ValueChanged<int> onRemove; // index into [lines]
  final bool enabled;

  const ExpenseFormLinesSection({
    super.key,
    required this.lines,
    required this.headNames,
    required this.accountOptions,
    required this.total,
    required this.onRemove,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Text(
            AppStrings.expFormLinesTitle(lines.length),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (lines.isEmpty)
          const CustomCard(
            padding: EdgeInsets.all(AppSizes.md),
            fullWidth: true,
            child: Text(
              AppStrings.expFormLinesEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: AppSizes.fontSm,
              ),
            ),
          )
        else
          for (var i = lines.length - 1; i >= 0; i--) ...[
            _LineTile(
              number: i + 1,
              line: lines[i],
              headLabel: headNames[lines[i].headId] ?? lines[i].headName,
              accountLabel: resolveExpenseFormAccountLabel(
                accountOptions,
                systemId: lines[i].paymentSystemId,
                accountId: lines[i].paymentAccId,
              ),
              onRemove: enabled ? () => onRemove(i) : null,
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        _TotalRow(total: total),
      ],
    );
  }
}

class _LineTile extends StatelessWidget {
  final int number;
  final ExpenseFormLine line;
  final String headLabel;
  final String accountLabel;
  final VoidCallback? onRemove;

  const _LineTile({
    required this.number,
    required this.line,
    required this.headLabel,
    required this.accountLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
      ),
      fullWidth: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  accountLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
                if (line.localNarration.isNotEmpty)
                  Text(
                    line.localNarration,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontXs,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            ExpenseFormFormat.amount(line.amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppIconButton(
            icon: Icons.delete_outline_rounded,
            color: AppColors.error,
            tooltip: AppStrings.expFormRemoveLine,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final num total;

  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.totalLabel,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ExpenseFormFormat.total(total),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}