import 'package:flutter/foundation.dart';
import '../../data/models/customers_model.dart';
import '../../data/models/get_discount.dart';

/// Manual discount entry mode (only used when the server rule is Regular).
enum DiscountType { percent, amount }

/// What the server says applies to this cart.
enum DiscountRule { none, regular, product, bill, both }

/// Which discount the seller chose when the server returns scope "both".
enum DiscountBasis { product, bill }

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

  // --- Manual discount (Regular rule only) ---
  final DiscountType discountType;
  final double discountInput;

  /// Bumped when the controller rewrites the typed value (clamp / reset)
  /// so the text field re-creates itself and shows the new value.
  final int discountFieldRevision;

  final double taxPercent;
  final double rounding;

  // --- Server discount (GET /get_discount) ---
  final GetDiscountModel? getDiscountModel;
  final bool isGetDiscountLoading;
  final String? discountErrorMessage;

  /// True when the server offered both product + bill discounts, so the
  /// seller must pick one (stays true across the re-fetch that follows
  /// a basis change).
  final bool bothChoice;
  final DiscountBasis discountBasis;

  // --- Customer search / pagination ---
  final String customerSearchQuery;
  final List<ResultDatum> customerResults;
  final bool isCustomerLoading;
  final bool isCustomerLoadingMore;
  final String? customerErrorMessage;
  final int customerCurrentStart;
  final bool customerHasMore;

  // --- Add-customer ---
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
    this.discountFieldRevision = 0,
    this.taxPercent = 0,
    this.rounding = 0,
    this.getDiscountModel,
    this.isGetDiscountLoading = false,
    this.discountErrorMessage,
    this.bothChoice = false,
    this.discountBasis = DiscountBasis.product,
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

  // ─────────────────────────────────────────────
  // Discount rule resolution
  // ─────────────────────────────────────────────
  DiscountResultData? get _result => getDiscountModel?.resultData;

  DiscountRule get rule {
    final d = _result;
    if (d == null || !d.discountApplied) return DiscountRule.none;
    switch ((d.discountScope ?? '').toLowerCase()) {
      case 'regular':
        return DiscountRule.regular;
      case 'product':
        return DiscountRule.product;
      case 'bill':
        return DiscountRule.bill;
      case 'both':
        return DiscountRule.both;
    }
    return DiscountRule.none;
  }

  /// The rule actually being applied (resolves "both" via the seller's pick).
  DiscountRule get effectiveRule => rule == DiscountRule.both
      ? (discountBasis == DiscountBasis.product
      ? DiscountRule.product
      : DiscountRule.bill)
      : rule;

  bool get canEnterDiscount => rule == DiscountRule.regular;
  bool get showBasisChoice => bothChoice;
  List<String> get discountCodes => _result?.discountCodes ?? const [];

  // --- Regular-rule cap ---
  bool get _isPercentageMethod =>
      (_result?.discountMethod ?? '').toLowerCase() == 'percentage';

  /// Max discount in currency; no cap configured (0/null) => whole subtotal.
  double get maxDiscountAmount {
    final d = _result;
    if (rule != DiscountRule.regular || d == null) return subtotal;
    final cap = _isPercentageMethod
        ? subtotal * ((d.discountRate ?? 0) / 100)
        : (d.discountAmount ?? 0);
    if (cap <= 0) return subtotal;
    return cap > subtotal ? subtotal : cap;
  }

  /// Max allowed value in the currently selected entry mode.
  double get maxDiscountInput {
    final d = _result;
    if (discountType == DiscountType.amount) return maxDiscountAmount;
    if (_isPercentageMethod && (d?.discountRate ?? 0) > 0) {
      return d!.discountRate!;
    }
    return subtotal <= 0 ? 0 : (maxDiscountAmount / subtotal) * 100;
  }

  bool get hasDiscountCap {
    final d = _result;
    if (rule != DiscountRule.regular || d == null) return false;
    return (_isPercentageMethod ? d.discountRate : d.discountAmount) != null &&
        (_isPercentageMethod ? d.discountRate! : d.discountAmount!) > 0;
  }

  // --- Product-wise ---
  /// Per-line discount amounts (only while product-wise is effective).
  /// The server value is treated as the discount for the whole line and
  /// clamped to that line's total.
  Map<String, double> get lineDiscounts {
    final d = _result;
    if (effectiveRule != DiscountRule.product || d == null) return const {};
    return {
      for (final item in items)
        item.id: (d.productDiscounts[item.id] ?? 0)
            .clamp(0.0, item.lineTotal)
            .toDouble(),
    };
  }

  double _billDiscountAmount() {
    final d = _result;
    if (d == null) return 0;
    final raw = _isPercentageMethod
        ? subtotal * ((d.discountRate ?? 0) / 100)
        : (rule == DiscountRule.both
        ? (d.billDiscountAmount ?? 0)
        : (d.billDiscountAmount ?? d.discountAmount ?? 0));
    return raw.clamp(0.0, subtotal).toDouble();
  }

  /// Total discount in currency, whichever rule is active.
  double get discountAmount {
    switch (effectiveRule) {
      case DiscountRule.none:
      case DiscountRule.both:
        return 0;
      case DiscountRule.regular:
        final raw = discountType == DiscountType.percent
            ? subtotal * (discountInput / 100)
            : discountInput;
        return raw.clamp(0.0, maxDiscountAmount).toDouble();
      case DiscountRule.product:
        return lineDiscounts.values.fold(0.0, (s, v) => s + v);
      case DiscountRule.bill:
        return _billDiscountAmount();
    }
  }

  double get discountPercent =>
      subtotal <= 0 ? 0 : (discountAmount / subtotal) * 100;

  /// Discount rate (%) to send for one line in `prod_dis_rate_arr`.
  double lineDiscountRate(CartLineItem item) {
    if (effectiveRule == DiscountRule.product) {
      final line = lineDiscounts[item.id] ?? 0;
      return item.lineTotal <= 0 ? 0 : (line / item.lineTotal) * 100;
    }
    if (effectiveRule == DiscountRule.regular &&
        discountType == DiscountType.percent) {
      return discountPercent.clamp(0.0, 100.0).toDouble();
    }
    return discountPercent; // bill-wise / amount-mode: same rate on every line
  }

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
    int? discountFieldRevision,
    double? taxPercent,
    double? rounding,
    GetDiscountModel? getDiscountModel,
    bool clearDiscount = false,
    bool? isGetDiscountLoading,
    String? discountErrorMessage,
    bool? bothChoice,
    DiscountBasis? discountBasis,
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
      discountFieldRevision:
      discountFieldRevision ?? this.discountFieldRevision,
      taxPercent: taxPercent ?? this.taxPercent,
      rounding: rounding ?? this.rounding,
      getDiscountModel:
      clearDiscount ? null : (getDiscountModel ?? this.getDiscountModel),
      isGetDiscountLoading: isGetDiscountLoading ?? this.isGetDiscountLoading,
      discountErrorMessage: discountErrorMessage,
      bothChoice: bothChoice ?? this.bothChoice,
      discountBasis: discountBasis ?? this.discountBasis,
      customerSearchQuery: customerSearchQuery ?? this.customerSearchQuery,
      customerResults: customerResults ?? this.customerResults,
      isCustomerLoading: isCustomerLoading ?? this.isCustomerLoading,
      isCustomerLoadingMore:
      isCustomerLoadingMore ?? this.isCustomerLoadingMore,
      customerErrorMessage: customerErrorMessage,
      customerCurrentStart: customerCurrentStart ?? this.customerCurrentStart,
      customerHasMore: customerHasMore ?? this.customerHasMore,
      isAddingCustomer: isAddingCustomer ?? this.isAddingCustomer,
      addCustomerErrorMessage: addCustomerErrorMessage,
    );
  }
}