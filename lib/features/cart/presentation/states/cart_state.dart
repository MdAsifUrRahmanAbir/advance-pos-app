import 'package:flutter/foundation.dart';
import '../../data/models/customers_model.dart';

/// Discount can be entered either as a percentage of the subtotal or as
/// a fixed amount — the seller picks which via the toggle in
/// [DiscountVatSection].
enum DiscountType { percent, amount }

/// "12.50" -> "12.5", "10.00" -> "10", "0.00" -> "0".
String trimDecimal(double value) {
  final s = value.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

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
  final ResultDatum? selectedCustomer;
  final String remarks;
  final String referenceNo;

  /// Raw value the seller typed for discount — interpreted as a percent
  /// or an amount depending on [discountType]. Use [discountAmount] /
  /// [discountPercent] for the derived, clamped values.
  final DiscountType discountType;
  final double discountInput;

  /// VAT is percent-only.
  final double taxPercent;
  final double rounding;

  // --- Customer search / pagination (for CustomerSearchSheet) ---
  final String customerSearchQuery;
  final List<ResultDatum> customerResults;
  final bool isCustomerLoading;
  final bool isCustomerLoadingMore;
  final String? customerErrorMessage;
  final int customerCurrentStart;
  final bool customerHasMore;

  // --- Add-customer (POST /customer/add), for AddCustomerSheet ---
  final bool isAddingCustomer;
  final String? addCustomerErrorMessage;


  const CartState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.selectedCustomer,
    this.remarks = '',
    this.referenceNo = '',
    this.discountType = DiscountType.percent,
    this.discountInput = 0,
    this.taxPercent = 0,
    this.rounding = 0,
    this.customerSearchQuery = '',
    this.customerResults = const [],
    this.isCustomerLoading = false,
    this.isCustomerLoadingMore = false,
    this.customerErrorMessage,
    this.customerCurrentStart = 0,
    this.customerHasMore = true,
    this.isAddingCustomer = false,
    this.addCustomerErrorMessage,

});

  factory CartState.initial() => const CartState();

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Discount in currency, always clamped to [0, subtotal] regardless of
  /// which mode the seller typed in.
  double get discountAmount {
    final raw = discountType == DiscountType.percent
        ? subtotal * (discountInput / 100)
        : discountInput;
    return raw.clamp(0.0, subtotal).toDouble();
  }

  /// Discount as a percentage of the subtotal (derived, so it's correct
  /// in both modes and after the cart changes).
  double get discountPercent => subtotal <= 0 ? 0 : (discountAmount / subtotal) * 100;

  double get taxAmount {
    final pct = taxPercent.clamp(0.0, 100.0).toDouble();
    return (subtotal - discountAmount) * (pct / 100);
  }

  double get totalPayable => subtotal - discountAmount + taxAmount + rounding;

  CartState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CartLineItem>? items,
    ResultDatum? selectedCustomer,
    String? remarks,
    String? referenceNo,
    DiscountType? discountType,
    double? discountInput,
    double? taxPercent,
    double? rounding,
    String? customerSearchQuery,
    List<ResultDatum>? customerResults,
    bool? isCustomerLoading,
    bool? isCustomerLoadingMore,
    String? customerErrorMessage,
    int? customerCurrentStart,
    bool? customerHasMore,
    bool? isAddingCustomer,
    String? addCustomerErrorMessage,

}) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      remarks: remarks ?? this.remarks,
      referenceNo: referenceNo ?? this.referenceNo,
      discountType: discountType ?? this.discountType,
      discountInput: discountInput ?? this.discountInput,
      taxPercent: taxPercent ?? this.taxPercent,
      rounding: rounding ?? this.rounding,
      customerSearchQuery: customerSearchQuery ?? this.customerSearchQuery,
      customerResults: customerResults ?? this.customerResults,
      isCustomerLoading: isCustomerLoading ?? this.isCustomerLoading,
      isCustomerLoadingMore: isCustomerLoadingMore ?? this.isCustomerLoadingMore,
      customerErrorMessage: customerErrorMessage,
      customerCurrentStart: customerCurrentStart ?? this.customerCurrentStart,
      customerHasMore: customerHasMore ?? this.customerHasMore,
      isAddingCustomer: isAddingCustomer ?? this.isAddingCustomer,
      addCustomerErrorMessage: addCustomerErrorMessage,

);
  }
}