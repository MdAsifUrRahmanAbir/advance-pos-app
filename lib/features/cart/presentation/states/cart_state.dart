import 'package:flutter/foundation.dart';

@immutable
class CartLineItem {
  final String id;
  final String name;
  final double unitPrice;
  final int quantity;

  const CartLineItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  CartLineItem copyWith({int? quantity}) {
    return CartLineItem(
      id: id,
      name: name,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

@immutable
class CartState {
  final bool isLoading;
  final String? errorMessage;

  final List<CartLineItem> items;
  final String customerName;
  final String remarks;
  final String referenceNo;

  final double discountPercent;
  final double taxPercent;
  final double rounding;

  const CartState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.customerName = '',
    this.remarks = '',
    this.referenceNo = '',
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.rounding = 0,
  });

  factory CartState.initial() => const CartState();

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxAmount => (subtotal - discountAmount) * (taxPercent / 100);
  double get totalPayable => subtotal - discountAmount + taxAmount + rounding;

  CartState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CartLineItem>? items,
    String? customerName,
    String? remarks,
    String? referenceNo,
    double? discountPercent,
    double? taxPercent,
    double? rounding,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      remarks: remarks ?? this.remarks,
      referenceNo: referenceNo ?? this.referenceNo,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      rounding: rounding ?? this.rounding,
    );
  }
}
