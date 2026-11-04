import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../data/repositories/bill_preview_repository.dart';
import '../states/sales_bill_preview_state.dart';

/// Family arg: the sales bill number to preview.
final salesBillPreviewControllerProvider = NotifierProvider.autoDispose
    .family<SalesBillPreviewController, SalesBillPreviewState, String>(
  SalesBillPreviewController.new,
);

/// Loads `GET /sales/invoice/:billNo`, then prints / shares the thermal
/// receipt. Printing captures an on-screen receipt as an image, so the
/// paper is the same as the preview.
class SalesBillPreviewController extends Notifier<SalesBillPreviewState> {
  SalesBillPreviewController(this.billNo);

  final String billNo;

  /// RepaintBoundary key of the full receipt in the Bill Preview sheet.
  final GlobalKey receiptKey = GlobalKey();

  /// RepaintBoundary key of the receipt peek in the sale-complete sheet.
  /// Separate from [receiptKey] because both sheets can be open at once.
  final GlobalKey peekReceiptKey = GlobalKey();

  /// Only the latest load (first load or retry) may write state.
  int _requestSeq = 0;

  BillPreviewRepository get _repository =>
      ref.read(billPreviewRepositoryProvider);

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

  /// Prints the receipt under [boundaryKey] (defaults to [receiptKey]) on
  /// the chosen Bluetooth printer.
  Future<bool> printBill(String printerMac, {GlobalKey? boundaryKey}) async {
    if (state.isPrinting || state.bill == null) return false;
    state = state.copyWith(isPrinting: true);
    try {
      final image =
          await ReceiptShareService.captureAsPng(boundaryKey ?? receiptKey);
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

  /// Shares the receipt under [boundaryKey] (defaults to [receiptKey]) as
  /// a PNG image through the system share sheet (email, social apps…).
  /// [origin] anchors the share popover on iPad.
  Future<bool> shareBill({GlobalKey? boundaryKey, Rect? origin}) async {
    if (state.isSharing || state.bill == null) return false;
    state = state.copyWith(isSharing: true);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey ?? receiptKey,
        saleId: billNo,
        subject: AppStrings.billShareSubject(billNo),
        text: AppStrings.billShareText(billNo),
        sharePositionOrigin: origin,
      );
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return false;
    }
  }

  /// Saves the receipt under [boundaryKey] (defaults to [receiptKey]) as a
  /// PNG to the gallery. False when photo access is denied or it fails.
  Future<bool> saveBill({GlobalKey? boundaryKey}) async {
    if (state.isSaving || state.bill == null) return false;
    state = state.copyWith(isSaving: true);
    try {
      final saved = await ReceiptShareService.saveReceiptImage(
        boundaryKey: boundaryKey ?? receiptKey,
        saleId: billNo,
      );
      if (ref.mounted) state = state.copyWith(isSaving: false);
      return saved;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isSaving: false);
      return false;
    }
  }
}
