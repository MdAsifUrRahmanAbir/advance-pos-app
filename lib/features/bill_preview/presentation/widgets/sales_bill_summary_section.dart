import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// Totals block, matching the web bill: amount, qty, discount, VAT (only
/// when its amount is above zero), adjust point, delivery / other charge,
/// grand total, in words, paid by, given amount, then Changed Amount — or
/// Due Amount for credit-type sales.
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

  /// Sales types that show Due Amount instead of Changed Amount (web bill:
  /// sales_type 3, 6, 7).
  static const Set<int> _dueSalesTypes = {3, 6, 7};

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final paidBy = SalesBillPreviewFormat.paidBy(payments);
    final words = SalesBillPreviewFormat.text(s.grandTotalWords);
    final showVat = SalesBillPreviewFormat.number(s.vatAmount) > 0;
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
    final isDueSale = _dueSalesTypes.contains(
      int.tryParse(SalesBillPreviewFormat.text(s.salesType) ?? ''),
    );

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
        _AmountRow(
          label:
              '${AppStrings.billDiscount}$discountPct${AppStrings.billMinusSuffix}',
          value: SalesBillPreviewFormat.amount(s.discountAmount),
        ),
        // TODO: label Excl./Incl. from vat_generate once the API sends it.
        if (showVat)
          _AmountRow(
            labelSpan: TextSpan(
              text: AppStrings.billVat,
              children: [
                const TextSpan(
                  text: AppStrings.billVatExcl,
                  style: TextStyle(fontSize: _fontTiny),
                ),
                TextSpan(text: AppStrings.billVatRate(vatRate)),
              ],
            ),
            value: SalesBillPreviewFormat.amount(s.vatAmount),
          ),
        if (SalesBillPreviewFormat.isNonZero(s.adjustPoint))
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
            label: AppStrings.billOtherCharge,
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
        _AmountRow(
          label: AppStrings.billGivenAmount,
          value: SalesBillPreviewFormat.amount(s.givenAmount),
        ),
        if (isDueSale)
          _AmountRow(
            label: AppStrings.billDueAmount,
            value: SalesBillPreviewFormat.amount(s.dueAmount),
          )
        else
          _AmountRow(
            label: AppStrings.billChangedAmount,
            value: SalesBillPreviewFormat.grouped(s.changedAmount),
            emphasize: true,
          ),
        const SalesBillDashedDivider(),
      ],
    );
  }
}

/// Bold label on the left, bold amount on the right. [emphasize] = bigger
/// value (web bill: 120%).
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
              fontSize: emphasize ? AppSizes.fontSm : AppSizes.fontXs,
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
