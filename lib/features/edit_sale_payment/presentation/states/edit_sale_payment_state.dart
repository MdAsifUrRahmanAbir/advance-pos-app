import 'package:flutter/foundation.dart';

import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem, SelectedPaymentEntry;

/// One line of what the invoice was paid with before the edit.
@immutable
class PreviousPayment {
  final int systemId;
  final String systemName;
  final double amount;

  const PreviousPayment({
    required this.systemId,
    required this.systemName,
    required this.amount,
  });
}

/// Before → after for one payment method ([now] is net: cash minus what
/// is returned, so it can be negative when cash is paid out).
@immutable
class PaymentMethodChange {
  final int systemId;
  final String systemName;
  final double previous;
  final double now;

  const PaymentMethodChange({
    required this.systemId,
    required this.systemName,
    required this.previous,
    required this.now,
  });

  double get delta => now - previous;
}

/// Multi-flag state for Update Payment. Reuses the payment feature's
/// [SelectedPaymentEntry] / [ReceiptLineItem] types (so its read-only
/// widgets render unchanged).
///
/// Money rules: the previous payments stay as they were. A higher total
/// is collected on top (any method); a lower total — and any change —
/// is always returned from Cash.
@immutable
class EditSalePaymentState {
  final String billNo;

  // --- Amounts (snapshotted from the Edit Sale cart) ---
  final double payableAmount;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double originalPayable;
  final double originalPaid;
  final String saleDate;
  final List<ReceiptLineItem> receiptItems;

  /// What the invoice was paid with before this edit.
  final List<PreviousPayment> previousPayments;

  /// Cash account money is returned from when no Cash method is selected.
  final pa.ResultDatum? cashAccount;

  // --- Payment selection ---
  final List<SelectedPaymentEntry> selectedEntries;

  /// True when the selection was pre-filled from the invoice's original
  /// payment methods.
  final bool prefilledFromInvoice;

  // --- Independent async flags ---
  final bool isUpdating;
  final bool isSharing;
  final bool isPrinting;
  final String? errorMessage;

  final bool isUpdated;
  final String? updatedBillNo;

  static const int maxSelectable = 2;
  static const double _eps = 0.005;

  const EditSalePaymentState({
    required this.billNo,
    this.payableAmount = 0,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.vatAmount = 0,
    this.originalPayable = 0,
    this.originalPaid = 0,
    this.saleDate = '',
    this.receiptItems = const [],
    this.previousPayments = const [],
    this.cashAccount,
    this.selectedEntries = const [],
    this.prefilledFromInvoice = false,
    this.isUpdating = false,
    this.isSharing = false,
    this.isPrinting = false,
    this.errorMessage,
    this.isUpdated = false,
    this.updatedBillNo,
  });

  /// Paid before the edit (the collection lines; the sale's paid amount
  /// when the invoice has none).
  double get previousTotal => previousPayments.isEmpty
      ? originalPaid
      : previousPayments.fold(0, (s, p) => s + p.amount);

  /// >0 = the customer pays more, <0 = money goes back to the customer.
  double get difference => payableAmount - previousTotal;

  double get totalCollected => selectedEntries.fold(0, (s, e) => s + e.amount);

  bool get hasCash => selectedEntries.any((e) => e.isCash);

  SelectedPaymentEntry? get cashEntry =>
      selectedEntries.where((e) => e.isCash).firstOrNull;

  double get nonCashTotal =>
      selectedEntries.where((e) => !e.isCash).fold(0, (s, e) => s + e.amount);

  /// >0 = collected more than payable, <0 = still short.
  double get changeDue => totalCollected - payableAmount;

  /// Money handed back to the customer — always from Cash, even when no
  /// cash was taken (it is paid out of the drawer).
  double get cashReturn => changeDue > _eps ? changeDue : 0;

  /// Amount still missing.
  double get shortfall => changeDue < -_eps ? -changeDue : 0;

  /// What the customer actually pays (collected minus change).
  double get netCollected => totalCollected - cashReturn;

  /// Cash given minus cash returned. Negative when more is returned than
  /// was taken in cash.
  double get netCashAmount => (cashEntry?.amount ?? 0) - cashReturn;

  /// A return needs a Cash account to come out of.
  bool get canReturnCash =>
      cashReturn <= _eps || cashEntry?.account != null || cashAccount != null;

  /// Exactly one method and it's not cash → amount locked.
  bool get lockSingleNonCashAmount =>
      selectedEntries.length == 1 && !selectedEntries.first.isCash;

  /// Per method: paid before → after this update (net).
  List<PaymentMethodChange> get methodChanges {
    final rows = <int, PaymentMethodChange>{};
    for (final p in previousPayments) {
      rows[p.systemId] = PaymentMethodChange(
        systemId: p.systemId,
        systemName: p.systemName,
        previous: (rows[p.systemId]?.previous ?? 0) + p.amount,
        now: 0,
      );
    }
    for (final e in selectedEntries) {
      rows[e.system.id] = PaymentMethodChange(
        systemId: e.system.id,
        systemName: e.system.paymentSystemName,
        previous: rows[e.system.id]?.previous ?? 0,
        now: e.isCash ? netCashAmount : e.amount,
      );
    }
    // Returned with no Cash method selected: still paid out of Cash.
    final account = cashAccount;
    if (cashEntry == null && cashReturn > _eps && account != null) {
      final system = account.paymentSystem;
      rows[system.id] = PaymentMethodChange(
        systemId: system.id,
        systemName: system.paymentSystemName,
        previous: rows[system.id]?.previous ?? 0,
        now: -cashReturn,
      );
    }
    return rows.values.toList();
  }

  bool get canSubmit {
    if (isUpdating || isUpdated || selectedEntries.isEmpty) return false;
    if (payableAmount <= _eps || receiptItems.isEmpty) return false;
    if (selectedEntries.any((e) => e.account == null)) return false;
    if (!canReturnCash) return false;
    return totalCollected >= payableAmount - _eps;
  }

  String get methodLabel => selectedEntries.isEmpty
      ? '-'
      : selectedEntries.map((e) => e.system.paymentSystemName).join(' + ');

  EditSalePaymentState copyWith({
    double? payableAmount,
    double? subtotal,
    double? discountAmount,
    double? vatAmount,
    double? originalPayable,
    double? originalPaid,
    String? saleDate,
    List<ReceiptLineItem>? receiptItems,
    List<PreviousPayment>? previousPayments,
    pa.ResultDatum? cashAccount,
    List<SelectedPaymentEntry>? selectedEntries,
    bool? prefilledFromInvoice,
    bool? isUpdating,
    bool? isSharing,
    bool? isPrinting,
    String? errorMessage,
    bool clearError = false,
    bool? isUpdated,
    String? updatedBillNo,
  }) {
    return EditSalePaymentState(
      billNo: billNo,
      payableAmount: payableAmount ?? this.payableAmount,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      originalPayable: originalPayable ?? this.originalPayable,
      originalPaid: originalPaid ?? this.originalPaid,
      saleDate: saleDate ?? this.saleDate,
      receiptItems: receiptItems ?? this.receiptItems,
      previousPayments: previousPayments ?? this.previousPayments,
      cashAccount: cashAccount ?? this.cashAccount,
      selectedEntries: selectedEntries ?? this.selectedEntries,
      prefilledFromInvoice: prefilledFromInvoice ?? this.prefilledFromInvoice,
      isUpdating: isUpdating ?? this.isUpdating,
      isSharing: isSharing ?? this.isSharing,
      isPrinting: isPrinting ?? this.isPrinting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdated: isUpdated ?? this.isUpdated,
      updatedBillNo: updatedBillNo ?? this.updatedBillNo,
    );
  }
}