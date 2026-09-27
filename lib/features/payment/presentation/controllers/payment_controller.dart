import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../data/models/payment_accounts_model.dart' as pa;
import '../../data/models/payment_system_model.dart' as ps;
import '../../data/repositories/payment_repository.dart';
import '../states/payment_state.dart';

final paymentControllerProvider =
NotifierProvider.autoDispose<PaymentController, PaymentState>(PaymentController.new);

class PaymentController extends Notifier<PaymentState> {
  PaymentRepository get _repository => ref.read(paymentRepositoryProvider);

  @override
  PaymentState build() {
    Future.microtask(loadPaymentMethods);

    // TODO: wire to paymentRepositoryProvider.getPendingSale(saleId) once
    // the payment/data/repositories layer is ready. Currently mock data
    // matching the in-progress New Sale cart.
    return const PaymentState().copyWith(
      payableAmount: 1341.88,
      saleId: '#SL00100001',
      saleDate: '09/06/2026',
      salesAgent: 'Admin',
      availableAgents: ['Admin', 'Rahul Sharma', 'Amit Patel'],
      receiptItems: const [
        ReceiptLineItem(name: 'Quantum Wireless Mouse', quantity: 2, lineTotal: 900.00),
        ReceiptLineItem(name: 'Minimalist Leather Backpack', quantity: 1, lineTotal: 300.00),
        ReceiptLineItem(name: 'Smart LED Lamp', quantity: 1, lineTotal: 50.00),
      ],
    );
  }

  // --- Payment systems / accounts ---

  Future<void> loadPaymentMethods() async {
    state = state.copyWith(isPaymentMethodsLoading: true, paymentMethodsErrorMessage: null);
    try {
      final systems = await _repository.getPaymentSystems();
      final accounts = await _repository.getPaymentAccounts();
      state = state.copyWith(
        isPaymentMethodsLoading: false,
        paymentSystems: systems.resultData,
        paymentAccounts: accounts.resultData,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isPaymentMethodsLoading: false,
        paymentMethodsErrorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

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
  List<SelectedPaymentEntry> _recalculateAmounts(List<SelectedPaymentEntry> entries) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) {
      return [entries.first.copyWith(amount: state.payableAmount)];
    }
    final half = state.payableAmount / 2;
    return entries.map((e) => e.copyWith(amount: half)).toList();
  }

  /// Filtered by shortName, per the accounts endpoint's shape — swap to
  /// `a.paymentSystemId == system.id` if two systems ever share a
  /// shortName in practice.
  List<pa.ResultDatum> accountsForSystem(ps.ResultDatum system) {
    return state.paymentAccounts.where((a) => a.paymentSystem.shortName == system.shortName).toList();
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }

  void updateAmountForSystem(int systemId, double amount) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(amount: amount) else e,
      ],
    );
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
      await ReceiptShareService.shareReceiptImage(boundaryKey: boundaryKey, saleId: state.saleId);
      state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSharing: false, shareError: 'shareFailedMessage');
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
          state = state.copyWith(isPrinting: false, printError: 'printFailedMessage');
          return false;
        }
      }
      final success = await ThermalPrinterService.printReceipt(
        storeName: 'POS Pro', // TODO: source from store settings once available
        saleId: state.saleId,
        saleDate: state.saleDate,
        methodLabel: state.methodLabel,
        items: state.receiptItems,
        total: state.payableAmount,
        givenAmount: state.totalCollected,
        changeDue: state.changeDue,
      );
      state = state.copyWith(isPrinting: false, printError: success ? null : 'printFailedMessage');
      return success;
    } catch (_) {
      state = state.copyWith(isPrinting: false, printError: 'printFailedMessage');
      return false;
    }
  }
}