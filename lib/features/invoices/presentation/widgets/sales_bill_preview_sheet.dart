import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_placeholder.dart';
import 'sales_bill_customer_section.dart';
import 'sales_bill_footer_section.dart';
import 'sales_bill_header_section.dart';
import 'sales_bill_items_section.dart';
import 'sales_bill_paper.dart';
import 'sales_bill_summary_section.dart';

/// Bottom sheet holding only the thermal receipt and a Print button.
/// Skeleton while [bill] is null and loading; ErrorState when it failed.
class SalesBillPreviewSheet extends StatelessWidget {
  final SalesBillPreviewModel? bill;
  final DateTime? printedAt;
  final GlobalKey receiptKey;
  final bool isLoading;
  final bool isPrinting;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onPrint;

  const SalesBillPreviewSheet({
    super.key,
    required this.bill,
    required this.printedAt,
    required this.receiptKey,
    required this.isLoading,
    required this.isPrinting,
    required this.errorMessage,
    required this.onRetry,
    required this.onPrint,
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
                  child: _receipt(
                    bill ?? SalesBillPreviewPlaceholder.bill,
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
    );
  }

  Widget _receipt(SalesBillPreviewModel bill) {
    return SalesBillPaper(
      boundaryKey: receiptKey,
      children: [
        SalesBillHeaderSection(
          company: bill.company,
          branch: bill.branch,
          counter: bill.counter,
          invoice: bill.invoice,
          printedAt: printedAt,
        ),
        SalesBillItemsSection(rows: bill.productRowData),
        SalesBillSummarySection(summary: bill.summary, payments: bill.payments),
        SalesBillCustomerSection(
          customer: bill.customer,
          employee: bill.employee,
        ),
        SalesBillFooterSection(
          billNo: bill.invoice.salesBillNo,
          config: bill.config,
        ),
      ],
    );
  }
}