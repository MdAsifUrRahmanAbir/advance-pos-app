import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../payment/presentation/widgets/printer_selection_sheet.dart';
import '../controllers/sales_bill_preview_controller.dart';
import '../widgets/sales_bill_preview_sheet.dart';

/// Sheet width cap on tablets (within the 480–960 range).
const double _sheetMaxWidth = 560;

/// View-layer wiring shared by the Invoices mobile and tab views: opens the
/// Bill Preview receipt in a bottom sheet and runs the Print flow.
/// The controller is autoDispose, so closing the sheet disposes it.
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
          errorMessage: state.errorMessage,
          onRetry: controller.load,
          onPrint: () => _printBill(context, controller),
        );
      },
    ),
  );
}

Future<void> _printBill(
    BuildContext context,
    SalesBillPreviewController controller,
    ) async {
  final device = await showModalBottomSheet<BluetoothInfo>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PrinterSelectionSheet(),
  );
  if (device == null || !context.mounted) return;
  final printed = await controller.printBill(device.macAdress);
  if (!context.mounted) return;
  CustomSnackbar.show(
    context,
    printed ? AppStrings.printSuccessMessage : AppStrings.printFailedMessage,
    error: !printed,
  );
}