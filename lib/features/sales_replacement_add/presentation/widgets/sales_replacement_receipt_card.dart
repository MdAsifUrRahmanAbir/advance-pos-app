import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../states/sales_replacement_receipt.dart';

/// Receipt of a created replacement: bill numbers, date, customer and
/// payment method, the returned products (credits), the replacement
/// products, then new total / return credit / net payable / paid / change.
///
/// Wrapped in a [RepaintBoundary] keyed by [boundaryKey] for image
/// sharing. Deliberately uses the LIGHT palette constants (not
/// `context.appColors`): a shared receipt image should look the same
/// whatever theme the salesman's phone is in.
class SalesReplacementReceiptCard extends StatelessWidget {
  final SalesReplacementReceipt receipt;
  final GlobalKey boundaryKey;

  const SalesReplacementReceiptCard({
    super.key,
    required this.receipt,
    required this.boundaryKey,
  });

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
            _MetaRow(label: AppStrings.srdReturnBillNoLabel, value: receipt.billNo),
            _MetaRow(
              label: AppStrings.srdSalesBillNoLabel,
              value: receipt.originalBillNo,
            ),
            _MetaRow(label: AppStrings.receiptDateLabel, value: receipt.date),
            _MetaRow(
              label: AppStrings.invoiceCustomerLabel,
              value: receipt.customerName,
            ),
            _MetaRow(
              label: AppStrings.receiptPaymentMethodLabel,
              value: receipt.methodLabel,
            ),
            const Divider(height: AppSizes.lg, color: AppColors.border),
            const _SectionTitle(AppStrings.repdReturnedSectionTitle),
            for (final item in receipt.returned)
              _AmountRow(label: '${item.quantity}× ${item.name}', value: -item.lineTotal),
            _AmountRow(
              label: AppStrings.repdReturnAmountLabel,
              value: -receipt.returnTotal,
              emphasized: true,
            ),
            const Divider(height: AppSizes.lg, color: AppColors.border),
            const _SectionTitle(AppStrings.repdReplacementSectionTitle),
            for (final item in receipt.replacement)
              _AmountRow(label: '${item.quantity}× ${item.name}', value: item.lineTotal),
            _AmountRow(
              label: AppStrings.repaNewItemsTotalLabel,
              value: receipt.newTotal,
              emphasized: true,
            ),
            const Divider(height: AppSizes.lg, color: AppColors.border),
            _AmountRow(
              label: AppStrings.repaNetPayableLabel,
              value: receipt.netPayable,
              emphasized: true,
            ),
            if (receipt.collected > 0)
              _AmountRow(label: AppStrings.invoicePaidLabel, value: receipt.collected),
            if (receipt.change > 0)
              _AmountRow(label: AppStrings.change, value: receipt.change),
            const SizedBox(height: AppSizes.sm),
            const Text(
              AppStrings.receiptThankYouLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontXs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w700,
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
            ),
          ),
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

  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

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