import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/expense_model.dart' show ResultDatum;
import '../states/expense_format.dart';
import 'expense_item_menu.dart';

/// One expense row: number, date · outlet, amount, head count and a
/// three-dot menu (Edit / Delete).
class ExpenseListItem extends StatelessWidget {
  final ResultDatum data;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const ExpenseListItem({
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDeleting ? null : onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: CustomCard(
        // Right/vertical padding is tighter so the 48dp menu target keeps the
        // card at its previous height.
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.sm,
          AppSizes.sm,
        ),
        child: Row(
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
                  Text(
                    data.expenseNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.expenseDate} · ${data.branchName}',
                    maxLines: 1,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ExpenseFormat.money(data.totalAmount),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.expHeadsCount(data.details.length),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ],
            ),
            ExpenseItemMenu(
              onEdit: onEdit,
              onDelete: onDelete,
              isBusy: isDeleting,
            ),
          ],
        ),
      ),
    );
  }
}