import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../controllers/sales_bill_preview_controller.dart';
import '../widgets/sale_complete_sheet.dart';
import 'sales_bill_preview_launcher.dart';

/// Sheet width cap on tablets (within the 480–960 range).
const double _sheetMaxWidth = 560;

/// View-layer wiring shared by Payment and Edit Sale Payment: after a sale
/// is saved, loads its invoice and shows the sale-complete sheet with
/// Share / Print / Bill Preview. Each exit callback receives the sheet's
/// context so the caller can pop it before navigating.
void showSaleCompleteSheet(
  BuildContext context, {
  required String billNo,
  required String title,
  required String subtitle,
  required void Function(BuildContext sheetContext) onNewSale,
  required void Function(BuildContext sheetContext) onGoToDashboard,
  void Function(BuildContext sheetContext)? onDone,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: _sheetMaxWidth),
    builder: (sheetContext) => Consumer(
      builder: (consumerContext, ref, _) {
        final provider = salesBillPreviewControllerProvider(billNo);
        final state = ref.watch(provider);
        final controller = ref.read(provider.notifier);

        return SaleCompleteSheet(
          title: title,
          subtitle: subtitle,
          bill: state.bill,
          printedAt: state.printedAt,
          peekReceiptKey: controller.peekReceiptKey,
          isLoading: state.isLoading,
          isSharing: state.isSharing,
          isPrinting: state.isPrinting,
          errorMessage: state.errorMessage,
          onRetry: controller.load,
          onShare: () async {
            final ok = await controller.shareBill(
              boundaryKey: controller.peekReceiptKey,
            );
            if (!ok && consumerContext.mounted) {
              CustomSnackbar.show(
                consumerContext,
                AppStrings.shareFailedMessage,
                error: true,
              );
            }
          },
          onPrint: () => printSalesBill(
            consumerContext,
            controller,
            boundaryKey: controller.peekReceiptKey,
          ),
          onPreview: () => showSalesBillPreview(consumerContext, billNo),
          onNewSale: () => onNewSale(sheetContext),
          onGoToDashboard: () => onGoToDashboard(sheetContext),
          onDone: onDone == null ? null : () => onDone(sheetContext),
        );
      },
    ),
  );
}
