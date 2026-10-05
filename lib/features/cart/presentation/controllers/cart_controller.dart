import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../new_sale/presentation/controllers/new_sale_controller.dart';
import '../../../new_sale/presentation/states/new_sale_state.dart' as new_sale;
import '../../data/models/customers_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../states/cart_state.dart';

final cartControllerProvider =
    NotifierProvider.autoDispose<CartController, CartState>(CartController.new);

/// Owns everything checkout-related EXCEPT the product cart itself:
/// customer, remarks, reference no., discount/tax/rounding, and the
/// customer search/pagination + add-customer flow.
///
/// The product cart lines live in [NewSaleController] (single source of
/// truth, since it owns stock-capping). This controller mirrors them
/// into its own [CartState.items] shape via `ref.listen` — NOT
/// `ref.watch` — so a New Sale cart change only refreshes `items`, never
/// wipes out customer/remarks/customer-search state accumulated here.
class CartController extends Notifier<CartState> {
  late final TextEditingController customerSearchController;

  CartRepository get _repository => ref.read(cartRepositoryProvider);

  static const int _customerPageLength = 20;
  static const int _minCustomerSearchLength = 4;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;

  List<CartLineItem> _mapFromNewSale(List<new_sale.CartLineItem> lines) {
    return [
      for (final line in lines)
        CartLineItem(
          id: line.product.id,
          name: line.product.name,
          unitPrice: line.product.price,
          quantity: line.quantity,
        ),
    ];
  }

  @override
  CartState build() {
    customerSearchController = TextEditingController();
    ref.onDispose(() {
      customerSearchController.dispose();
      _debounce?.cancel();
    });

    ref.listen<new_sale.NewSaleState>(newSaleControllerProvider, (
      previous,
      next,
    ) {
      state = state.copyWith(items: _mapFromNewSale(next.cartItems));
    });

    final initialItems = _mapFromNewSale(
      ref.read(newSaleControllerProvider).cartItems,
    );

    return CartState.initial().copyWith(items: initialItems);
  }

  // --- Cart line mutations: delegate to NewSaleController, the single
  // owner of stock-capping logic. ---
  void incrementQuantity(String itemId) =>
      ref.read(newSaleControllerProvider.notifier).increaseQty(itemId);

  void decrementQuantity(String itemId) =>
      ref.read(newSaleControllerProvider.notifier).decreaseQty(itemId);

  void removeItem(String itemId) =>
      ref.read(newSaleControllerProvider.notifier).removeFromCart(itemId);

  void clearAll() => ref.read(newSaleControllerProvider.notifier).clearAll();

  // --- Checkout fields owned here ---
  void selectCustomer(ResultDatum customer) =>
      state = state.copyWith(selectedCustomer: customer);

  void updateRemarks(String remarks) =>
      state = state.copyWith(remarks: remarks);

  void updateReferenceNo(String referenceNo) =>
      state = state.copyWith(referenceNo: referenceNo);

  double _round2(double v) => (v * 100).round() / 100;

  /// Switching the discount mode converts the current discount into the
  /// new mode, so the effective discount stays the same (e.g. 10% on
  /// ৳1000 becomes ৳100 when switching to amount).
  void setDiscountType(DiscountType type) {
    if (type == state.discountType) return;
    final converted = type == DiscountType.percent
        ? _round2(state.discountPercent)
        : _round2(state.discountAmount);
    state = state.copyWith(discountType: type, discountInput: converted);
  }

  void updateDiscountInput(double value) =>
      state = state.copyWith(discountInput: value < 0 ? 0 : value);

  void updateTaxPercent(double value) =>
      state = state.copyWith(taxPercent: value < 0 ? 0 : value);

  // --- Customer search / pagination ---
  void updateCustomerSearchQuery(String query) {
    customerSearchController.value = customerSearchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(customerSearchQuery: query);

    _debounce?.cancel();
    if (query.isEmpty || query.length >= _minCustomerSearchLength) {
      _debounce = Timer(_debounceDelay, () => searchCustomers(reset: true));
    }
  }

  Future<bool> searchCustomers({bool reset = false}) async {
    state = state.copyWith(
      isCustomerLoading: true,
      customerErrorMessage: null,
      customerResults: reset ? [] : state.customerResults,
      customerCurrentStart: reset ? 0 : state.customerCurrentStart,
      customerHasMore: reset ? true : state.customerHasMore,
    );
    try {
      final effectiveSearch =
          state.customerSearchQuery.length >= _minCustomerSearchLength
          ? state.customerSearchQuery
          : '';
      final customers = await _repository.getCustomers(
        start: 0,
        length: _customerPageLength,
        search: effectiveSearch,
      );
      state = state.copyWith(
        isCustomerLoading: false,
        customerResults: customers.resultData,
        customerCurrentStart: 0,
        customerHasMore:
            customers.resultData.length < customers.recordsFiltered,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isCustomerLoading: false,
        customerErrorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  Future<void> loadMoreCustomers() async {
    if (state.isCustomerLoadingMore ||
        state.isCustomerLoading ||
        !state.customerHasMore)
      return;
    state = state.copyWith(
      isCustomerLoadingMore: true,
      customerErrorMessage: null,
    );
    try {
      final nextStart = state.customerCurrentStart + _customerPageLength;
      final effectiveSearch =
          state.customerSearchQuery.length >= _minCustomerSearchLength
          ? state.customerSearchQuery
          : '';
      final customers = await _repository.getCustomers(
        start: nextStart,
        length: _customerPageLength,
        search: effectiveSearch,
      );
      state = state.copyWith(
        isCustomerLoadingMore: false,
        customerResults: [...state.customerResults, ...customers.resultData],
        customerCurrentStart: nextStart,
        customerHasMore:
            (nextStart + customers.resultData.length) <
            customers.recordsFiltered,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isCustomerLoadingMore: false,
        customerErrorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

  /// Loads the first page once per controller lifetime — called when
  /// [CustomerSearchSheet] opens.
  void ensureCustomersLoaded() {
    if (state.customerResults.isEmpty && !state.isCustomerLoading) {
      searchCustomers(reset: true);
    }
  }

  // --- Add customer (POST /customer/add) ---

  /// Creates the customer via the API, then re-fetches it from the
  /// customer *list* endpoint by mobile number to get back a real
  /// [ResultDatum] (with the server-assigned `sl`/customer_no) — never
  /// fabricates one locally from the form fields, since the create
  /// response shape (`AddCustomerModel`) doesn't necessarily mirror the
  /// list shape.
  ///
  /// On success, selects the new customer as the cart's current
  /// customer and returns it. Returns `null` on failure (message left
  /// in [CartState.addCustomerErrorMessage] for the sheet to show).
  Future<ResultDatum?> createAndSelectCustomer({
    required String name,
    required String mobile,
    String email = '',
    String address = '',
  }) async {
    state = state.copyWith(
      isAddingCustomer: true,
      addCustomerErrorMessage: null,
    );
    try {
      await _repository.createCustomer(
        customerName: name,
        customerMobile: mobile,
        customerEmail: email,
        address: address,
      );

      final lookup = await _repository.getCustomers(
        start: 0,
        length: 5,
        search: mobile,
      );
      final created =
          lookup.resultData
              .where((c) => c.customerMobile == mobile)
              .firstOrNull ??
          lookup.resultData.firstOrNull;

      if (created == null) {
        state = state.copyWith(
          isAddingCustomer: false,
          addCustomerErrorMessage:
              'Customer was created but could not be found in the list. Please search manually.',
        );
        return null;
      }

      state = state.copyWith(
        isAddingCustomer: false,
        selectedCustomer: created,
      );
      return created;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isAddingCustomer: false,
        addCustomerErrorMessage: getErrorMessage(error, stackTrace),
      );
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getGetDiscount() async {
    state = state.copyWith(isGetDiscountLoading: true);
    try {
      final getDiscount = await _repository.getGetDiscount();
      state = state.copyWith(
        isGetDiscountLoading: false,
        getDiscountModel: getDiscount,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isGetDiscountLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}
