import 'package:flutter/foundation.dart';

import '../../../cart/presentation/states/cart_state.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart';
import '../../../new_sale/presentation/states/new_sale_state.dart' show ProductItem;

/// Outcome of adding a product from the search results.
enum EditCartAddOutcome { added, noStock }

/// Multi-flag state for the Edit Sale cart.
///
/// The cart part ([cart]) reuses the cart feature's [CartState] type, so
/// the read-only cart widgets (`CartItemList`, `DiscountVatSection`) can
/// render it unchanged. Everything edit-specific — the original invoice,
/// product search, stock caps — lives alongside it here.
@immutable
class EditSaleCartState {
  final String billNo;

  // --- Original invoice ---
  final bool isInvoiceLoading;
  final String? invoiceErrorMessage;
  final String? technicalDetails;
  final ResultData? invoice;

  // --- Editable cart (customer, lines, discount, VAT, customer search) ---
  final CartState cart;

  // --- Product search / scan ---
  final String productQuery;
  final List<ProductItem> productResults;
  final bool isProductSearching;
  final String? productSearchError;
  final bool isScanning;

  /// Quantity sold on the original invoice, by product id. That stock is
  /// already deducted on the server, so it's added back to the cap.
  final Map<String, int> originalQuantities;

  /// Max allowed quantity per product id (branch stock + original qty).
  /// Missing key = stock not known yet (the server still validates).
  final Map<String, int> maxQuantities;

  final bool isResolvingCustomer;

  /// True when the invoice had a named customer that couldn't be matched
  /// to a customer record — the salesman must re-select them.
  final bool customerUnmatched;

  /// Snapshot of the editable fields right after loading — used to warn
  /// before discarding changes.
  final String initialSignature;

  static const int minProductSearchLength = 3;

  const EditSaleCartState({
    required this.billNo,
    this.isInvoiceLoading = false,
    this.invoiceErrorMessage,
    this.technicalDetails,
    this.invoice,
    this.cart = const CartState(),
    this.productQuery = '',
    this.productResults = const [],
    this.isProductSearching = false,
    this.productSearchError,
    this.isScanning = false,
    this.originalQuantities = const {},
    this.maxQuantities = const {},
    this.isResolvingCustomer = false,
    this.customerUnmatched = false,
    this.initialSignature = '',
  });

  bool get isReady => invoice != null;

  bool get showProductResults =>
      productQuery.trim().length >= minProductSearchLength;

  int quantityInCart(String productId) =>
      cart.items.where((i) => i.id == productId).firstOrNull?.quantity ?? 0;

  /// How many more of [product] can still be added.
  int remainingFor(ProductItem product) {
    final cap = product.stock + (originalQuantities[product.id] ?? 0);
    return cap - quantityInCart(product.id);
  }

  /// Fingerprint of everything that ends up in the PUT payload.
  String get signature => [
    cart.items.map((i) => '${i.id}:${i.quantity}').join('|'),
    cart.selectedCustomer?.customerNo ?? '',
    cart.taxPercent.toStringAsFixed(2),
    cart.discountType.name,
    cart.discountInput.toStringAsFixed(2),
    cart.discountBasis.name,
  ].join('#');

  bool get hasChanges => isReady && signature != initialSignature;

  bool get canProceed =>
      isReady &&
          cart.items.isNotEmpty &&
          !cart.isGetDiscountLoading &&
          !isResolvingCustomer;

  EditSaleCartState copyWith({
    bool? isInvoiceLoading,
    String? invoiceErrorMessage,
    bool clearInvoiceError = false,
    String? technicalDetails,
    bool clearTechnicalDetails = false,
    ResultData? invoice,
    CartState? cart,
    String? productQuery,
    List<ProductItem>? productResults,
    bool? isProductSearching,
    String? productSearchError,
    bool clearProductSearchError = false,
    bool? isScanning,
    Map<String, int>? originalQuantities,
    Map<String, int>? maxQuantities,
    bool? isResolvingCustomer,
    bool? customerUnmatched,
    String? initialSignature,
  }) {
    return EditSaleCartState(
      billNo: billNo,
      isInvoiceLoading: isInvoiceLoading ?? this.isInvoiceLoading,
      invoiceErrorMessage: clearInvoiceError
          ? null
          : (invoiceErrorMessage ?? this.invoiceErrorMessage),
      technicalDetails: clearTechnicalDetails
          ? null
          : (technicalDetails ?? this.technicalDetails),
      invoice: invoice ?? this.invoice,
      cart: cart ?? this.cart,
      productQuery: productQuery ?? this.productQuery,
      productResults: productResults ?? this.productResults,
      isProductSearching: isProductSearching ?? this.isProductSearching,
      productSearchError: clearProductSearchError
          ? null
          : (productSearchError ?? this.productSearchError),
      isScanning: isScanning ?? this.isScanning,
      originalQuantities: originalQuantities ?? this.originalQuantities,
      maxQuantities: maxQuantities ?? this.maxQuantities,
      isResolvingCustomer: isResolvingCustomer ?? this.isResolvingCustomer,
      customerUnmatched: customerUnmatched ?? this.customerUnmatched,
      initialSignature: initialSignature ?? this.initialSignature,
    );
  }
}