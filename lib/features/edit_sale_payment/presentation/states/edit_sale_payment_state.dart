import 'package:flutter/foundation.dart';

import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem, SelectedPaymentEntry;

/// Multi-flag state for Update Payment. Reuses the payment feature's
/// [SelectedPaymentEntry] / [ReceiptLineItem] types (so its read-only
/// widgets render unchanged); the amounts/rules mirror `PaymentState`.
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
    this.selectedEntries = const [],
    this.prefilledFromInvoice = false,
    this.isUpdating = false,
    this.isSharing = false,
    this.isPrinting = false,
    this.errorMessage,
    this.isUpdated = false,
    this.updatedBillNo,
  });

  double get totalCollected => selectedEntries.fold(0, (s, e) => s + e.amount);

  bool get hasCash => selectedEntries.any((e) => e.isCash);

  double get nonCashTotal =>
      selectedEntries.where((e) => !e.isCash).fold(0, (s, e) => s + e.amount);

  /// >0 = collected more than payable, <0 = still short.
  double get changeDue => totalCollected - payableAmount;

  /// Cash to hand back. Only ever non-zero when cash is selected.
  double get cashReturn => hasCash && changeDue > _eps ? changeDue : 0;

  /// What the customer actually pays (collected minus change).
  double get netCollected => totalCollected - cashReturn;

  /// Exactly one method and it's not cash → amount locked to payable.
  bool get lockSingleNonCashAmount =>
      selectedEntries.length == 1 && !selectedEntries.first.isCash;

  bool get canSubmit {
    if (isUpdating || isUpdated || selectedEntries.isEmpty) return false;
    if (payableAmount <= _eps || receiptItems.isEmpty) return false;
    if (selectedEntries.any((e) => e.account == null)) return false;
    if (nonCashTotal > payableAmount + _eps) return false;
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