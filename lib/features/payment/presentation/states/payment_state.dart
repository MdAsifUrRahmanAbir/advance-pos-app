import 'package:flutter/material.dart';

enum PaymentMethod { cash, bank, card, mobile }

extension PaymentMethodX on PaymentMethod {
  IconData get icon => switch (this) {
    PaymentMethod.cash => Icons.payments_outlined,
    PaymentMethod.bank => Icons.account_balance_outlined,
    PaymentMethod.card => Icons.credit_card_outlined,
    PaymentMethod.mobile => Icons.phone_iphone_outlined,
  };

  String get labelKey => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.bank => 'Bank',
    PaymentMethod.card => 'Card',
    PaymentMethod.mobile => 'Mobile',
  };
}

@immutable
class PaymentState {
  final bool isProcessing;
  final String? errorMessage;

  final double payableAmount;
  final String saleId;
  final String saleDate;

  final PaymentMethod selectedMethod;
  final double givenAmount;

  final String salesAgent;
  final List<String> availableAgents;

  const PaymentState({
    this.isProcessing = false,
    this.errorMessage,
    this.payableAmount = 0,
    this.saleId = '',
    this.saleDate = '',
    this.selectedMethod = PaymentMethod.cash,
    this.givenAmount = 0,
    this.salesAgent = '',
    this.availableAgents = const [],
  });

  double get changeDue => givenAmount - payableAmount;
  bool get canComplete => givenAmount >= payableAmount && !isProcessing;

  PaymentState copyWith({
    bool? isProcessing,
    String? errorMessage,
    double? payableAmount,
    String? saleId,
    String? saleDate,
    PaymentMethod? selectedMethod,
    double? givenAmount,
    String? salesAgent,
    List<String>? availableAgents,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      payableAmount: payableAmount ?? this.payableAmount,
      saleId: saleId ?? this.saleId,
      saleDate: saleDate ?? this.saleDate,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      givenAmount: givenAmount ?? this.givenAmount,
      salesAgent: salesAgent ?? this.salesAgent,
      availableAgents: availableAgents ?? this.availableAgents,
    );
  }
}