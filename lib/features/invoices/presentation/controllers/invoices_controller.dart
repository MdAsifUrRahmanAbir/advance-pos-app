import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/model/invoices_model.dart';
import '../../data/repositories/invoices_repository.dart';
import '../states/invoices_state.dart';

final invoicesControllerProvider =
NotifierProvider.autoDispose<InvoicesController, InvoicesState>(
  InvoicesController.new,
);

class InvoicesController extends Notifier<InvoicesState> {
  late final TextEditingController searchController;

  InvoicesRepository get _repository => ref.read(invoicesRepositoryProvider);

  static const int _pageLength = 15;

  @override
  InvoicesState build() {
    searchController = TextEditingController();
    ref.onDispose(() => searchController.dispose());

    Future.microtask(getInvoices);

    return InvoicesState.initial();
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);
    getInvoices(reset: true);
  }

  Future<void> refresh() async {
    await getInvoices(reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isInvoicesLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      errorMessage: null,
      technicalDetails: null,
    );
    try {
      final nextStart = state.currentStart + _pageLength;
      final invoices = await _repository.getInvoices(
        start: nextStart,
        length: _pageLength,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isLoadingMore: false,
        invoicesModel: invoices,
        allItems: [...state.allItems, ...invoices.resultData],
        currentStart: nextStart,
        hasMore:
        (nextStart + invoices.resultData.length) < invoices.recordsFiltered,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.invoices,
        ),
      );
    }
  }

  Future<bool> getInvoices({bool reset = false}) async {
    state = state.copyWith(
      isInvoicesLoading: true,
      errorMessage: null,
      technicalDetails: null,
      allItems: reset ? [] : state.allItems,
      currentStart: reset ? 0 : state.currentStart,
      hasMore: reset ? true : state.hasMore,
    );
    try {
      final invoices = await _repository.getInvoices(
        start: 0,
        length: _pageLength,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isInvoicesLoading: false,
        invoicesModel: invoices,
        allItems: invoices.resultData,
        currentStart: 0,
        hasMore: invoices.resultData.length < invoices.recordsFiltered,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isInvoicesLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.invoices,
        ),
      );
      return false;
    }
  }
}