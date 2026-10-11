import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/expense_detail_model.dart' show ResultData;
import '../states/expense_format.dart';

/// Hero summary: expense no + amount, then date, outlet, entry info, narration.
class ExpenseDetailSummaryCard extends StatelessWidget {
  final ResultData data;

  const ExpenseDetailSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs + 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.expExpenseNo,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                    Text(
                      data.expenseNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            AppStrings.expAmount,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              ExpenseFormat.money(data.totalAmount),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSizes.md),
          _InfoRow(AppStrings.expExpenseDate, ExpenseFormat.orDash(data.expenseDate)),
          _InfoRow(AppStrings.expOutlet, ExpenseFormat.orDash(data.branchName)),
          _InfoRow(AppStrings.expEntryBy, ExpenseFormat.orDash(data.entryBy)),
          _InfoRow(
            AppStrings.expEntryDateTime,
            ExpenseFormat.orDash(data.entryDateTime),
          ),
          _InfoRow(
            AppStrings.expGlobalNarration,
            ExpenseFormat.orDash(data.globalNarration),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}