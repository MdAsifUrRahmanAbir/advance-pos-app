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

/// One payment system the user has selected (max
/// [PaymentState.maxSelectable] total), plus which account (for
/// non-cash systems) and how much of the payable amount is allocated
/// to it.
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

  /// Matched by shortName rather than a hardcoded id, since "Cash" is
  /// just another row from `/gnl/payment_system/all` on the backend.
  bool get isCash => system.shortName.trim().toUpperCase() == 'CAS';

  SelectedPaymentEntry copyWith({
    pa.ResultDatum? account,
    double? amount,
  }) {
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
  final String saleId;
  final String saleDate;

  final String salesAgent;
  final List<String> availableAgents;

  final List<ReceiptLineItem> receiptItems;

  /// User's chosen payment system(s), capped at [maxSelectable].
  /// (The systems/accounts lists themselves live in MasterDataState.)
  final List<SelectedPaymentEntry> selectedEntries;

  // --- Independent concurrent operations (multi-flag pattern, §4) ---
  final bool isSharing;
  final bool isPrinting;
  final String? shareError;
  final String? printError;

  const PaymentState({
    this.isProcessing = false,
    this.errorMessage,
    this.payableAmount = 0,
    this.saleId = '',
    this.saleDate = '',
    this.salesAgent = '',
    this.availableAgents = const [],
    this.receiptItems = const [],
    this.selectedEntries = const [],
    this.isSharing = false,
    this.isPrinting = false,
    this.shareError,
    this.printError,
  });

  /// Only 2 payment methods can be combined on a single sale.
  static const int maxSelectable = 2;

  double get totalCollected => selectedEntries.fold(0, (sum, e) => sum + e.amount);

  double get changeDue => totalCollected - payableAmount;

  /// True when exactly one, non-cash system is selected — its amount
  /// field is locked to the full [payableAmount] rather than editable,
  /// since a single digital payment can't have "change".
  bool get lockSingleNonCashAmount => selectedEntries.length == 1 && !selectedEntries.first.isCash;

  /// Every selected non-cash entry needs an account chosen, and the
  /// combined amount must cover the payable amount.
  bool get canComplete {
    if (isProcessing || selectedEntries.isEmpty) return false;
    final missingAccount = selectedEntries.any((e) => !e.isCash && e.account == null);
    if (missingAccount) return false;
    return totalCollected >= payableAmount;
  }

  /// Joined system names, for the receipt / printed slip.
  String get methodLabel {
    if (selectedEntries.isEmpty) return '-';
    return selectedEntries.map((e) => e.system.paymentSystemName).join(' + ');
  }

  PaymentState copyWith({
    bool? isProcessing,
    String? errorMessage,
    double? payableAmount,
    String? saleId,
    String? saleDate,
    String? salesAgent,
    List<String>? availableAgents,
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
      saleId: saleId ?? this.saleId,
      saleDate: saleDate ?? this.saleDate,
      salesAgent: salesAgent ?? this.salesAgent,
      availableAgents: availableAgents ?? this.availableAgents,
      receiptItems: receiptItems ?? this.receiptItems,
      selectedEntries: selectedEntries ?? this.selectedEntries,
      isSharing: isSharing ?? this.isSharing,
      isPrinting: isPrinting ?? this.isPrinting,
      shareError: shareError,
      printError: printError,
    );
  }
}