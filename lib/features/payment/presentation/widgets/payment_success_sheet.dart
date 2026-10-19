import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../states/payment_state.dart';
import 'mini_receipt_card.dart';
import 'payment_success_actions.dart';

/// Shown after `POST /sales/add` succeeds. Same layout as the Edit Sale
/// success sheet. It can't be swiped or back-buttoned away — the action
/// buttons (New Sale / Dashboard) are the only exits.
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
    final colors = context.appColors;
    final billNo = paymentState.salesBillNo;
    final amount = CurrencyFormatter.format(paymentState.payableAmount);
    final subtitle = (billNo != null && billNo.isNotEmpty)
        ? AppStrings.paymentCollectedBillSubtitle(billNo, amount)
        : AppStrings.paymentCollectedSubtitle(amount);

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: AppSizes.xxl),
                const SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.paymentCollectedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
                ),
                const SizedBox(height: AppSizes.lg),
                MiniReceiptCard(
                  billNo: billNo,
                  saleDate: paymentState.saleDate,
                  methodLabel: paymentState.methodLabel,
                  items: paymentState.receiptItems,
                  subtotal: paymentState.subtotal,
                  discount: paymentState.discountAmount,
                  vat: paymentState.vatAmount,
                  total: paymentState.payableAmount,
                  paid: paymentState.totalCollected,
                  change: paymentState.cashReturn,
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
        ),
      ),
    );
  }
}