import 'package:flutter/material.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
// import '../../../master_data/data/models/payment_system_model.dart' as ps;

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

@immutable
class SelectedPaymentEntry {
  final pa.PaymentSystem system;
  final pa.ResultDatum? account;
  final double amount;

  const SelectedPaymentEntry({
    required this.system,
    this.account,
    this.amount = 0,
  });

  bool get isCash => system.shortName.trim().toUpperCase() == 'CAS';

  // TODO: confirm the exact short name the backend uses for Reward.
  bool get isReward {
    final short = system.shortName.trim().toUpperCase();
    return short == 'REW' ||
        short == 'RWD' ||
        system.paymentSystemName.toUpperCase().contains('REWARD');
  }

  /// Cash and Reward never show an account dropdown — their account is
  /// auto-assigned when the system is selected.
  bool get needsAccountPicker => !isCash && !isReward;

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

  final bool isSaleCompleted;
  final String? salesBillNo;

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
    this.isSaleCompleted = false,
    this.salesBillNo,
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

// lock: exactly one method and it's not cash (reward included)
  bool get lockSingleNonCashAmount =>
      selectedEntries.length == 1 && !selectedEntries.first.isCash;

// every entry (cash too) needs an account id for the API
  bool get canComplete {
    if (isProcessing || isSaleCompleted || selectedEntries.isEmpty) return false;
    if (selectedEntries.any((e) => e.account == null)) return false;
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
    bool? isSaleCompleted,
    String? salesBillNo,

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
      isSaleCompleted: isSaleCompleted ?? this.isSaleCompleted,
      salesBillNo: salesBillNo ?? this.salesBillNo,
    );
  }
}