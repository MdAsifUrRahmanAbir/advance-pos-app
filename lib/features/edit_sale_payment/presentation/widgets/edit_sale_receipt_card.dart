import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../states/edit_sale_payment_state.dart';

/// Receipt for an updated sale: bill no, date, method, lines, then
/// subtotal / discount / VAT / total / paid / change — so the totals
/// reconcile with the lines.
///
/// Wrapped in a [RepaintBoundary] keyed by [boundaryKey] for image
/// sharing. Deliberately uses the LIGHT palette constants (not
/// `context.appColors`): a shared receipt image should look the same
/// whatever theme the salesman's phone is in.
class EditSaleReceiptCard extends StatelessWidget {
  final EditSalePaymentState state;
  final GlobalKey boundaryKey;

  const EditSaleReceiptCard({super.key, required this.state, required this.boundaryKey});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MetaRow(
              label: AppStrings.editSaleReceiptBillLabel,
              value: state.updatedBillNo ?? state.billNo,
            ),
            _MetaRow(label: AppStrings.receiptDateLabel, value: state.saleDate),
            _MetaRow(label: AppStrings.receiptPaymentMethodLabel, value: state.methodLabel),
            const Divider(height: AppSizes.lg, color: AppColors.border),
            for (final item in state.receiptItems)
              _AmountRow(label: '${item.quantity}× ${item.name}', value: item.lineTotal),
            const Divider(height: AppSizes.lg, color: AppColors.border),
            _AmountRow(label: AppStrings.editSaleReceiptSubtotal, value: state.subtotal),
            if (state.discountAmount > 0)
              _AmountRow(
                label: AppStrings.editSaleReceiptDiscount,
                value: -state.discountAmount,
              ),
            if (state.vatAmount > 0)
              _AmountRow(label: AppStrings.editSaleReceiptVat, value: state.vatAmount),
            _AmountRow(
              label: AppStrings.editSaleReceiptTotal,
              value: state.payableAmount,
              emphasized: true,
            ),
            _AmountRow(label: AppStrings.editSaleReceiptPaid, value: state.totalCollected),
            if (state.cashReturn > 0)
              _AmountRow(label: AppStrings.editSaleReceiptChange, value: state.cashReturn),
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.receiptThankYouLine,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;

  const _AmountRow({required this.label, required this.value, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasized ? AppColors.primary : AppColors.textPrimary,
      fontSize: emphasized ? AppSizes.fontMd : AppSizes.fontSm,
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          ),
          Text(
            value < 0
                ? '- ${CurrencyFormatter.format(value.abs())}'
                : CurrencyFormatter.format(value),
            style: style,
          ),
        ],
      ),
    );
  }
}