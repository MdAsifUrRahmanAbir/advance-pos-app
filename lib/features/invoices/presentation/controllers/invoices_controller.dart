import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/invoices_repository.dart';
import '../states/invoice_date_presets.dart';
import '../states/invoice_filter.dart';
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

  void selectStatus(String statusKey) {
    final hadDatePreset = state.selectedDatePreset != null;
    state = state.copyWith(
      selectedStatus: statusKey,
      clearSelectedDatePreset: true,
      filter: state.filter.clearing(startDate: true, endDate: true),
    );
    // Only need to refetch if a date preset was actually active before —
    // pure status switching is a client-side filter over already-loaded data.
    if (hadDatePreset) {
      getInvoices(reset: true);
    }
  }

  /// Tapping a date-preset chip (Today/Yesterday/Last 7 Days/This
  /// Month/Last Month) computes concrete dates and applies them
  /// immediately. Tapping the already-active preset again clears the
  /// date filter back to "any date". Quick Filter row is single-select
  /// overall, so picking a date preset also resets the status chip
  /// back to "all".
  Future<void> selectDatePreset(String? presetKey) async {
    if (presetKey == null) {
      state = state.copyWith(
        clearSelectedDatePreset: true,
        filter: state.filter.clearing(startDate: true, endDate: true),
      );
    } else {
      final range = InvoiceDatePresets.rangeFor(presetKey);
      state = state.copyWith(
        selectedStatus: 'all',
        selectedDatePreset: presetKey,
        filter: state.filter.copyWith(startDate: range.start, endDate: range.end),
      );
    }
    await getInvoices(reset: true);
  }


  /// A text search and the drawer filter are mutually-exclusive ways of
  /// narrowing the list — running a search clears any active filter
  /// (group/category/etc.) and date preset, same rationale as Stock.
  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(
      searchQuery: query,
      filter: InvoiceFilter.empty,
      clearSelectedDatePreset: true,
    );
    getInvoices(reset: true);
  }


  /// Applied by [InvoiceFilterDrawer]'s "Apply" button — replaces the
  /// active filter (including any custom date range picked there) and
  /// refetches from scratch. Clears the quick-preset chip highlight
  /// since the drawer's own date range now takes precedence — note this
  /// also happens if the user opens the drawer and applies without
  /// touching dates at all, a minor UX nuance rather than a bug.
  Future<void> applyFilter(InvoiceFilter filter) async {
    state = state.copyWith(filter: filter, clearSelectedDatePreset: true);
    await getInvoices(reset: true);
  }

  Future<void> clearFilter() async {
    state = state.copyWith(filter: InvoiceFilter.empty, clearSelectedDatePreset: true);
    await getInvoices(reset: true);
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
        groupId: state.filter.groupId,
        categoryId: state.filter.categoryId,
        subCategoryId: state.filter.subCategoryId,
        brandId: state.filter.brandId,
        customerId: state.filter.customerId,
        employeeId: state.filter.employeeId,
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
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
        groupId: state.filter.groupId,
        categoryId: state.filter.categoryId,
        subCategoryId: state.filter.subCategoryId,
        brandId: state.filter.brandId,
        customerId: state.filter.customerId,
        employeeId: state.filter.employeeId,
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
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


  // ───────────────────────────────────────────────
  // DELETE
  // ───────────────────────────────────────────────
  Future<bool> invoiceDelete(String billNo) async {
    state = state.copyWith(isCommonSuccessLoading: true, errorMessage: null);
    try {
      await _repository.deleteCommonSuccess(billNo);
      state = state.copyWith(
        isCommonSuccessLoading: false,
        allItems: state.allItems
            .where((invoice) => invoice.salesBillNo != billNo)
            .toList(),
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isCommonSuccessLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

}
