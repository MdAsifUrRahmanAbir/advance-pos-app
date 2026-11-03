import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// Totals block: amount, qty, discount, VAT, adjust point, extras, grand
/// total, in words, paid by, given and changed amount. Rows whose server
/// value is null are hidden; delivery / processing / due only when non-zero.
class SalesBillSummarySection extends StatelessWidget {
  final Summary summary;
  final List<Payment> payments;

  const SalesBillSummarySection({
    super.key,
    required this.summary,
    required this.payments,
  });

  /// Smaller than AppSizes.fontXs for the "Excl." hint — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final paidBy = SalesBillPreviewFormat.paidBy(payments);
    final words = SalesBillPreviewFormat.text(s.grandTotalWords);
    // A zero rate with a VAT amount means item-wise VAT: shown as "-".
    final vatRate = SalesBillPreviewFormat.isNonZero(s.vatRate)
        ? SalesBillPreviewFormat.quantity(s.vatRate)
        : AppStrings.emptyValue;
    final discountPct =
    s.showDiscountPct && SalesBillPreviewFormat.isPresent(s.discountRate)
        ? AppStrings.billDiscountPct(
      SalesBillPreviewFormat.quantity(s.discountRate),
    )
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmountRow(
          label: AppStrings.billTotalAmount,
          value: SalesBillPreviewFormat.amount(s.totalAmount),
        ),
        _AmountRow(
          label: AppStrings.billTotalQuantity,
          value: SalesBillPreviewFormat.quantity(s.totalQuantity),
        ),
        if (SalesBillPreviewFormat.isPresent(s.discountAmount))
          _AmountRow(
            label:
            '${AppStrings.billDiscount}$discountPct${AppStrings.billMinusSuffix}',
            value: SalesBillPreviewFormat.amount(s.discountAmount),
          ),
        if (SalesBillPreviewFormat.isPresent(s.vatAmount))
          _AmountRow(
            labelSpan: TextSpan(
              text: AppStrings.billVat,
              children: [
                const TextSpan(
                  text: AppStrings.billVatExcl,
                  style: TextStyle(
                    fontSize: _fontTiny,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(text: AppStrings.billVatRate(vatRate)),
              ],
            ),
            value: SalesBillPreviewFormat.amount(s.vatAmount),
          ),
        if (SalesBillPreviewFormat.isPresent(s.adjustPoint))
          _AmountRow(
            label: AppStrings.billAdjustPoint,
            value: SalesBillPreviewFormat.amount(s.adjustPoint),
          ),
        if (SalesBillPreviewFormat.isNonZero(s.deliveryCharge))
          _AmountRow(
            label: AppStrings.billDeliveryCharge,
            value: SalesBillPreviewFormat.amount(s.deliveryCharge),
          ),
        if (SalesBillPreviewFormat.isNonZero(s.processingFee))
          _AmountRow(
            label: AppStrings.billProcessingFee,
            value: SalesBillPreviewFormat.amount(s.processingFee),
          ),
        _AmountRow(
          label: AppStrings.billGrandTotal,
          value: SalesBillPreviewFormat.amount(s.grandTotal),
          emphasize: true,
        ),
        const SalesBillDashedDivider(),
        if (words != null)
          _LabeledLine(label: AppStrings.billInWords, value: words),
        if (paidBy != null)
          _LabeledLine(label: AppStrings.billPaidBy, value: paidBy),
        if (words != null || paidBy != null) const SalesBillDashedDivider(),
        if (SalesBillPreviewFormat.isPresent(s.givenAmount))
          _AmountRow(
            label: AppStrings.billGivenAmount,
            value: SalesBillPreviewFormat.amount(s.givenAmount),
          ),
        _AmountRow(
          label: AppStrings.billChangedAmount,
          value: SalesBillPreviewFormat.accounting(s.changedAmount),
          emphasize: true,
        ),
        if (SalesBillPreviewFormat.isNonZero(s.dueAmount))
          _AmountRow(
            label: AppStrings.billDueAmount,
            value: SalesBillPreviewFormat.amount(s.dueAmount),
            emphasize: true,
          ),
        const SalesBillDashedDivider(),
      ],
    );
  }
}

/// Bold label on the left, amount on the right. [emphasize] = bigger value.
class _AmountRow extends StatelessWidget {
  final String? label;
  final InlineSpan? labelSpan;
  final String value;
  final bool emphasize;

  const _AmountRow({
    this.label,
    this.labelSpan,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text.rich(
              labelSpan ?? TextSpan(text: label),
              style: labelStyle,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: emphasize ? AppSizes.fontMd : AppSizes.fontXs,
            ),
          ),
        ],
      ),
    );
  }
}

/// "In Words: …" / "PAID BY: …" — bold label, regular value, wraps.
class _LabeledLine extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(fontWeight: FontWeight.w700),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}