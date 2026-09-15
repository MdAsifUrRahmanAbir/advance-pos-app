import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../states/payment_state.dart';

final paymentControllerProvider =
    NotifierProvider.autoDispose<PaymentController, PaymentState>(
      PaymentController.new,
    );

class PaymentController extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    // TODO: wire to paymentRepositoryProvider.getPendingSale(saleId) once
    // the payment/data/repositories layer is ready. Currently mock data
    // matching the in-progress New Sale cart.
    return const PaymentState().copyWith(
      payableAmount: 1341.88,
      saleId: '#SL00100001',
      saleDate: '09/06/2026',
      givenAmount: 1500.00,
      salesAgent: 'Admin',
      availableAgents: ['Admin', 'Rahul Sharma', 'Amit Patel'],
      receiptItems: const [
        ReceiptLineItem(
          name: 'Quantum Wireless Mouse',
          quantity: 2,
          lineTotal: 900.00,
        ),
        ReceiptLineItem(
          name: 'Minimalist Leather Backpack',
          quantity: 1,
          lineTotal: 300.00,
        ),
        ReceiptLineItem(name: 'Smart LED Lamp', quantity: 1, lineTotal: 50.00),
      ],
    );
  }

  void selectMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void updateGivenAmount(double amount) {
    state = state.copyWith(givenAmount: amount, errorMessage: null);
  }

  void selectAgent(String agent) {
    state = state.copyWith(salesAgent: agent);
  }

  Future<bool> completeSale() async {
    if (!state.canComplete) {
      state = state.copyWith(errorMessage: 'errorGivenAmountInsufficient');
      return false;
    }
    state = state.copyWith(isProcessing: true, errorMessage: null);

    // TODO: wire to paymentRepositoryProvider.completeSale(...) once the
    // payment/data/repositories layer is ready.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(isProcessing: false);
    return true;
  }

  /// Captures the receipt widget (via [boundaryKey]) and opens the share
  /// sheet. Returns true on success; view layer shows any snackbar.
  Future<bool> shareReceipt(GlobalKey boundaryKey) async {
    state = state.copyWith(isSharing: true, shareError: null);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId: state.saleId,
      );
      state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSharing: false,
        shareError: 'shareFailedMessage',
      );
      return false;
    }
  }

  /// Sends the receipt to [printerMac] over Bluetooth ESC/POS.
  /// Returns true on success; view layer shows any snackbar.
  Future<bool> printReceipt(String printerMac) async {
    state = state.copyWith(isPrinting: true, printError: null);
    try {
      final connected = await ThermalPrinterService.isConnected();
      if (!connected) {
        final ok = await ThermalPrinterService.connect(printerMac);
        if (!ok) {
          state = state.copyWith(
            isPrinting: false,
            printError: 'printFailedMessage',
          );
          return false;
        }
      }
      final success = await ThermalPrinterService.printReceipt(
        storeName: 'POS Pro', // TODO: source from store settings once available
        saleId: state.saleId,
        saleDate: state.saleDate,
        method: state.selectedMethod,
        items: state.receiptItems,
        total: state.payableAmount,
        givenAmount: state.givenAmount,
        changeDue: state.changeDue,
      );
      state = state.copyWith(
        isPrinting: false,
        printError: success ? null : 'printFailedMessage',
      );
      return success;
    } catch (_) {
      state = state.copyWith(
        isPrinting: false,
        printError: 'printFailedMessage',
      );
      return false;
    }
  }
}
