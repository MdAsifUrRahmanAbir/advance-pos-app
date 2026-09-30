import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/data/models/payment_system_model.dart' as ps;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../states/payment_state.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/states/cart_state.dart' show CartState;
import 'dart:math' as math;

final paymentControllerProvider =
    NotifierProvider.autoDispose<PaymentController, PaymentState>(
      PaymentController.new,
    );

class PaymentController extends Notifier<PaymentState> {

  @override
  PaymentState build() {
    final cart = ref.read(cartControllerProvider);
    return PaymentState().copyWith(
      payableAmount: _round2(cart.totalPayable),
      saleDate: _formatDate(DateTime.now()),
      receiptItems: _receiptItemsFrom(cart),
    );
  }

  double _round2(double v) => (v * 100).round() / 100;

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  List<ReceiptLineItem> _receiptItemsFrom(CartState cart) => [
    for (final line in cart.items)
      ReceiptLineItem(
        name: line.name,
        quantity: line.quantity,
        lineTotal: line.lineTotal,
      ),
  ];

  /// Selects/deselects a payment system, capped at
  /// [PaymentState.maxSelectable]. Re-derives every selected entry's
  /// amount afterward (see [_recalculateAmounts]).
  void toggleSystem(ps.ResultDatum system) {
    final current = List<SelectedPaymentEntry>.from(state.selectedEntries);
    final existingIndex = current.indexWhere((e) => e.system.id == system.id);

    if (existingIndex != -1) {
      current.removeAt(existingIndex);
    } else {
      if (current.length >= PaymentState.maxSelectable) return;
      current.add(SelectedPaymentEntry(system: system));
    }

    state = state.copyWith(selectedEntries: _recalculateAmounts(current));
  }

  /// - 1 entry selected -> defaults to the full payable amount (locked
  ///   in the UI afterward if that entry is non-cash).
  /// - 2 entries selected -> starting 50/50 split, both editable.
  List<SelectedPaymentEntry> _recalculateAmounts(
    List<SelectedPaymentEntry> entries,
  ) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) {
      return [entries.first.copyWith(amount: state.payableAmount)];
    }
    final half = state.payableAmount / 2;
    return entries.map((e) => e.copyWith(amount: half)).toList();
  }

  /// Accounts come from cached master data, filtered by shortName — swap
  /// to `a.paymentSystemId == system.id` if two systems ever share a
  /// shortName in practice.
  List<pa.ResultDatum> accountsForSystem(ps.ResultDatum system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts
        .where((a) => a.paymentSystem.shortName == system.shortName)
        .toList();
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }


  /// Editing one amount auto-fills the other (when two methods are
  /// selected) with `payable - edited`, never below 0. Non-cash amounts
  /// are capped at the payable amount; cash may exceed it (that's the
  /// "given" amount, and the difference is returned as change).
  void updateAmountForSystem(int systemId, double amount) {
    final payable = state.payableAmount;
    final entries = state.selectedEntries;
    final edited = entries.where((e) => e.system.id == systemId).firstOrNull;
    if (edited == null) return;

    var value = amount < 0 ? 0.0 : amount;
    if (!edited.isCash) value = math.min(value, payable);

    final other = entries.length == 2
        ? entries.firstWhere((e) => e.system.id != systemId)
        : null;
    final complement = _round2(math.max(payable - value, 0));

    state = state.copyWith(
      selectedEntries: [
        for (final e in entries)
          if (e.system.id == systemId)
            e.copyWith(amount: value)
          else if (other != null && e.system.id == other.system.id)
            e.copyWith(amount: complement)
          else
            e,
      ],
    );
  }

  Future<bool> completeSale() async {
    if (!state.canComplete) {
      state = state.copyWith(errorMessage: 'errorGivenAmountInsufficient');
      return false;
    }
    state = state.copyWith(isProcessing: true, errorMessage: null);

    // TODO: wire to paymentRepositoryProvider.completeSale(...) once the
    // payment/data/repositories layer supports sale creation — submit
    // state.selectedEntries (system id, account id, amount each)
    // alongside the sale/cart payload.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(isProcessing: false);
    return true;
  }

  Future<bool> shareReceipt(GlobalKey boundaryKey) async {
    state = state.copyWith(isSharing: true, shareError: null);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId: DateTime.now().millisecondsSinceEpoch.toString(),
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
        // saleId: state.saleId,
        saleDate: state.saleDate,
        methodLabel: state.methodLabel,
        items: state.receiptItems,
        total: state.payableAmount,
        givenAmount: state.totalCollected,
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
