import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../cart/data/models/customers_model.dart' as cust;
import '../../../cart/data/repositories/cart_repository.dart';
import '../../../cart/presentation/states/cart_state.dart';
import '../../../invoice_detail/data/models/sale_amounts.dart';
import '../../../new_sale/data/models/stocks_model.dart' as stock;
import '../../../new_sale/presentation/states/new_sale_state.dart'
    show ProductItem, ScanOutcome, ScanResult;
import '../../data/models/edit_sale_source.dart';
import '../../data/repositories/edit_sale_cart_repository.dart';
import '../states/edit_sale_cart_state.dart';

/// Family arg: the sales bill number being edited (e.g. SL00020100416).
final editSaleCartControllerProvider = NotifierProvider.autoDispose
    .family<EditSaleCartController, EditSaleCartState, String>(
  EditSaleCartController.new,
);

/// Edit Sale cart: loads the invoice, lets the salesman change lines /
/// customer / discount / VAT, and adds products via search or scan.
///
/// Independent from New Sale and Cart (neither is touched). The discount
/// rules are a port of `CartController`'s logic operating on
/// [EditSaleCartState.cart] — candidate for a shared helper once the cart
/// feature can be refactored.
class EditSaleCartController extends Notifier<EditSaleCartState> {
  EditSaleCartController(this.billNo);

  final String billNo;

  late final TextEditingController productSearchController;
  late final TextEditingController customerSearchController;

  EditSaleCartRepository get _repository =>
      ref.read(editSaleCartRepositoryProvider);
  CartRepository get _cartRepository => ref.read(cartRepositoryProvider);

  /// Throws [StateError] when nobody is signed in — always read inside a
  /// try block so it surfaces as a normal error message.
  int get _branchId => ref.read(sessionBranchIdProvider);

  static const int _customerPageLength = 20;
  static const int _minCustomerSearchLength = 4;
  static const int _productPageLength = 20;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _productDebounce;
  Timer? _customerDebounce;
  Timer? _discountDebounce;
  int _productRequestId = 0;
  int _discountRequestId = 0;
  bool _loading = false;

  /// Original sale date — discount rules are evaluated as of that day.
  DateTime? _saleDate;

  /// Original bill discount %, re-applied once the server confirms the
  /// "regular" (manual) rule. Null once consumed.
  double? _pendingDiscountRate;

  @override
  EditSaleCartState build() {
    productSearchController = TextEditingController();
    customerSearchController = TextEditingController();
    ref.onDispose(() {
      productSearchController.dispose();
      customerSearchController.dispose();
      _productDebounce?.cancel();
      _customerDebounce?.cancel();
      _discountDebounce?.cancel();
    });

    Future.microtask(() {
      if (ref.mounted) loadInvoice();
    });
    return EditSaleCartState(billNo: billNo, isInvoiceLoading: true);
  }

  // ───────────────────────────────────────────────
  // Load the invoice
  // ───────────────────────────────────────────────
  Future<bool> loadInvoice() async {
    if (_loading) return false;
    _loading = true;
    state = state.copyWith(
      isInvoiceLoading: true,
      clearInvoiceError: true,
      clearTechnicalDetails: true,
    );
    try {
      final source = await _repository.getInvoiceForEdit(billNo);
      if (!ref.mounted) return false;
      final invoice = source.invoice;

      // Merge duplicate product rows so each product is one cart line.
      final quantities = <String, int>{};
      final lines = <String, CartLineItem>{};
      final stockLookupKeys = <String, String>{};
      for (final detail in invoice.saleDetails) {
        final id = detail.productId.toString();
        final qty = detail.quantityValue;
        quantities[id] = (quantities[id] ?? 0) + qty;
        final existing = lines[id];
        lines[id] = existing == null
            ? CartLineItem(
          id: id,
          name: detail.productName,
          unitPrice: detail.unitPriceValue,
          quantity: qty,
        )
            : existing.copyWith(quantity: existing.quantity + qty);
        final barcode = detail.productBarcode.trim();
        stockLookupKeys[id] = barcode.isNotEmpty ? barcode : detail.productName;
      }

      _saleDate = _parseSaleDate(invoice.sale.salesDate);
      final originalRate = invoice.sale.discountRateValue;
      _pendingDiscountRate = originalRate > 0 ? originalRate : null;

      state = state.copyWith(
        isInvoiceLoading: false,
        invoice: invoice,
        originalQuantities: quantities,
        cart: state.cart.copyWith(
          items: lines.values.toList(),
          taxPercent: invoice.sale.vatRateValue,
        ),
      );
      _loading = false;

      unawaited(_hydrateStock(stockLookupKeys));
      await _resolveCustomer(source);
      if (!ref.mounted) return true;
      await refreshDiscount();
      if (ref.mounted) {
        state = state.copyWith(initialSignature: state.signature);
      }
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isInvoiceLoading: false,
        invoiceErrorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.invoiceDetails(billNo),
        ),
      );
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Accepts ISO (`2026-10-17`) and day-first (`17-10-2026`, `17/10/2026`)
  /// dates. Null when unreadable — discounts then use today's date.
  DateTime? _parseSaleDate(String raw) {
    final value = raw.trim();
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final match = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})').firstMatch(value);
    if (match == null) return null;
    return DateTime(
      int.parse(match[3]!),
      int.parse(match[2]!),
      int.parse(match[1]!),
    );
  }

  /// Matches the invoice's customer to a customer record (by mobile, and
  /// by customer number when the API provides one). Walk-in invoices
  /// stay without a customer.
  Future<void> _resolveCustomer(EditSaleSource source) async {
    final invoice = source.invoice;
    final name = invoice.customerName.trim();
    final mobile = invoice.customerMobile?.toString().trim() ?? '';
    final isWalkIn = (name.isEmpty || name == '-') && mobile.isEmpty;
    if (isWalkIn) return;

    state = state.copyWith(isResolvingCustomer: true);
    cust.ResultDatum? match;
    try {
      if (mobile.isNotEmpty) {
        final result = await _cartRepository.getCustomers(
          start: 0,
          length: 10,
          search: mobile,
        );
        final sameMobile = result.resultData
            .where((c) => c.customerMobile.trim() == mobile)
            .toList();
        // With a known customer_no only an exact match counts (two
        // customers can share a phone number). Without it, the mobile
        // match is the best available signal.
        match = source.customerNo != null
            ? sameMobile.where((c) => c.customerNo == source.customerNo).firstOrNull
            : sameMobile.firstOrNull;
      }
    } catch (_) {
      // Fall through — handled as "unmatched" below.
    }
    if (!ref.mounted) return;

    if (match == null && source.customerNo != null) {
      match = cust.ResultDatum(
        sl: 0,
        customerNo: source.customerNo!,
        customerName: name,
        customerType: 0,
        isPurchase: null,
        customerMobile: mobile,
        customerEmail: '',
        branchName: '',
      );
    }

    state = state.copyWith(
      isResolvingCustomer: false,
      customerUnmatched: match == null,
      cart: match == null ? null : state.cart.copyWith(selectedCustomer: match),
    );
  }

  /// Looks up current branch stock for the original lines so increments
  /// are capped. Failures are ignored — the server still validates.
  Future<void> _hydrateStock(Map<String, String> lookupKeys) async {
    final caps = <String, int>{};
    try {
      final branchId = _branchId;
      await Future.wait(
        lookupKeys.entries.map((entry) async {
          try {
            final result = await _repository.searchProducts(
              branchId: branchId,
              search: entry.value,
              length: 5,
            );
            final hit = result.resultData
                .where((r) => r.product.id.toString() == entry.key)
                .firstOrNull;
            if (hit != null) {
              caps[entry.key] = _branchStock(hit.product.stock, branchId) +
                  (state.originalQuantities[entry.key] ?? 0);
            }
          } catch (_) {}
        }),
      );
    } catch (_) {
      return;
    }
    if (!ref.mounted || caps.isEmpty) return;
    state = state.copyWith(maxQuantities: {...state.maxQuantities, ...caps});
  }

  int _branchStock(stock.Stock s, int branchId) {
    final entry = s.branchStock.where((b) => b.id == branchId).firstOrNull;
    return entry?.stock ?? s.organizationStock;
  }

  ProductItem _mapProduct(stock.ResultDatum r, int branchId) {
    final product = r.product.product;
    return ProductItem(
      id: r.product.id.toString(),
      name: product.name,
      sku: product.skuCode,
      price: parseAmount(product.salePrice),
      categoryKey: '',
      stock: _branchStock(r.product.stock, branchId),
      barcode: product.barcode.isNotEmpty ? product.barcode : product.sysBarcode,
    );
  }

  // ───────────────────────────────────────────────
  // Product search (top search bar)
  // ───────────────────────────────────────────────
  void updateProductQuery(String query) {
    _productDebounce?.cancel();
    state = state.copyWith(productQuery: query, clearProductSearchError: true);
    if (query.trim().length < EditSaleCartState.minProductSearchLength) {
      _productRequestId++; // drop any in-flight response
      state = state.copyWith(productResults: const [], isProductSearching: false);
      return;
    }
    _productDebounce = Timer(_debounceDelay, () => _searchProducts(query.trim()));
  }

  Future<void> retryProductSearch() => _searchProducts(state.productQuery.trim());

  Future<void> _searchProducts(String query) async {
    final requestId = ++_productRequestId;
    state = state.copyWith(isProductSearching: true, clearProductSearchError: true);
    try {
      final branchId = _branchId;
      final result = await _repository.searchProducts(
        branchId: branchId,
        search: query,
        length: _productPageLength,
      );
      if (!ref.mounted || requestId != _productRequestId) return;
      state = state.copyWith(
        isProductSearching: false,
        productResults: [for (final r in result.resultData) _mapProduct(r, branchId)],
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || requestId != _productRequestId) return;
      state = state.copyWith(
        isProductSearching: false,
        productSearchError: getErrorMessage(error, stackTrace),
      );
    }
  }

  void clearProductSearch() {
    _productDebounce?.cancel();
    _productRequestId++;
    productSearchController.clear();
    state = state.copyWith(
      productQuery: '',
      productResults: const [],
      isProductSearching: false,
      clearProductSearchError: true,
    );
  }

  /// Adds one unit of [product]. Stock already sold on this invoice
  /// counts as available (the server returns it when the sale is edited).
  EditCartAddOutcome addProduct(ProductItem product) {
    if (state.remainingFor(product) <= 0) return EditCartAddOutcome.noStock;

    final cap = product.stock + (state.originalQuantities[product.id] ?? 0);
    final items = List<CartLineItem>.from(state.cart.items);
    final index = items.indexWhere((i) => i.id == product.id);
    if (index == -1) {
      items.add(CartLineItem(
        id: product.id,
        name: product.name,
        unitPrice: product.price,
        quantity: 1,
      ));
    } else {
      // Keep the invoice's original unit price for existing lines.
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    }
    state = state.copyWith(
      cart: state.cart.copyWith(items: items),
      maxQuantities: {...state.maxQuantities, product.id: cap},
    );
    _scheduleDiscountRefresh();
    return EditCartAddOutcome.added;
  }

  /// Exact barcode/SKU lookup for the scanner. Never touches the search
  /// bar or its results. Returns null when the lookup itself failed.
  Future<ScanResult?> handleScannedCode(String code) async {
    state = state.copyWith(isScanning: true);
    try {
      final branchId = _branchId;
      final result = await _repository.searchProducts(
        branchId: branchId,
        search: code,
        length: 10,
      );
      if (!ref.mounted) return null;
      state = state.copyWith(isScanning: false);
      final match = result.resultData
          .map((r) => _mapProduct(r, branchId))
          .where((p) => p.barcode == code || p.sku == code)
          .firstOrNull;
      if (match == null) {
        return const ScanResult(product: null, outcome: ScanOutcome.notFound);
      }
      final outcome = addProduct(match);
      return ScanResult(
        product: match,
        outcome: outcome == EditCartAddOutcome.added
            ? ScanOutcome.added
            : ScanOutcome.outOfStock,
      );
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isScanning: false);
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // Line mutations
  // ───────────────────────────────────────────────
  /// False when the stock cap is reached (the view shows a message).
  bool incrementQuantity(String productId) {
    final items = state.cart.items;
    final line = items.where((i) => i.id == productId).firstOrNull;
    if (line == null) return false;
    final cap = state.maxQuantities[productId];
    if (cap != null && line.quantity >= cap) return false;
    _setItems([
      for (final i in items)
        i.id == productId ? i.copyWith(quantity: i.quantity + 1) : i,
    ]);
    return true;
  }

  void decrementQuantity(String productId) {
    _setItems([
      for (final i in state.cart.items)
        if (i.id != productId)
          i
        else if (i.quantity > 1)
          i.copyWith(quantity: i.quantity - 1),
    ]);
  }

  void removeItem(String productId) {
    _setItems(state.cart.items.where((i) => i.id != productId).toList());
  }

  void _setItems(List<CartLineItem> items) {
    state = state.copyWith(cart: state.cart.copyWith(items: items));
    _scheduleDiscountRefresh();
  }

  // ───────────────────────────────────────────────
  // Customer
  // ───────────────────────────────────────────────
  void selectCustomer(cust.ResultDatum customer) {
    state = state.copyWith(
      customerUnmatched: false,
      cart: state.cart.copyWith(selectedCustomer: customer),
    );
    refreshDiscount(); // membership discounts are customer-specific
  }

  void updateCustomerSearchQuery(String query) {
    final cart = state.cart;
    state = state.copyWith(cart: cart.copyWith(customerSearchQuery: query));
    _customerDebounce?.cancel();
    if (query.isEmpty || query.length >= _minCustomerSearchLength) {
      _customerDebounce = Timer(_debounceDelay, () => searchCustomers(reset: true));
    }
  }

  String get _effectiveCustomerSearch {
    final query = state.cart.customerSearchQuery;
    return query.length >= _minCustomerSearchLength ? query : '';
  }

  void ensureCustomersLoaded() {
    final cart = state.cart;
    if (cart.customerResults.isEmpty && !cart.isCustomerLoading) {
      searchCustomers(reset: true);
    }
  }

  Future<bool> searchCustomers({bool reset = false}) async {
    state = state.copyWith(
      cart: state.cart.copyWith(
        isCustomerLoading: true,
        customerResults: reset ? const [] : null,
        customerCurrentStart: reset ? 0 : null,
        customerHasMore: reset ? true : null,
      ),
    );
    try {
      final customers = await _cartRepository.getCustomers(
        start: 0,
        length: _customerPageLength,
        search: _effectiveCustomerSearch,
      );
      if (!ref.mounted) return false;
      state = state.copyWith(
        cart: state.cart.copyWith(
          isCustomerLoading: false,
          customerResults: customers.resultData,
          customerCurrentStart: 0,
          customerHasMore: customers.resultData.length < customers.recordsFiltered,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        cart: state.cart.copyWith(
          isCustomerLoading: false,
          customerErrorMessage: getErrorMessage(error, stackTrace),
        ),
      );
      return false;
    }
  }

  Future<void> loadMoreCustomers() async {
    final cart = state.cart;
    if (cart.isCustomerLoadingMore || cart.isCustomerLoading || !cart.customerHasMore) {
      return;
    }
    state = state.copyWith(cart: cart.copyWith(isCustomerLoadingMore: true));
    try {
      final nextStart = cart.customerCurrentStart + _customerPageLength;
      final customers = await _cartRepository.getCustomers(
        start: nextStart,
        length: _customerPageLength,
        search: _effectiveCustomerSearch,
      );
      if (!ref.mounted) return;
      final current = state.cart;
      state = state.copyWith(
        cart: current.copyWith(
          isCustomerLoadingMore: false,
          customerResults: [...current.customerResults, ...customers.resultData],
          customerCurrentStart: nextStart,
          customerHasMore:
          (nextStart + customers.resultData.length) < customers.recordsFiltered,
        ),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        cart: state.cart.copyWith(
          isCustomerLoadingMore: false,
          customerErrorMessage: getErrorMessage(error, stackTrace),
        ),
      );
    }
  }

  /// Creates a customer and selects them. Never falls back to "first
  /// search result" — a wrong customer on an invoice is worse than
  /// asking the salesman to search.
  Future<cust.ResultDatum?> createAndSelectCustomer({
    required String name,
    required String mobile,
    String email = '',
    String address = '',
  }) async {
    state = state.copyWith(cart: state.cart.copyWith(isAddingCustomer: true));
    try {
      final created = await _cartRepository.createCustomer(
        customerName: name,
        customerMobile: mobile,
        customerEmail: email,
        address: address,
        branchId: _branchId,
      );
      final lookup = await _cartRepository.getCustomers(
        start: 0,
        length: 5,
        search: mobile,
      );
      if (!ref.mounted) return null;

      var customer = lookup.resultData
          .where((c) => c.customerMobile.trim() == mobile)
          .firstOrNull;
      if (customer == null && created.id.trim().isNotEmpty) {
        customer = cust.ResultDatum(
          sl: 0,
          customerNo: created.id.trim(),
          customerName: created.customerName,
          customerType: 1,
          isPurchase: null,
          customerMobile: mobile,
          customerEmail: email,
          branchName: '',
        );
      }
      if (customer == null) {
        state = state.copyWith(
          cart: state.cart.copyWith(
            isAddingCustomer: false,
            addCustomerErrorMessage: AppStrings.editSaleCustomerCreatedNotFound,
          ),
        );
        return null;
      }

      state = state.copyWith(
        customerUnmatched: false,
        cart: state.cart.copyWith(isAddingCustomer: false, selectedCustomer: customer),
      );
      refreshDiscount();
      return customer;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        cart: state.cart.copyWith(
          isAddingCustomer: false,
          addCustomerErrorMessage: getErrorMessage(error, stackTrace),
        ),
      );
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // Discount + VAT (port of CartController's rules)
  // ───────────────────────────────────────────────
  double _round2(double v) => (v * 100).round() / 100;

  void setDiscountType(DiscountType type) {
    final cart = state.cart;
    if (type == cart.discountType) return;
    final converted = type == DiscountType.percent
        ? _round2(cart.discountPercent)
        : _round2(cart.discountAmount);
    state = state.copyWith(
      cart: cart.copyWith(discountType: type, discountInput: converted),
    );
  }

  /// The seller types freely but never above the server cap.
  void updateDiscountInput(double value) {
    final cart = state.cart;
    var v = value < 0 ? 0.0 : value;
    var rewritten = false;
    if (cart.canEnterDiscount && cart.hasDiscountCap) {
      final cap = cart.maxDiscountInput;
      if (cap > 0 && v > cap) {
        v = _round2(cap);
        rewritten = true;
      }
    }
    state = state.copyWith(
      cart: cart.copyWith(
        discountInput: v,
        discountFieldRevision: rewritten ? cart.discountFieldRevision + 1 : null,
      ),
    );
  }

  void setDiscountBasis(DiscountBasis basis) {
    if (basis == state.cart.discountBasis) return;
    state = state.copyWith(cart: state.cart.copyWith(discountBasis: basis));
    refreshDiscount(basisChange: true);
  }

  void updateTaxPercent(double value) {
    state = state.copyWith(
      cart: state.cart.copyWith(taxPercent: value < 0 ? 0 : value),
    );
  }

  void _scheduleDiscountRefresh() {
    _discountDebounce?.cancel();
    _discountDebounce = Timer(_debounceDelay, () => refreshDiscount());
  }

  void _clearDiscount() {
    _discountRequestId++; // invalidate any in-flight response
    final cart = state.cart;
    state = state.copyWith(
      cart: cart.copyWith(
        clearDiscount: true,
        isGetDiscountLoading: false,
        bothChoice: false,
        discountInput: 0,
        discountFieldRevision: cart.discountFieldRevision + 1,
      ),
    );
  }

  /// GET /get_discount — on load, every line change, customer change and
  /// basis change. Uses the original sale date and the session branch.
  Future<bool> refreshDiscount({bool basisChange = false}) async {
    final items = state.cart.items;
    if (items.isEmpty) {
      _clearDiscount();
      return false;
    }

    final requestId = ++_discountRequestId;
    final before = state.cart;
    state = state.copyWith(cart: before.copyWith(isGetDiscountLoading: true));

    try {
      final model = await _cartRepository.getGetDiscount(
        customerId: before.selectedCustomer?.customerNo,
        amounts: [for (final i in items) _round2(i.lineTotal)],
        productIds: [for (final i in items) i.id],
        quantities: [for (final i in items) i.quantity],
        discountType: before.bothChoice ? before.discountBasis.name : null,
        branchId: _branchId,
        salesDate: _saleDate,
      );
      if (!ref.mounted || requestId != _discountRequestId) return false;

      final current = state.cart;
      final scope = (model.resultData?.discountScope ?? '').toLowerCase();
      final applied = model.resultData?.discountApplied == true;
      final both = applied &&
          (scope == 'both' ||
              (basisChange &&
                  current.bothChoice &&
                  (scope == 'bill' || scope == 'product')));

      var next = current.copyWith(
        getDiscountModel: model,
        isGetDiscountLoading: false,
        bothChoice: both,
      );
      // Rule changed (e.g. Regular -> Bill): drop any manually typed value.
      if (next.rule != current.rule) {
        next = next.copyWith(
          discountInput: 0,
          discountFieldRevision: current.discountFieldRevision + 1,
        );
      }
      state = state.copyWith(cart: _applyOriginalDiscount(next));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted || requestId != _discountRequestId) return false;
      final current = state.cart;
      // Never leave a stale discount applied after a failed check.
      state = state.copyWith(
        cart: current.copyWith(
          clearDiscount: true,
          bothChoice: false,
          isGetDiscountLoading: false,
          discountInput: 0,
          discountFieldRevision: current.discountFieldRevision + 1,
          discountErrorMessage: getErrorMessage(error, stackTrace),
        ),
      );
      return false;
    }
  }

  /// First discount response only: if the rule is still the manual
  /// "regular" one, re-apply the invoice's original bill discount %
  /// (clamped to today's cap). Product/bill rules are auto-applied by
  /// the server, so nothing is needed for those.
  CartState _applyOriginalDiscount(CartState cart) {
    final rate = _pendingDiscountRate;
    if (rate == null) return cart;
    _pendingDiscountRate = null;
    if (cart.rule != DiscountRule.regular) return cart;

    var next = cart.copyWith(discountType: DiscountType.percent, discountInput: rate);
    if (next.hasDiscountCap) {
      final cap = next.maxDiscountInput;
      if (cap > 0 && rate > cap) next = next.copyWith(discountInput: _round2(cap));
    }
    return next.copyWith(discountFieldRevision: next.discountFieldRevision + 1);
  }
}