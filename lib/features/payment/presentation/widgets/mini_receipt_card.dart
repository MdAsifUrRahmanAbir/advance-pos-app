import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../states/payment_state.dart';

/// Receipt summary: bill no, date, method, lines, then (when [subtotal]
/// is given) subtotal / discount / VAT, total, paid and change.
///
/// With a [boundaryKey] it is wrapped in a [RepaintBoundary] for image
/// sharing. Uses the LIGHT palette constants on purpose: a shared receipt
/// image should look the same whatever theme the phone is in.
class MiniReceiptCard extends StatelessWidget {
  final String saleDate;
  final String methodLabel;
  final List<ReceiptLineItem> items;
  final double total;
  final GlobalKey? boundaryKey;

  final String? billNo;
  final double? subtotal;
  final double discount;
  final double vat;
  final double? paid;
  final double change;

  const MiniReceiptCard({
    super.key,
    required this.saleDate,
    required this.methodLabel,
    required this.items,
    required this.total,
    this.boundaryKey,
    this.billNo,
    this.subtotal,
    this.discount = 0,
    this.vat = 0,
    this.paid,
    this.change = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasBill = billNo != null && billNo!.isNotEmpty;

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: boundaryKey != null ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasBill) _MetaRow(label: AppStrings.billLabel, value: billNo!),
          _MetaRow(label: AppStrings.receiptDateLabel, value: saleDate),
          _MetaRow(label: AppStrings.receiptPaymentMethodLabel, value: methodLabel),
          const SizedBox(height: AppSizes.xs),
          const _DashedDivider(),
          const SizedBox(height: AppSizes.sm),
          for (final item in items)
            _AmountRow(label: '${item.quantity}× ${item.name}', value: item.lineTotal),
          const SizedBox(height: AppSizes.xs),
          const _DashedDivider(),
          const SizedBox(height: AppSizes.sm),
          if (subtotal != null) ...[
            _AmountRow(label: AppStrings.subtotalLabel, value: subtotal!),
            if (discount > 0)
              _AmountRow(label: AppStrings.invoiceDiscountLabel, value: -discount),
            if (vat > 0) _AmountRow(label: AppStrings.invoiceVatLabel, value: vat),
          ],
          _AmountRow(
            label: AppStrings.totalLabel,
            value: total,
            emphasized: true,
          ),
          if (paid != null) _AmountRow(label: AppStrings.invoicePaidLabel, value: paid!),
          if (change > 0) _AmountRow(label: AppStrings.change, value: change),
          if (boundaryKey != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.receiptThankYouLine,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
            ),
          ],
        ],
      ),
    );

    if (boundaryKey == null) return content;
    return RepaintBoundary(key: boundaryKey, child: content);
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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(double.infinity, 1), painter: _DashPainter());
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}