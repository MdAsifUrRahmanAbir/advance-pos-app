import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_placeholder.dart';
import 'sale_complete_actions.dart';
import 'sale_complete_header.dart';
import 'sale_complete_summary_card.dart';
import 'sales_bill_receipt_peek.dart';

/// Shown after a sale is created or updated. Loads the real invoice
/// (`GET /sales/invoice`) and shows its summary plus a receipt peek, with
/// Share / Print / Preview and the exit actions. It can't be swiped or
/// back-buttoned away — the exit buttons are the only way out.
class SaleCompleteSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final SalesBillPreviewModel? bill;
  final DateTime? printedAt;
  final GlobalKey peekReceiptKey;
  final bool isLoading;
  final bool isSharing;
  final bool isPrinting;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onPreview;
  final VoidCallback onNewSale;
  final VoidCallback onGoToDashboard;
  final VoidCallback? onDone;

  const SaleCompleteSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bill,
    required this.printedAt,
    required this.peekReceiptKey,
    required this.isLoading,
    required this.isSharing,
    required this.isPrinting,
    required this.errorMessage,
    required this.onRetry,
    required this.onShare,
    required this.onPrint,
    required this.onPreview,
    required this.onNewSale,
    required this.onGoToDashboard,
    this.onDone,
  });

  /// Sheet may use up to this share of the screen height — flagged.
  static const double _maxHeightFactor = 0.92;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loaded = bill != null;
    final hasError = !loaded && !isLoading && errorMessage != null;
    final shown = bill ?? SalesBillPreviewPlaceholder.bill;

    return PopScope(
      canPop: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
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
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.lg,
              AppSizes.md,
              AppSizes.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SaleCompleteHeader(title: title, subtitle: subtitle),
                const SizedBox(height: AppSizes.lg),
                if (hasError)
                  ErrorState(
                    message: AppStrings.saleDoneBillLoadFailed,
                    retryLabel: AppStrings.retry,
                    onRetry: onRetry,
                  )
                else ...[
                  SaleCompleteSummaryCard(bill: shown)
                      .skeletonizer(enabled: !loaded),
                  const SizedBox(height: AppSizes.sm),
                  SalesBillReceiptPeek(
                    bill: shown,
                    printedAt: printedAt,
                    boundaryKey: peekReceiptKey,
                    onViewFull: loaded ? onPreview : null,
                  ).skeletonizer(enabled: !loaded),
                ],
                const SizedBox(height: AppSizes.md),
                SaleCompleteActions(
                  isSharing: isSharing,
                  isPrinting: isPrinting,
                  onShare: loaded ? onShare : null,
                  onPrint: loaded ? onPrint : null,
                  onPreview: loaded ? onPreview : null,
                  onNewSale: onNewSale,
                  onGoToDashboard: onGoToDashboard,
                  onDone: onDone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
