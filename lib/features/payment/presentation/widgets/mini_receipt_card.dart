import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/payment_state.dart';

/// Compact receipt summary shown inside the payment-success sheet.
/// Optionally wraps itself in a RepaintBoundary (via [boundaryKey]) so
/// ReceiptShareService can capture it as an image for sharing.
class MiniReceiptCard extends StatelessWidget {
  final String saleId;
  final String saleDate;
  final PaymentMethod method;
  final List<ReceiptLineItem> items;
  final double total;
  final GlobalKey? boundaryKey;

  const MiniReceiptCard({
    super.key,
    required this.saleId,
    required this.saleDate,
    required this.method,
    required this.items,
    required this.total,
    this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: boundaryKey != null ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(label: AppStrings.receiptSaleIdLabel, value: saleId),
          const SizedBox(height: AppSizes.xs),
          _MetaRow(label: AppStrings.receiptDateLabel, value: saleDate),
          const SizedBox(height: AppSizes.xs),
          _MetaRow(
            label: AppStrings.receiptPaymentMethodLabel,
            value: method.labelKey,
          ),
          const SizedBox(height: AppSizes.sm),
          const _DashedDivider(),
          const SizedBox(height: AppSizes.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}× ${item.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ),
                  Text(
                    '₹${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const _DashedDivider(),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (boundaryKey != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.receiptThankYouLine,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontXs,
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashPainter(),
    );
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
