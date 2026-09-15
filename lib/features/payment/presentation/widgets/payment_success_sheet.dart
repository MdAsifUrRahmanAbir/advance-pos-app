import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/payment_state.dart';
import 'mini_receipt_card.dart';
import 'payment_success_actions.dart';

class PaymentSuccessSheet extends StatelessWidget {
  final PaymentState paymentState;
  final GlobalKey receiptBoundaryKey;
  final bool isSharing;
  final bool isPrinting;
  final VoidCallback onNewSale;
  final VoidCallback onGoToDashboard;
  final VoidCallback onShareReceipt;
  final VoidCallback onPrintReceipt;

  const PaymentSuccessSheet({
    super.key,
    required this.paymentState,
    required this.receiptBoundaryKey,
    required this.isSharing,
    required this.isPrinting,
    required this.onNewSale,
    required this.onGoToDashboard,
    required this.onShareReceipt,
    required this.onPrintReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLg),
          topRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: AppSizes.iconLg,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              AppStrings.paymentCollectedTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              AppStrings.paymentCollectedSubtitle(
                '₹${paymentState.payableAmount.toStringAsFixed(2)}',
              ),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            MiniReceiptCard(
              saleId: paymentState.saleId,
              saleDate: paymentState.saleDate,
              method: paymentState.selectedMethod,
              items: paymentState.receiptItems,
              total: paymentState.payableAmount,
              boundaryKey: receiptBoundaryKey,
            ),
            const SizedBox(height: AppSizes.lg),
            PaymentSuccessActions(
              isSharing: isSharing,
              isPrinting: isPrinting,
              onNewSale: onNewSale,
              onGoToDashboard: onGoToDashboard,
              onShareReceipt: onShareReceipt,
              onPrintReceipt: onPrintReceipt,
            ),
          ],
        ),
      ),
    );
  }
}
