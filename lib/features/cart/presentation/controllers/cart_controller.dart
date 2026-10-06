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
      _discountDebounce?.cancel();
    });

    ref.listen<new_sale.NewSaleState>(newSaleControllerProvider, (
        previous,
        next,
        ) {
      final items = _mapFromNewSale(next.cartItems);
      final changed = _signature(items) != _signature(state.items);
      state = state.copyWith(items: items);
      if (changed) _scheduleDiscountRefresh();
    });

    final initialItems = _mapFromNewSale(
      ref.read(newSaleControllerProvider).cartItems,
    );

    // Customer is optional — check discounts as soon as the cart opens.
    Future.microtask(getGetDiscount);

    return CartState.initial().copyWith(items: initialItems);
  }


  void selectCustomer(ResultDatum customer) {
    state = state.copyWith(selectedCustomer: customer);
    getGetDiscount(); // discounts are customer-specific
  }

  void setDiscountType(DiscountType type) {
    if (type == state.discountType) return;
    final converted = type == DiscountType.percent
        ? _round2(state.discountPercent)
        : _round2(state.discountAmount);
    state = state.copyWith(discountType: type, discountInput: converted);
  }

  /// Regular rule: the seller types freely but never above the server cap.
  void updateDiscountInput(double value) {
    var v = value < 0 ? 0.0 : value;
    var rewritten = false;
    if (state.canEnterDiscount && state.hasDiscountCap) {
      final cap = state.maxDiscountInput;
      if (cap > 0 && v > cap) {
        v = _round2(cap);
        rewritten = true;
      }
    }
    state = state.copyWith(
      discountInput: v,
      discountFieldRevision:
      rewritten ? state.discountFieldRevision + 1 : null,
    );
  }

  /// Radio shown when the server returns scope "both".
  void setDiscountBasis(DiscountBasis basis) {
    if (basis == state.discountBasis) return;
    state = state.copyWith(discountBasis: basis);
    getGetDiscount(basisChange: true);
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


  void updateRemarks(String remarks) =>
      state = state.copyWith(remarks: remarks);

  void updateReferenceNo(String referenceNo) =>
      state = state.copyWith(referenceNo: referenceNo);

  double _round2(double v) => (v * 100).round() / 100;

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
        !state.customerHasMore) {
      return;
    }
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


  Timer? _discountDebounce;
  int _discountRequestId = 0;


  String _signature(List<CartLineItem> items) =>
      items.map((i) => '${i.id}:${i.quantity}:${i.unitPrice}').join('|');

  void _scheduleDiscountRefresh() {
    _discountDebounce?.cancel();
    _discountDebounce =
        Timer(const Duration(milliseconds: 400), () => getGetDiscount());
  }

  void _clearDiscount() {
    _discountRequestId++; // invalidate any in-flight response
    state = state.copyWith(
      clearDiscount: true,
      isGetDiscountLoading: false,
      bothChoice: false,
      discountInput: 0,
      discountFieldRevision: state.discountFieldRevision + 1,
    );
  }

  // ───────────────────────────────────────────────
  // GET /get_discount
  // Runs on cart open, on every cart change, and when a customer is
  // selected (membership customers can have special discounts). The
  // customer is optional — customerId is simply omitted until chosen.
  // ───────────────────────────────────────────────
  Future<bool> getGetDiscount({bool basisChange = false}) async {
    final items = state.items;
    if (items.isEmpty) {
      _clearDiscount();
      return false;
    }

    final requestId = ++_discountRequestId;
    state = state.copyWith(isGetDiscountLoading: true);

    try {
      final model = await _repository.getGetDiscount(
        customerId: state.selectedCustomer?.customerNo,
        // amount = unit price × quantity (line total), per the API contract
        amounts: [for (final i in items) _round2(i.lineTotal)],
        productIds: [for (final i in items) i.id],
        quantities: [for (final i in items) i.quantity],
        discountType: state.bothChoice ? state.discountBasis.name : null,
      );
      if (requestId != _discountRequestId) return false; // stale response

      final scope = (model.resultData?.discountScope ?? '').toLowerCase();
      final applied = model.resultData?.discountApplied == true;
      final both = applied &&
          (scope == 'both' ||
              (basisChange &&
                  state.bothChoice &&
                  (scope == 'bill' || scope == 'product')));

      var next = state.copyWith(
        getDiscountModel: model,
        isGetDiscountLoading: false,
        bothChoice: both,
      );
      // Rule changed (e.g. Regular -> Bill, or a membership rule kicked in):
      // drop any manually typed value.
      if (next.rule != state.rule) {
        next = next.copyWith(
          discountInput: 0,
          discountFieldRevision: state.discountFieldRevision + 1,
        );
      }
      state = next;
      return true;
    } catch (error, stackTrace) {
      if (requestId != _discountRequestId) return false;
      // Never leave a stale discount applied after a failed check.
      state = state.copyWith(
        clearDiscount: true,
        bothChoice: false,
        isGetDiscountLoading: false,
        discountInput: 0,
        discountFieldRevision: state.discountFieldRevision + 1,
        discountErrorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}
