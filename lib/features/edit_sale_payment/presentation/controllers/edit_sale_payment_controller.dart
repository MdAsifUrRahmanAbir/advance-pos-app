import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/api_params.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../cart/presentation/states/cart_state.dart';
import '../../../edit_sale_cart/presentation/controllers/edit_sale_cart_controller.dart';
import '../../../invoice_detail/data/models/sale_amounts.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../payment/presentation/controllers/payment_split_rules.dart';
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
/// invoice's previous payments exactly as they were, and sends
/// `PUT /sales/edit/:billNo`.
///
/// A higher total is collected on top of the previous payments through
/// any method ([addDueTo]); a lower total and any change are returned
/// from Cash.
class EditSalePaymentController extends Notifier<EditSalePaymentState> {
  EditSalePaymentController(this.billNo);

  final String billNo;

  static const String _deliveryCharge = '0';
  static const double _eps = 0.005;

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
      if (next.paymentAccounts.isNotEmpty) _onAccountsReady();
    });
    Future.microtask(() {
      if (ref.mounted) _onAccountsReady();
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

  void _onAccountsReady() {
    _syncCashAccount();
    _prefillFromInvoice();
  }

  /// The Cash account change and returns are paid out of.
  void _syncCashAccount() {
    if (state.cashAccount != null) return;
    final cash = ref
        .read(masterDataControllerProvider)
        .paymentAccounts
        .where((a) => SelectedPaymentEntry(system: a.paymentSystem).isCash)
        .firstOrNull;
    if (cash != null) state = state.copyWith(cashAccount: cash);
  }

  // ───────────────────────────────────────────────
  // Pre-fill from the original invoice
  // ───────────────────────────────────────────────
  /// Previous payments keep their exact amounts (marked as typed, so no
  /// rule recalculates them). The difference to the new total is shown
  /// separately and settled with [addDueTo] or returned from Cash.
  void _prefillFromInvoice() {
    if (_prefillDone || state.selectedEntries.isNotEmpty) return;
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    if (accounts.isEmpty) return;
    _prefillDone = true;

    final invoice = ref.read(editSaleCartControllerProvider(billNo)).invoice;
    if (invoice == null) return;

    final previous = [
      for (final c in invoice.payment.collection)
        if (c.amount.abs() > _eps)
          PreviousPayment(
            systemId: c.paymentSystemId,
            systemName: c.paymentSystemName,
            amount: _round2(c.amount),
          ),
    ];

    final systems = paymentSystemsFrom(accounts);
    final usedAccountIds =
    invoice.payment.paymentAccounts.map((a) => a.id.trim()).toSet();

    final entries = <SelectedPaymentEntry>[];
    for (final p in previous) {
      final system = systems.where((s) => s.id == p.systemId).firstOrNull;
      if (system == null) continue;

      final index = entries.indexWhere((e) => e.system.id == system.id);
      if (index != -1) {
        // Same method listed twice: one entry with the sum.
        entries[index] = entries[index]
            .copyWith(amount: _round2(entries[index].amount + p.amount));
        continue;
      }
      if (entries.length >= EditSalePaymentState.maxSelectable) continue;

      var entry = SelectedPaymentEntry(
        system: system,
        amount: p.amount,
        amountTouched: true,
      );
      final candidates = accountsForSystem(system);
      final account = candidates
          .where((a) => usedAccountIds.contains(a.id.toString()))
          .firstOrNull ??
          (!entry.needsAccountPicker || candidates.length == 1
              ? candidates.firstOrNull
              : null);
      if (account != null) entry = entry.copyWith(account: account);
      entries.add(entry);
    }

    state = state.copyWith(
      previousPayments: previous,
      selectedEntries: entries,
      prefilledFromInvoice: entries.isNotEmpty,
    );
  }

  // ───────────────────────────────────────────────
  // Payment selection
  // ───────────────────────────────────────────────
  List<pa.ResultDatum> accountsForSystem(pa.PaymentSystem system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts.where((a) => a.paymentSystem.id == system.id).toList();
  }

  /// Adding a method keeps every other amount (previous payments are not
  /// redistributed); the new method starts at 0 — or at the full payable
  /// when it is the only one.
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
      if (current.isEmpty) entry = entry.copyWith(amount: state.payableAmount);
      current.add(entry);
    }
    state = state.copyWith(selectedEntries: current, clearError: true);
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }

  /// Same Cash/non-cash rules as Payment, but typed and previous amounts
  /// are never recalculated.
  void updateAmountForSystem(int systemId, double amount) {
    state = state.copyWith(
      selectedEntries: PaymentSplitRules.onAmountEdited(
        state.selectedEntries,
        systemId: systemId,
        amount: amount,
        payable: state.payableAmount,
        keepTypedAmounts: true,
      ),
    );
  }

  /// Adds what is still missing to the method the customer pays it with.
  void addDueTo(int systemId) {
    final due = state.shortfall;
    if (due <= 0) return;
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId)
            e.copyWith(amount: _round2(e.amount + due), amountTouched: true)
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
    if (ref.read(apiParamsControllerProvider) == null) {
      state = state.copyWith(errorMessage: AppStrings.editSaleNotSignedIn);
      return false;
    }

    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final payload = _buildPayload();
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

  /// Account + amount per method. Non-cash as collected; Cash is net
  /// (given − returned) and goes negative when more is returned than was
  /// taken in cash. FLAG: backend must accept a negative cash amount.
  List<({pa.ResultDatum account, double amount})> _paymentLines() {
    final lines = <({pa.ResultDatum account, double amount})>[];
    for (final e in state.selectedEntries) {
      final account = e.account;
      if (e.isCash || account == null || e.amount <= _eps) continue;
      lines.add((account: account, amount: e.amount));
    }
    final cashAccount = state.cashEntry?.account ?? state.cashAccount;
    final cash = state.netCashAmount;
    if (cashAccount != null && cash.abs() > _eps) {
      lines.add((account: cashAccount, amount: cash));
    }
    return lines;
  }

  Map<String, dynamic> _buildPayload() {
    final CartState cart = ref.read(editSaleCartControllerProvider(billNo)).cart;
    final items = cart.items;
    final vatRate = cart.taxPercent.clamp(0.0, 100.0).toStringAsFixed(2);
    final lines = _paymentLines();

    return {
      // sales_type / branch_id / employee_id: set by EditSalePaymentRepository.
      if (cart.selectedCustomer != null)
        'customer_id': cart.selectedCustomer!.customerNo,
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
        for (final l in lines)
          '${l.account.paymentSystem.id}': '${l.account.id}',
      },
      'given_amount_arr': {
        for (final l in lines)
          '${l.account.paymentSystem.id}': _money(l.amount),
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