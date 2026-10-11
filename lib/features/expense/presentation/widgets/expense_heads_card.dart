import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/expense_detail_model.dart' show Detail, ResultData;
import '../states/expense_format.dart';

/// Expense heads: head name, resolved payment account, narration, amount,
/// plus a total footer. [accountLabelOf] maps (paymentSystemId,
/// paymentAccId) to a display label from master data.
class ExpenseHeadsCard extends StatelessWidget {
  final ResultData data;
  final String Function(int systemId, int accountId) accountLabelOf;

  const ExpenseHeadsCard({
    super.key,
    required this.data,
    required this.accountLabelOf,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.expExpenseHeads,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          for (final head in data.details) ...[
            _HeadTile(
              head: head,
              accountLabel: accountLabelOf(
                head.paymentSystemId,
                head.paymentAccId,
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.expTotal,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ExpenseFormat.money(data.totalAmount),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadTile extends StatelessWidget {
  final Detail head;
  final String accountLabel;

  const _HeadTile({required this.head, required this.accountLabel});

  @override
  Widget build(BuildContext context) {
    final narration = head.localNarration.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  head.headName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Flexible(
                      child: Text(
                        accountLabel,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontXs,
                        ),
                      ),
                    ),
                  ],
                ),
                if (narration.isNotEmpty && narration != AppStrings.expEmptyValue)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      narration,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontXs,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            ExpenseFormat.money(head.amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}