import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/states/cart_state.dart' show CartState;
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../new_sale/presentation/controllers/new_sale_controller.dart';
import '../../data/repositories/payment_repository.dart';
import '../states/payment_state.dart';
import 'payment_split_rules.dart';

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
      subtotal: _round2(cart.subtotal),
      discountAmount: _round2(cart.discountAmount),
      vatAmount: _round2(cart.taxAmount),
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
  /// [PaymentState.maxSelectable]. Amounts are re-derived by
  /// [PaymentSplitRules.onSelectionChanged].
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

    state = state.copyWith(
      selectedEntries:
      PaymentSplitRules.onSelectionChanged(current, state.payableAmount),
    );
  }

  List<pa.ResultDatum> accountsForSystem(pa.PaymentSystem system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts.where((a) => a.paymentSystem.id == system.id).toList();
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }

  /// See [PaymentSplitRules.onAmountEdited]: cash fills an untouched
  /// non-cash side; non-cash never fills cash; change comes from cash.
  void updateAmountForSystem(int systemId, double amount) {
    state = state.copyWith(
      selectedEntries: PaymentSplitRules.onAmountEdited(
        state.selectedEntries,
        systemId: systemId,
        amount: amount,
        payable: state.payableAmount,
      ),
    );
  }

  static const _deliveryCharge = '0';

  PaymentRepository get _repository => ref.read(paymentRepositoryProvider);

  Future<bool> completeSale() async {
    if (!state.canComplete) return false;
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final result = await _repository.completeSale(_buildSalePayload());
      if (!ref.mounted) return true;
      state = state.copyWith(
        isProcessing: false,
        isSaleCompleted: true,
        salesBillNo: result.salesBillNo,
      );
      // Sale is recorded — empty the cart so back-navigation can't resell it.
      ref.read(newSaleControllerProvider.notifier).clearAll();
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
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

    final vatRate = cart.taxPercent.clamp(0.0, 100.0).toStringAsFixed(2);

    final cashReturn = state.cashReturn;
    // Net 0 (e.g. all the cash was returned as change) is not a payment.
    final payments = state.selectedEntries
        .where((e) => PaymentSplitRules.netAmount(e, cashReturn) > 0.005)
        .toList();

    return {
      // sales_type / branch_id / employee_id: set by PaymentRepository.
      if (cart.selectedCustomer != null)
        'customer_id': cart.selectedCustomer!.customerNo,
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
        for (var i = 0; i < items.length; i++)
          '$i': cart.lineDiscountRate(items[i]).toStringAsFixed(4),
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
          '${e.system.id}': _money(PaymentSplitRules.netAmount(e, cashReturn)),
      },
    };
  }

  Future<bool> shareReceipt(GlobalKey boundaryKey) async {
    state = state.copyWith(isSharing: true, shareError: null);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId:
        state.salesBillNo ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(
          isSharing: false,
          shareError: 'shareFailedMessage',
        );
      }
      return false;
    }
  }

  Future<bool> printReceipt(String printerMac) async {
    state = state.copyWith(isPrinting: true, printError: null);
    try {
      final connected = await ThermalPrinterService.isConnected() ||
          await ThermalPrinterService.connect(printerMac);
      final success = connected &&
          await ThermalPrinterService.printReceipt(
            storeName: AppStrings.appBrandName,
            billNo: state.salesBillNo,
            saleDate: state.saleDate,
            methodLabel: state.methodLabel,
            items: state.receiptItems,
            total: state.payableAmount,
            givenAmount: state.totalCollected,
            changeDue: state.cashReturn,
            subtotal: state.subtotal,
            discount: state.discountAmount,
            vat: state.vatAmount,
          );
      if (ref.mounted) {
        state = state.copyWith(
          isPrinting: false,
          printError: success ? null : 'printFailedMessage',
        );
      }
      return success;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(
          isPrinting: false,
          printError: 'printFailedMessage',
        );
      }
      return false;
    }
  }
}