import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/fly_to_target.dart' show globalRectOf;
import '../../../../core/widgets/utility/printer_selection_sheet.dart';
import '../controllers/sales_bill_preview_controller.dart';
import '../widgets/sales_bill_preview_sheet.dart';

/// Sheet width cap on tablets (within the 480–960 range).
const double _sheetMaxWidth = 560;

/// Common entry point for any screen that shows a sales bill (Invoices,
/// Invoice Detail, Payment, Edit Sale): opens the Bill Preview receipt in
/// a bottom sheet and runs the Share / Print flows. The controller is
/// autoDispose, so closing the last sheet that watches it disposes it.
void showSalesBillPreview(BuildContext context, String billNo) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: _sheetMaxWidth),
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final provider = salesBillPreviewControllerProvider(billNo);
        final state = ref.watch(provider);
        final controller = ref.read(provider.notifier);

        return SalesBillPreviewSheet(
          bill: state.bill,
          printedAt: state.printedAt,
          receiptKey: controller.receiptKey,
          isLoading: state.isLoading,
          isPrinting: state.isPrinting,
          isSharing: state.isSharing,
          isSaving: state.isSaving,
          errorMessage: state.errorMessage,
          onRetry: controller.load,
          onPrint: () => printSalesBill(context, controller),
          onShare: () async {
            final ok =
            await controller.shareBill(origin: globalRectOf(context));
            if (!ok && context.mounted) {
              CustomSnackbar.show(
                context,
                AppStrings.shareFailedMessage,
                error: true,
              );
            }
          },
          onSave: () async {
            final ok = await controller.saveBill();
            if (!context.mounted) return;
            CustomSnackbar.show(
              context,
              ok ? AppStrings.billSavedMessage : AppStrings.billSaveFailed,
              error: !ok,
            );
          },
        );
      },
    ),
  );
}

/// Picks a paired printer, prints the receipt under [boundaryKey]
/// (defaults to the Bill Preview receipt) and shows the result snackbar.
Future<void> printSalesBill(
    BuildContext context,
    SalesBillPreviewController controller, {
      GlobalKey? boundaryKey,
    }) async {
  final device = await showModalBottomSheet<BluetoothInfo>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PrinterSelectionSheet(),
  );
  if (device == null || !context.mounted) return;
  final printed =
  await controller.printBill(device.macAdress, boundaryKey: boundaryKey);
  if (!context.mounted) return;
  CustomSnackbar.show(
    context,
    printed ? AppStrings.printSuccessMessage : AppStrings.printFailedMessage,
    error: !printed,
  );
}