import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../states/edit_sale_payment_state.dart';
import 'edit_sale_receipt_card.dart';

/// Shown after `PUT /sales/edit` succeeds. Share / print the updated
/// receipt, then "Done" returns to the Invoices list. The sheet can't be
/// swiped or back-buttoned away — "Done" is the only exit, so the flow
/// always unwinds back to Invoices.
class EditSaleSuccessSheet extends StatelessWidget {
  final EditSalePaymentState state;
  final GlobalKey receiptBoundaryKey;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onDone;

  const EditSaleSuccessSheet({
    super.key,
    required this.state,
    required this.receiptBoundaryKey,
    required this.onShare,
    required this.onPrint,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final billNo = state.updatedBillNo ?? state.billNo;

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
                  AppStrings.editSaleUpdatedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.editSaleUpdatedSubtitle(billNo),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
                ),
                const SizedBox(height: AppSizes.lg),
                EditSaleReceiptCard(state: state, boundaryKey: receiptBoundaryKey),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: AppStrings.actionShareReceipt,
                        icon: Icons.ios_share_rounded,
                        onPressed: state.isSharing ? null : onShare,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: SecondaryButton(
                        label: AppStrings.actionPrintReceipt,
                        icon: Icons.print_outlined,
                        onPressed: state.isPrinting ? null : onPrint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                PrimaryButton(label: AppStrings.editSaleDoneAction, onPressed: onDone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}