import '../../../cart/presentation/states/cart_state.dart' show CartLineItem;
import '../../../new_sale/presentation/states/new_sale_state.dart'
    show ProductItem;
import '../../../payment/presentation/states/payment_state.dart'
    show SelectedPaymentEntry;
import 'sales_replacement_add_calc.dart';
import 'sales_replacement_receipt.dart';

/// Step 2 (replacement items, totals, payment, submit). Product search,
/// the cart and the submit run independently, hence their own flags.
class SalesReplacementReplaceState {
  static const int minProductSearchLength = 3;
  static const int maxPaymentMethods = 2;
  static const double _eps = 0.005;

  /// Credit for the returned products, mirrored from step 1.
  final double returnTotal;

  final List<CartLineItem> newLines;

  /// Branch stock per product id, remembered when the line was added.
  final Map<String, int> stockCaps;

  final String productQuery;
  final List<ProductItem> productResults;
  final bool isProductSearching;
  final String? productSearchError;

  final List<SelectedPaymentEntry> selectedEntries;

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSubmitted;
  final String? createdBillNo;

  /// Snapshot for the success sheet; set once the replacement is created.
  final SalesReplacementReceipt? receipt;
  final bool isSharing;
  final bool isPrinting;

  const SalesReplacementReplaceState({
    this.returnTotal = 0,
    this.newLines = const [],
    this.stockCaps = const {},
    this.productQuery = '',
    this.productResults = const [],
    this.isProductSearching = false,
    this.productSearchError,
    this.selectedEntries = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.isSubmitted = false,
    this.createdBillNo,
    this.receipt,
    this.isSharing = false,
    this.isPrinting = false,
  });

  bool get showProductResults =>
      productQuery.trim().length >= minProductSearchLength;

  // ── Totals ──
  double get newTotal => SalesReplacementAddCalc.round2(
    newLines.fold(0.0, (s, l) => s + l.lineTotal),
  );

  int get newItemCount => newLines.fold(0, (s, l) => s + l.quantity);

  /// New items minus the return credit. Negative means the customer would
  /// be owed money, which the API has no field for.
  double get netPayable =>
      SalesReplacementAddCalc.round2(newTotal - returnTotal);

  bool get isShortOfReturn => newLines.isNotEmpty && netPayable < -_eps;
  bool get needsPayment => netPayable > _eps;

  /// What the customer pays now (0 for an even exchange).
  double get payable => needsPayment ? netPayable : 0;

  // ── Payment ──
  double get totalCollected => selectedEntries.fold(0, (s, e) => s + e.amount);
  bool get hasCash => selectedEntries.any((e) => e.isCash);
  double get nonCashTotal =>
      selectedEntries.where((e) => !e.isCash).fold(0, (s, e) => s + e.amount);

  /// >0 = collected more than payable, <0 = still short.
  double get changeDue => totalCollected - payable;
  double get cashReturn => hasCash && changeDue > _eps ? changeDue : 0;

  /// One non-cash method: its amount is fixed to the payable amount.
  bool get lockSingleNonCashAmount =>
      selectedEntries.length == 1 && !selectedEntries.first.isCash;

  bool get _paymentOk {
    if (!needsPayment) return true;
    if (selectedEntries.isEmpty) return false;
    if (selectedEntries.any((e) => e.account == null)) return false;
    if (nonCashTotal > payable + _eps) return false;
    return totalCollected >= payable - _eps;
  }

  bool get canSubmit =>
      !isSubmitting &&
          !isSubmitted &&
          newLines.isNotEmpty &&
          !isShortOfReturn &&
          _paymentOk;

  // ── Cart helpers ──
  int quantityInCart(String productId) => newLines
      .where((l) => l.id == productId)
      .fold(0, (s, l) => s + l.quantity);

  /// How many more units of [product] can still be added.
  int remainingFor(ProductItem product) =>
      product.stock - quantityInCart(product.id);

  SalesReplacementReplaceState copyWith({
    double? returnTotal,
    List<CartLineItem>? newLines,
    Map<String, int>? stockCaps,
    String? productQuery,
    List<ProductItem>? productResults,
    bool? isProductSearching,
    String? productSearchError,
    bool clearProductSearchError = false,
    List<SelectedPaymentEntry>? selectedEntries,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitted,
    String? createdBillNo,
    SalesReplacementReceipt? receipt,
    bool? isSharing,
    bool? isPrinting,
  }) {
    return SalesReplacementReplaceState(
      returnTotal: returnTotal ?? this.returnTotal,
      newLines: newLines ?? this.newLines,
      stockCaps: stockCaps ?? this.stockCaps,
      productQuery: productQuery ?? this.productQuery,
      productResults: productResults ?? this.productResults,
      isProductSearching: isProductSearching ?? this.isProductSearching,
      productSearchError: clearProductSearchError
          ? null
          : (productSearchError ?? this.productSearchError),
      selectedEntries: selectedEntries ?? this.selectedEntries,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitted: isSubmitted ?? this.isSubmitted,
      createdBillNo: createdBillNo ?? this.createdBillNo,
      receipt: receipt ?? this.receipt,
      isSharing: isSharing ?? this.isSharing,
      isPrinting: isPrinting ?? this.isPrinting,
    );
  }
}