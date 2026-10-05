import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
// import '../../../master_data/data/models/payment_system_model.dart' as ps;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../states/payment_state.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import 'dart:math' as math;
import '../../../../core/utils/error_mapper.dart';
import '../../../cart/presentation/states/cart_state.dart' show CartState, DiscountType;
import '../../../new_sale/presentation/controllers/new_sale_controller.dart';
import '../../data/repositories/payment_repository.dart';

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
  void toggleSystem(pa.PaymentSystem system) {
    final current = List<SelectedPaymentEntry>.from(state.selectedEntries);
    final existingIndex = current.indexWhere((e) => e.system.id == system.id);

    if (existingIndex != -1) {
      current.removeAt(existingIndex);
    } else {
      if (current.length >= PaymentState.maxSelectable) return;

      var entry = SelectedPaymentEntry(system: system);
      // Cash / Reward: no dropdown, so bind their account right away.
      if (!entry.needsAccountPicker) {
        final accounts = accountsForSystem(system);
        if (accounts.isNotEmpty) entry = entry.copyWith(account: accounts.first);
      }
      current.add(entry);
    }

    state = state.copyWith(selectedEntries: _recalculateAmounts(current));
  }

  List<pa.ResultDatum> accountsForSystem(pa.PaymentSystem system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts.where((a) => a.paymentSystem.id == system.id).toList();
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

// TODO: replace these statics once branch / employee come from the
// logged-in session instead of being fixed.
  static const _salesType = '1';
  static const _branchId = '2';
  static const _employeeId = '2';
  static const _deliveryCharge = '0';

  PaymentRepository get _repository => ref.read(paymentRepositoryProvider);

  Future<bool> completeSale() async {
    if (!state.canComplete) return false;
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final result = await _repository.completeSale(_buildSalePayload());
      state = state.copyWith(
        isProcessing: false,
        isSaleCompleted: true,
        salesBillNo: result.salesBillNo,
      );
      // Sale is recorded — empty the cart so back-navigation can't resell it.
      ref.read(newSaleControllerProvider.notifier).clearAll();
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  String _money(double v) => v.toStringAsFixed(2);

  Map<String, dynamic> _buildSalePayload() {
    final cart = ref.read(cartControllerProvider);
    final items = cart.items;
    final payable = _money(state.payableAmount);

    // Percent typed by the seller is sent exactly; an amount-mode discount
    // is converted to a percent with extra precision to avoid cent drift.
    final discountRate = cart.discountType == DiscountType.percent
        ? cart.discountInput.clamp(0.0, 100.0).toStringAsFixed(2)
        : cart.discountPercent.toStringAsFixed(4);
    final vatRate = cart.taxPercent.clamp(0.0, 100.0).toStringAsFixed(2);

    final payments =
    state.selectedEntries.where((e) => e.amount > 0.005).toList();
    final cashReturn = state.cashReturn;

    return {
      'sales_type': _salesType,
      'branch_id': _branchId,
      if (cart.selectedCustomer != null)
        'customer_id': cart.selectedCustomer!.customerNo,
      'employee_id': _employeeId,
      'total_payable_amount': payable,
      'given_amount': payable,
      'total_quantity':
      items.fold<int>(0, (sum, l) => sum + l.quantity).toString(),
      'delivery_charge': _deliveryCharge,
      'product_id_arr': {
        for (var i = 0; i < items.length; i++) '$i': items[i].id,
      },
      'product_quantity_arr': {
        for (var i = 0; i < items.length; i++) '$i': '${items[i].quantity}',
      },
      'prod_dis_rate_arr': {
        for (var i = 0; i < items.length; i++) '$i': discountRate,
      },
      'prod_vat_rate_arr': {
        for (var i = 0; i < items.length; i++) '$i': vatRate,
      },
      'payment_acc_id_arr': {
        for (final e in payments)
          if (e.account != null) '${e.system.id}': '${e.account!.id}',
      },
      'given_amount_arr': {
        for (final e in payments)
          '${e.system.id}': _money(e.isCash ? e.amount - cashReturn : e.amount),
      },
    };
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
