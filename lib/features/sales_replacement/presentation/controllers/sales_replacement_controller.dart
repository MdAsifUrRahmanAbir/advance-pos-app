import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../sales_replacement_add/presentation/states/sales_replacement_receipt.dart';
import '../../../sales_replacement_detail/data/models/sales_replacement_detail_model.dart'
    show ResultData;
import '../../../sales_replacement_detail/data/repositories/sales_replacement_detail_repository.dart';
import '../../data/repositories/sales_replacement_repository.dart';
import '../states/sales_replacement_format.dart';
import '../states/sales_replacement_state.dart';

final salesReplacementControllerProvider =
NotifierProvider.autoDispose<SalesReplacementController, SalesReplacementState>(
  SalesReplacementController.new,
);

class SalesReplacementController extends Notifier<SalesReplacementState> {
  static const int _pageSize = 15;
  static const double _loadMoreThreshold = 200;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  // Not `late final`: build() re-runs on invalidate and must be able to
  // assign fresh controllers after onDispose disposed the old ones.
  late TextEditingController searchController;
  late ScrollController scrollController;
  Timer? _debounce;
  int _requestSeq = 0;
  bool _resetInFlight = false;

  SalesReplacementRepository get _repository =>
      ref.read(salesReplacementRepositoryProvider);

  SalesReplacementDetailRepository get _detailRepository =>
      ref.read(salesReplacementDetailRepositoryProvider);

  @override
  SalesReplacementState build() {
    searchController = TextEditingController();
    scrollController = ScrollController()..addListener(_onScroll);
    ref.onDispose(() {
      _debounce?.cancel();
      searchController.dispose();
      scrollController.dispose();
    });
    Future.microtask(() {
      if (ref.mounted) loadItems();
    });
    return const SalesReplacementState(isInitialLoading: true);
  }

  // ───────────────────────────────────────────────
  // Filters
  // ───────────────────────────────────────────────
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!ref.mounted) return;
      final query = value.trim();
      if (query == state.searchQuery) return;
      state = state.copyWith(searchQuery: query);
      loadItems();
    });
  }

  void applyDatePreset(SalesReplacementDatePreset preset, {DateTimeRange? range}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? from;
    DateTime? to;

    switch (preset) {
      case SalesReplacementDatePreset.all:
        break;
      case SalesReplacementDatePreset.today:
        from = to = today;
      case SalesReplacementDatePreset.yesterday:
        from = to = today.subtract(const Duration(days: 1));
      case SalesReplacementDatePreset.last7Days:
        from = today.subtract(const Duration(days: 6));
        to = today;
      case SalesReplacementDatePreset.thisMonth:
        from = DateTime(today.year, today.month, 1);
        to = DateTime(today.year, today.month + 1, 0);
      case SalesReplacementDatePreset.lastMonth:
        from = DateTime(today.year, today.month - 1, 1);
        to = DateTime(today.year, today.month, 0);
      case SalesReplacementDatePreset.custom:
        from = range?.start;
        to = range?.end;
    }

    state = state.copyWith(
      datePreset: from == null ? SalesReplacementDatePreset.all : preset,
      fromDate: from,
      toDate: to,
      clearDates: from == null,
    );
    loadItems();
  }

  // ───────────────────────────────────────────────
  // GET (list + pagination)
  // ───────────────────────────────────────────────
  /// Full reload; the skeleton shows either way. [keepCurrent] (pull-to-
  /// refresh) keeps the old list in state so a failed refresh can fall back
  /// to it; otherwise the list is cleared.
  Future<bool> loadItems({bool keepCurrent = false}) {
    state = keepCurrent
        ? state.copyWith(isLoadMoreFailed: false, isRefreshing: true)
        : state.copyWith(
      items: const [],
      isInitialLoading: true,
      isRefreshing: false,
      hasMore: false,
      totalCount: 0,
      isLoadMoreFailed: false,
    );
    _resetInFlight = true;
    return _fetch(reset: true);
  }

  Future<bool> refresh() => loadItems(keepCurrent: true);

  Future<bool> loadMore() {
    // A load-more must never start while a reset is running: it would bump
    // the request counter and drop the reset's response.
    if (_resetInFlight ||
        state.isInitialLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return Future.value(false);
    }
    state = state.copyWith(isLoadingMore: true, isLoadMoreFailed: false);
    return _fetch(reset: false);
  }

  Future<bool> _fetch({required bool reset}) async {
    final requestId = ++_requestSeq; // newer request wins; stale ones dropped
    try {
      final result = await _repository.getSalesReplacements(
        start: reset ? 0 : state.items.length,
        length: _pageSize,
        search: state.searchQuery,
        dateRange: SalesReplacementFormat.dateRange(state.fromDate, state.toDate),
      );
      if (!ref.mounted || requestId != _requestSeq) return true;

      final merged = reset
          ? result.resultData
          : [...state.items, ...result.resultData];
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        isLoadMoreFailed: false,
        isRefreshing: false,
        items: merged,
        totalCount: result.recordsFiltered,
        hasMore:
        result.resultData.isNotEmpty &&
            merged.length < result.recordsFiltered,
      );
      _fillViewportIfNeeded();
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted || requestId != _requestSeq) return true;
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        isLoadMoreFailed: !reset,
        isRefreshing: false,
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.salesReplacement,
        ),
      );
      return false;
    } finally {
      if (reset && requestId == _requestSeq) _resetInFlight = false;
    }
  }

  // ───────────────────────────────────────────────
  // DELETE
  // ───────────────────────────────────────────────
  /// Deletes one replacement, then removes it from the loaded list locally so
  /// the server offset stays in step with [SalesReplacementState.items].length.
  /// Returns false on failure ([SalesReplacementState.errorMessage] is set) or
  /// when another row action is already running.
  Future<bool> deleteSalesReplacement(String returnBillNo) async {
    if (state.isRowBusy) return false;
    state = state.copyWith(deletingBillNo: returnBillNo);
    try {
      await _repository.deleteSalesReplacement(returnBillNo);
      if (!ref.mounted) return true;

      final remaining = state.items
          .where((e) => e.returnBillNo != returnBillNo)
          .toList();
      final removed = state.items.length - remaining.length;
      final total = state.totalCount - removed;
      state = state.copyWith(
        clearDeleting: true,
        items: remaining,
        totalCount: total < 0 ? 0 : total,
        hasMore: state.hasMore && remaining.length < total,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        clearDeleting: true,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Send / Bill preview (one row's full bill)
  // ───────────────────────────────────────────────
  /// Loads the whole replacement behind a row, for Send and Bill Preview.
  /// Returns null on failure ([SalesReplacementState.errorMessage] is set)
  /// or when another row action is already running.
  Future<ResultData?> fetchBill(String returnBillNo) async {
    if (state.isRowBusy) return null;
    state = state.copyWith(loadingBillNo: returnBillNo);
    try {
      final detail = await _detailRepository.getSalesReplacementDetail(returnBillNo);
      if (!ref.mounted) return null;
      state = state.copyWith(clearLoadingBill: true);
      return detail.resultData;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        clearLoadingBill: true,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return null;
    }
  }

  /// Shares the previewed bill as an image.
  Future<bool> shareBillImage(GlobalKey boundaryKey, String billNo) async {
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId: billNo,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Prints the previewed bill on the chosen Bluetooth printer.
  Future<bool> printBill(SalesReplacementReceipt receipt, String printerMac) async {
    try {
      final connected = await ThermalPrinterService.isConnected() ||
          await ThermalPrinterService.connect(printerMac);
      return connected &&
          await ThermalPrinterService.printReceipt(
            storeName: AppStrings.appBrandName,
            billNo: receipt.billNo,
            saleDate: receipt.date,
            methodLabel: receipt.methodLabel,
            returnedItems: receipt.returned,
            returnedHeading: AppStrings.repdReturnedSectionTitle,
            itemsHeading: AppStrings.repdReplacementSectionTitle,
            items: receipt.replacement,
            subtotal: receipt.newTotal,
            discount: receipt.returnTotal,
            discountLabel: AppStrings.repdReturnAmountLabel,
            total: receipt.netPayable,
            givenAmount: receipt.collected,
            changeDue: receipt.change,
          );
    } catch (_) {
      return false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients || state.isLoadMoreFailed) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      loadMore();
    }
  }

  /// Tall screens may show the first page without scrolling, so no scroll
  /// event would ever request page 2.
  void _fillViewportIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted || !scrollController.hasClients) return;
      if (scrollController.position.maxScrollExtent <= 0) loadMore();
    });
  }
}