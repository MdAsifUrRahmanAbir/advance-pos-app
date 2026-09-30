import 'package:flutter/material.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/data/models/payment_system_model.dart' as ps;

@immutable
class ReceiptLineItem {
  final String name;
  final int quantity;
  final double lineTotal;

  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.lineTotal,
  });
}

/// One selected payment system plus its account (non-cash) and amount.
@immutable
class SelectedPaymentEntry {
  final ps.ResultDatum system;
  final pa.ResultDatum? account;
  final double amount;

  const SelectedPaymentEntry({
    required this.system,
    this.account,
    this.amount = 0,
  });

  bool get isCash => system.shortName.trim().toUpperCase() == 'CAS';

  SelectedPaymentEntry copyWith({pa.ResultDatum? account, double? amount}) {
    return SelectedPaymentEntry(
      system: system,
      account: account ?? this.account,
      amount: amount ?? this.amount,
    );
  }
}

@immutable
class PaymentState {
  final bool isProcessing;
  final String? errorMessage;

  final double payableAmount;
  final String saleDate;

  final List<ReceiptLineItem> receiptItems;
  final List<SelectedPaymentEntry> selectedEntries;

  final bool isSharing;
  final bool isPrinting;
  final String? shareError;
  final String? printError;

  const PaymentState({
    this.isProcessing = false,
    this.errorMessage,
    this.payableAmount = 0,
    this.saleDate = '',
    this.receiptItems = const [],
    this.selectedEntries = const [],
    this.isSharing = false,
    this.isPrinting = false,
    this.shareError,
    this.printError,
  });

  static const int maxSelectable = 2;
  static const double _eps = 0.005;

  double get totalCollected => selectedEntries.fold(0, (s, e) => s + e.amount);

  bool get hasCash => selectedEntries.any((e) => e.isCash);

  double get nonCashTotal =>
      selectedEntries.where((e) => !e.isCash).fold(0, (s, e) => s + e.amount);

  /// >0 = collected more than payable, <0 = still short.
  double get changeDue => totalCollected - payableAmount;

  /// Cash to hand back. Only ever non-zero when cash is selected.
  double get cashReturn => hasCash && changeDue > _eps ? changeDue : 0;

  /// Amount still missing.
  double get shortfall => changeDue < -_eps ? -changeDue : 0;

  /// Exactly one non-cash method -> amount pinned to the payable amount.
  bool get lockSingleNonCashAmount =>
      selectedEntries.length == 1 && !selectedEntries.first.isCash;

  bool get canComplete {
    if (isProcessing || selectedEntries.isEmpty) return false;
    if (selectedEntries.any((e) => !e.isCash && e.account == null)) return false;
    // Change can only come out of cash, so non-cash can't overpay.
    if (nonCashTotal > payableAmount + _eps) return false;
    return totalCollected >= payableAmount - _eps;
  }

  String get methodLabel {
    if (selectedEntries.isEmpty) return '-';
    return selectedEntries.map((e) => e.system.paymentSystemName).join(' + ');
  }

  PaymentState copyWith({
    bool? isProcessing,
    String? errorMessage,
    double? payableAmount,
    String? saleDate,
    List<ReceiptLineItem>? receiptItems,
    List<SelectedPaymentEntry>? selectedEntries,
    bool? isSharing,
    bool? isPrinting,
    String? shareError,
    String? printError,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      payableAmount: payableAmount ?? this.payableAmount,
      saleDate: saleDate ?? this.saleDate,
      receiptItems: receiptItems ?? this.receiptItems,
      selectedEntries: selectedEntries ?? this.selectedEntries,
      isSharing: isSharing ?? this.isSharing,
      isPrinting: isPrinting ?? this.isPrinting,
      shareError: shareError,
      printError: printError,
    );
  }
}