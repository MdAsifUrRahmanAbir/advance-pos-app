import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/edit_sale_payment_state.dart';

/// FLAG: no alpha token in AppColors; same tint as ChangeDueBanner.
const double _tintAlpha = 0.06;
const double _eps = 0.005;

/// What the invoice was paid with before the edit, the new total, and
/// whether the customer pays more or gets money back (always from Cash).
class EditSalePreviousPaymentCard extends StatelessWidget {
  final List<PreviousPayment> previousPayments;
  final double previousTotal;
  final double originalPayable;
  final double newPayable;

  const EditSalePreviousPaymentCard({
    super.key,
    required this.previousPayments,
    required this.previousTotal,
    required this.originalPayable,
    required this.newPayable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.editSalePreviousPaymentTitle,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          if (previousPayments.isEmpty)
            Text(
              AppStrings.editSaleNoPreviousPayment,
              style: TextStyle(color: colors.textHint, fontSize: AppSizes.fontSm),
            )
          else
            for (final p in previousPayments)
              _AmountRow(label: p.systemName, amount: p.amount),
          Divider(color: colors.border, height: AppSizes.lg),
          _AmountRow(
            label: AppStrings.editSaleOriginalTotalLabel,
            amount: originalPayable,
            muted: true,
          ),
          _AmountRow(label: AppStrings.invoicePaidLabel, amount: previousTotal),
          _AmountRow(
            label: AppStrings.editSaleNewTotalLabel,
            amount: newPayable,
            bold: true,
          ),
          const SizedBox(height: AppSizes.sm),
          _DifferencePill(difference: newPayable - previousTotal),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final bool muted;

  const _AmountRow({
    required this.label,
    required this.amount,
    this.bold = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = TextStyle(
      color: muted ? colors.textSecondary : colors.textPrimary,
      fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(CurrencyFormatter.format(amount), style: style),
        ],
      ),
    );
  }
}

/// "Customer pays more +X" / "Return to customer −X · from Cash" /
/// "Total unchanged".
class _DifferencePill extends StatelessWidget {
  final double difference;

  const _DifferencePill({required this.difference});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMore = difference > _eps;
    final isReturn = difference < -_eps;
    final color = isMore
        ? AppColors.warning
        : isReturn
        ? AppColors.success
        : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _tintAlpha),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            isMore
                ? Icons.add_card_rounded
                : isReturn
                ? Icons.keyboard_return_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMore
                      ? AppStrings.editSaleCollectMoreLabel
                      : isReturn
                      ? AppStrings.returnToCustomerLabel
                      : AppStrings.editSaleNoDifferenceLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isMore || isReturn)
                  Text(
                    isMore
                        ? AppStrings.editSaleCollectMoreNote
                        : AppStrings.editSaleReturnFromCashNote,
                    style: TextStyle(color: color, fontSize: AppSizes.fontXs),
                  ),
              ],
            ),
          ),
          if (isMore || isReturn)
            Text(
              '${isMore ? '+' : '-'}'
                  '${CurrencyFormatter.format(difference.abs())}',
              style: TextStyle(
                color: color,
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}