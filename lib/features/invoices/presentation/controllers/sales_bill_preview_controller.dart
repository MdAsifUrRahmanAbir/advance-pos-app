import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../data/repositories/invoices_repository.dart';
import '../states/sales_bill_preview_state.dart';

/// Family arg: the sales bill number to preview.
final salesBillPreviewControllerProvider = NotifierProvider.autoDispose
    .family<SalesBillPreviewController, SalesBillPreviewState, String>(
  SalesBillPreviewController.new,
);

/// Loads `GET /sales/invoice/:billNo` and prints the receipt. Printing
/// captures the on-screen receipt ([receiptKey]) as an image, so the paper
/// is the same as the preview.
class SalesBillPreviewController extends Notifier<SalesBillPreviewState> {
  SalesBillPreviewController(this.billNo);

  final String billNo;

  /// Key of the RepaintBoundary that wraps the receipt paper.
  final GlobalKey receiptKey = GlobalKey();

  /// Only the latest load (first load or retry) may write state.
  int _requestSeq = 0;

  InvoicesRepository get _repository => ref.read(invoicesRepositoryProvider);

  @override
  SalesBillPreviewState build() {
    Future.microtask(load);
    return const SalesBillPreviewState(isLoading: true);
  }

  Future<bool> load() async {
    final seq = ++_requestSeq;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bill = await _repository.getSalesBillPreview(billNo);
      if (!ref.mounted || seq != _requestSeq) return false;
      state = state.copyWith(
        isLoading: false,
        bill: bill,
        printedAt: DateTime.now(),
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _requestSeq) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  /// Prints the previewed receipt on the chosen Bluetooth printer.
  Future<bool> printBill(String printerMac) async {
    if (state.isPrinting || state.bill == null) return false;
    state = state.copyWith(isPrinting: true);
    try {
      final image = await ReceiptShareService.captureAsPng(receiptKey);
      final connected = await ThermalPrinterService.isConnected() ||
          await ThermalPrinterService.connect(printerMac);
      final printed =
          connected && await ThermalPrinterService.printImage(image);
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return printed;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return false;
    }
  }
}