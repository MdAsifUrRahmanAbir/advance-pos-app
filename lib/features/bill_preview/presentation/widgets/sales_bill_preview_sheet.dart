import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_placeholder.dart';
import 'sales_bill_receipt.dart';

/// Bottom sheet holding the thermal receipt with Save, Share and Print.
/// Save and Share use the receipt as a PNG image.
/// Skeleton while [bill] is null and loading; ErrorState when it failed.
class SalesBillPreviewSheet extends StatelessWidget {
  final SalesBillPreviewModel? bill;
  final DateTime? printedAt;
  final GlobalKey receiptKey;
  final bool isLoading;
  final bool isPrinting;
  final bool isSharing;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const SalesBillPreviewSheet({
    super.key,
    required this.bill,
    required this.printedAt,
    required this.receiptKey,
    required this.isLoading,
    required this.isPrinting,
    required this.isSharing,
    required this.isSaving,
    required this.errorMessage,
    required this.onRetry,
    required this.onPrint,
    required this.onShare,
    required this.onSave,
  });

  /// Sheet may use up to this share of the screen height — flagged.
  static const double _maxHeightFactor = 0.9;

  /// Drag handle bar width — flagged, no token.
  static const double _handleWidth = 40;

  @override
  Widget build(BuildContext context) {
    final hasError = bill == null && !isLoading && errorMessage != null;
    final maxHeight = MediaQuery.sizeOf(context).height * _maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: _handleWidth,
              height: AppSizes.xs,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            Flexible(
              child: hasError
                  ? ErrorState(
                message: errorMessage ?? AppStrings.billLoadFailed,
                retryLabel: AppStrings.retry,
                onRetry: onRetry,
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Center(
                  child: SalesBillReceipt(
                    bill: bill ?? SalesBillPreviewPlaceholder.bill,
                    printedAt: printedAt,
                    boundaryKey: receiptKey,
                  ).skeletonizer(enabled: bill == null),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: AppStrings.billSaveAction,
                      icon: Icons.download_rounded,
                      onPressed: bill == null || isSaving ? null : onSave,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: SecondaryButton(
                      label: AppStrings.invoiceShareAction,
                      icon: Icons.ios_share_rounded,
                      onPressed: bill == null || isSharing ? null : onShare,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: AppStrings.billPrintAction,
                      icon: Icons.print_outlined,
                      loading: isPrinting,
                      onPressed: bill == null ? null : onPrint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
