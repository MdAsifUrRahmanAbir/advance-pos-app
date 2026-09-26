import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/customers_repository.dart';
import '../states/customers_state.dart';

final customersControllerProvider =
NotifierProvider.autoDispose<CustomersController, CustomersState>(CustomersController.new);

class CustomersController extends Notifier<CustomersState> {
  late final TextEditingController searchController;

  CustomersRepository get _repository => ref.read(customersRepositoryProvider);

  static const int _pageLength = 20;
  static const int _minSearchLength = 3;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;

  @override
  CustomersState build() {
    searchController = TextEditingController();
    ref.onDispose(() {
      searchController.dispose();
      _debounce?.cancel();
    });

    Future.microtask(getCustomers);

    return CustomersState.initial();
  }

  /// Client-side only — see [CustomersState.filteredItems].
  void selectType(String typeKey) {
    state = state.copyWith(selectedType: typeKey);
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);

    _debounce?.cancel();
    if (query.isEmpty) {
      _runSearch(query);
      return;
    }
    if (query.length < _minSearchLength) return;

    _debounce = Timer(_debounceDelay, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    state = state.copyWith(searchQuery: query);
    await getCustomers(reset: true);
  }

  Future<void> refresh() async {
    await getCustomers(reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isCustomersLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final nextStart = state.currentStart + _pageLength;
      final customers = await _repository.getCustomers(
        start: nextStart,
        length: _pageLength,
        search: state.searchQuery,
      );
      state = state.copyWith(
        isLoadingMore: false,
        customersModel: customers,
        allItems: [...state.allItems, ...customers.resultData],
        currentStart: nextStart,
        hasMore: (nextStart + customers.resultData.length) < customers.recordsFiltered,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

  Future<bool> getCustomers({bool reset = false}) async {
    state = state.copyWith(
      isCustomersLoading: true,
      errorMessage: null,
      allItems: reset ? [] : state.allItems,
      currentStart: reset ? 0 : state.currentStart,
      hasMore: reset ? true : state.hasMore,
    );

    try {
      final customers = await _repository.getCustomers(
        start: 0,
        length: _pageLength,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isCustomersLoading: false,
        customersModel: customers,
        allItems: customers.resultData,
        currentStart: 0,
        hasMore: customers.resultData.length < customers.recordsFiltered,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isCustomersLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}