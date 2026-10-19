import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/session_profile.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../cart/presentation/states/cart_state.dart';
import '../../../edit_sale_cart/presentation/controllers/edit_sale_cart_controller.dart';
import '../../../invoice_detail/data/models/sale_amounts.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem, SelectedPaymentEntry;
import '../../../payment/presentation/states/payment_systems_from_accounts.dart';
import '../../data/repositories/edit_sale_payment_repository.dart';
import '../states/edit_sale_payment_state.dart';

/// Family arg: the sales bill number being edited.
final editSalePaymentControllerProvider = NotifierProvider.autoDispose
    .family<EditSalePaymentController, EditSalePaymentState, String>(
  EditSalePaymentController.new,
);

/// Payment step of Edit Sale. Reads the finished cart from
/// [editSaleCartControllerProvider] (same bill no), pre-fills the
/// invoice's original payment methods, and sends `PUT /sales/edit/:billNo`.
///
/// Selection/split rules are the same as the regular Payment screen;
/// the payment feature itself is not touched.
class EditSalePaymentController extends Notifier<EditSalePaymentState> {
  EditSalePaymentController(this.billNo);

  final String billNo;

  /// Retail sales — the Invoices list and detail endpoints use the same.
  static const String _salesType = '1';
  static const String _deliveryCharge = '0';

  bool _prefillDone = false;

  EditSalePaymentRepository get _repository =>
      ref.read(editSalePaymentRepositoryProvider);

  @override
  EditSalePaymentState build() {
    final edit = ref.read(editSaleCartControllerProvider(billNo));
    final cart = edit.cart;
    final sale = edit.invoice?.sale;

    // Master data may still be loading when this page opens — pre-fill
    // as soon as payment accounts arrive.
    ref.listen(masterDataControllerProvider, (_, next) {
      if (next.paymentAccounts.isNotEmpty) _prefillFromInvoice();
    });
    Future.microtask(() {
      if (ref.mounted) _prefillFromInvoice();
    });

    return EditSalePaymentState(
      billNo: billNo,
      payableAmount: _round2(cart.totalPayable),
      subtotal: _round2(cart.subtotal),
      discountAmount: _round2(cart.discountAmount),
      vatAmount: _round2(cart.taxAmount),
      originalPayable: sale?.totalPayableAmountValue ?? 0,
      originalPaid: sale?.paidAmountValue ?? 0,
      saleDate: sale?.salesDate ?? '',
      receiptItems: [
        for (final line in cart.items)
          ReceiptLineItem(
            name: line.name,
            quantity: line.quantity,
            lineTotal: line.lineTotal,
          ),
      ],
    );
  }

  double _round2(double v) => (v * 100).round() / 100;
  String _money(double v) => v.toStringAsFixed(2);

  // ───────────────────────────────────────────────
  // Pre-fill from the original invoice
  // ───────────────────────────────────────────────
  void _prefillFromInvoice() {
    if (_prefillDone || state.selectedEntries.isNotEmpty) return;
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    if (accounts.isEmpty) return;
    _prefillDone = true;

    final invoice = ref.read(editSaleCartControllerProvider(billNo)).invoice;
    if (invoice == null) return;

    final systems = paymentSystemsFrom(accounts);
    final usedAccountIds =
    invoice.payment.paymentAccounts.map((a) => a.id.trim()).toSet();

    final entries = <SelectedPaymentEntry>[];
    final originalAmounts = <double>[];
    for (final collected in invoice.payment.collection) {
      if (entries.length >= EditSalePaymentState.maxSelectable) break;
      final system =
          systems.where((s) => s.id == collected.paymentSystemId).firstOrNull;
      if (system == null || entries.any((e) => e.system.id == system.id)) continue;

      var entry = SelectedPaymentEntry(system: system);
      final candidates = accountsForSystem(system);
      final account = candidates
          .where((a) => usedAccountIds.contains(a.id.toString()))
          .firstOrNull ??
          (!entry.needsAccountPicker || candidates.length == 1
              ? candidates.firstOrNull
              : null);
      if (account != null) entry = entry.copyWith(account: account);
      entries.add(entry);
      originalAmounts.add(collected.amount);
    }
    if (entries.isEmpty) return;

    final payable = state.payableAmount;
    final List<SelectedPaymentEntry> withAmounts;
    if (entries.length == 1) {
      withAmounts = [entries.first.copyWith(amount: payable)];
    } else {
      // Keep the original first-method amount where it still fits; the
      // second method covers the rest of the new total.
      final first = _round2(math.min(originalAmounts.first, payable));
      withAmounts = [
        entries[0].copyWith(amount: first),
        entries[1].copyWith(amount: _round2(math.max(payable - first, 0))),
      ];
    }
    state = state.copyWith(selectedEntries: withAmounts, prefilledFromInvoice: true);
  }

  // ───────────────────────────────────────────────
  // Payment selection (same rules as PaymentController)
  // ───────────────────────────────────────────────
  List<pa.ResultDatum> accountsForSystem(pa.PaymentSystem system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts.where((a) => a.paymentSystem.id == system.id).toList();
  }

  void toggleSystem(pa.PaymentSystem system) {
    _prefillDone = true; // the salesman took over — never overwrite
    final current = List<SelectedPaymentEntry>.from(state.selectedEntries);
    final index = current.indexWhere((e) => e.system.id == system.id);

    if (index != -1) {
      current.removeAt(index);
    } else {
      if (current.length >= EditSalePaymentState.maxSelectable) return;
      var entry = SelectedPaymentEntry(system: system);
      // Cash / Reward have no dropdown — bind their account right away.
      if (!entry.needsAccountPicker) {
        final accounts = accountsForSystem(system);
        if (accounts.isNotEmpty) entry = entry.copyWith(account: accounts.first);
      }
      current.add(entry);
    }
    state = state.copyWith(selectedEntries: _recalculateAmounts(current), clearError: true);
  }

  /// 1 entry → full payable; 2 entries → 50/50 starting split.
  List<SelectedPaymentEntry> _recalculateAmounts(List<SelectedPaymentEntry> entries) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) {
      return [entries.first.copyWith(amount: state.payableAmount)];
    }
    final half = _round2(state.payableAmount / 2);
    return [
      entries[0].copyWith(amount: half),
      entries[1].copyWith(amount: _round2(state.payableAmount - half)),
    ];
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }

  /// Editing one amount auto-fills the other with `payable - edited`
  /// (never below 0). Non-cash is capped at payable; cash may exceed it
  /// (the difference is change).
  void updateAmountForSystem(int systemId, double amount) {
    final payable = state.payableAmount;
    final entries = state.selectedEntries;
    final edited = entries.where((e) => e.system.id == systemId).firstOrNull;
    if (edited == null) return;

    var value = amount < 0 ? 0.0 : amount;
    if (!edited.isCash) value = math.min(value, payable);
    final complement = _round2(math.max(payable - value, 0));

    state = state.copyWith(
      selectedEntries: [
        for (final e in entries)
          if (e.system.id == systemId)
            e.copyWith(amount: value)
          else if (entries.length == 2)
            e.copyWith(amount: complement)
          else
            e,
      ],
    );
  }

  // ───────────────────────────────────────────────
  // PUT /sales/edit/:billNo
  // ───────────────────────────────────────────────
  Future<bool> updateSale() async {
    if (!state.canSubmit) return false;
    final profile = ref.read(sessionProfileProvider);
    if (profile == null) {
      state = state.copyWith(errorMessage: AppStrings.editSaleNotSignedIn);
      return false;
    }

    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final payload = _buildPayload(profile);
      final result = await _repository.updateSale(billNo, payload);
      if (!ref.mounted) return true;
      state = state.copyWith(
        isUpdating: false,
        isUpdated: true,
        updatedBillNo: (result.salesBillNo?.isNotEmpty ?? false)
            ? result.salesBillNo
            : billNo,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isUpdating: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  Map<String, dynamic> _buildPayload(SessionProfile profile) {
    final CartState cart = ref.read(editSaleCartControllerProvider(billNo)).cart;
    final items = cart.items;
    final vatRate = cart.taxPercent.clamp(0.0, 100.0).toStringAsFixed(2);
    final payments = state.selectedEntries.where((e) => e.amount > 0.005).toList();
    final cashReturn = state.cashReturn;

    return {
      'sales_type': _salesType,
      'branch_id': '${profile.branchId}',
      if (cart.selectedCustomer != null)
        'customer_id': cart.selectedCustomer!.customerNo,
      'employee_id': '${profile.employeeId}',
      'total_payable_amount': _money(state.payableAmount),
      'given_amount': _money(state.netCollected),
      'total_quantity': items.fold<int>(0, (sum, l) => sum + l.quantity).toString(),
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
          '${e.system.id}': _money(e.isCash ? e.amount - cashReturn : e.amount),
      },
    };
  }

  // ───────────────────────────────────────────────
  // Receipt
  // ───────────────────────────────────────────────
  Future<bool> shareReceipt(GlobalKey boundaryKey) async {
    state = state.copyWith(isSharing: true);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId: state.updatedBillNo ?? billNo,
      );
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return false;
    }
  }

  Future<bool> printReceipt(String printerMac) async {
    state = state.copyWith(isPrinting: true);
    try {
      final connected = await ThermalPrinterService.isConnected() ||
          await ThermalPrinterService.connect(printerMac);
      final success = connected &&
          await ThermalPrinterService.printReceipt(
            storeName: AppStrings.appBrandName,
            billNo: state.updatedBillNo ?? billNo,
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
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return success;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return false;
    }
  }
}