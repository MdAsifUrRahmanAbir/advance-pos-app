import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../states/sales_replacement_receipt.dart';
import 'sales_replacement_receipt_card.dart';

/// Shown after `POST /s_return/add` succeeds: the created replacement's
/// receipt, with Share and Print, then Done. It can't be swiped or
/// back-buttoned away — Done is the only exit, so the flow always unwinds
/// back to the replacement list.
class SalesReplacementAddSuccessSheet extends StatelessWidget {
  final SalesReplacementReceipt receipt;
  final GlobalKey receiptBoundaryKey;
  final bool isSharing;
  final bool isPrinting;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onDone;

  const SalesReplacementAddSuccessSheet({
    super.key,
    required this.receipt,
    required this.receiptBoundaryKey,
    required this.isSharing,
    required this.isPrinting,
    required this.onShare,
    required this.onPrint,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.lg,
          AppSizes.md,
          AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: AppSizes.xxl,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.repaCreatedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (receipt.billNo.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    AppStrings.repaCreatedSubtitle(receipt.billNo),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.lg),
                SalesReplacementReceiptCard(
                  receipt: receipt,
                  boundaryKey: receiptBoundaryKey,
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: AppStrings.actionShareReceipt,
                        icon: Icons.ios_share_rounded,
                        onPressed: isSharing ? null : onShare,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: SecondaryButton(
                        label: AppStrings.actionPrintReceipt,
                        icon: Icons.print_outlined,
                        onPressed: isPrinting ? null : onPrint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                PrimaryButton(label: AppStrings.done, onPressed: onDone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}