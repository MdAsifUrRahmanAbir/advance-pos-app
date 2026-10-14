import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/sales_return_repository.dart';
import '../states/sales_return_format.dart';
import '../states/sales_return_state.dart';

final salesReturnControllerProvider =
NotifierProvider.autoDispose<SalesReturnController, SalesReturnState>(
  SalesReturnController.new,
);

class SalesReturnController extends Notifier<SalesReturnState> {
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

  SalesReturnRepository get _repository =>
      ref.read(salesReturnRepositoryProvider);

  @override
  SalesReturnState build() {
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
    return const SalesReturnState(isInitialLoading: true);
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

  void applyDatePreset(SalesReturnDatePreset preset, {DateTimeRange? range}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? from;
    DateTime? to;

    switch (preset) {
      case SalesReturnDatePreset.all:
        break;
      case SalesReturnDatePreset.today:
        from = to = today;
      case SalesReturnDatePreset.yesterday:
        from = to = today.subtract(const Duration(days: 1));
      case SalesReturnDatePreset.last7Days:
        from = today.subtract(const Duration(days: 6));
        to = today;
      case SalesReturnDatePreset.thisMonth:
        from = DateTime(today.year, today.month, 1);
        to = DateTime(today.year, today.month + 1, 0);
      case SalesReturnDatePreset.lastMonth:
        from = DateTime(today.year, today.month - 1, 1);
        to = DateTime(today.year, today.month, 0);
      case SalesReturnDatePreset.custom:
        from = range?.start;
        to = range?.end;
    }

    state = state.copyWith(
      datePreset: from == null ? SalesReturnDatePreset.all : preset,
      fromDate: from,
      toDate: to,
      clearDates: from == null,
    );
    loadItems();
  }

  // ───────────────────────────────────────────────
  // GET (list + pagination)
  // ───────────────────────────────────────────────
  /// Full reload. [keepCurrent] keeps the visible list (pull-to-refresh);
  /// otherwise the list is cleared and the skeleton shows.
  Future<bool> loadItems({bool keepCurrent = false}) {
    state = keepCurrent
        ? state.copyWith(isLoadMoreFailed: false)
        : state.copyWith(
      items: const [],
      isInitialLoading: true,
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
      final result = await _repository.getSalesReturns(
        start: reset ? 0 : state.items.length,
        length: _pageSize,
        branchId: ref.read(sessionBranchIdProvider),
        search: state.searchQuery,
        dateRange: SalesReturnFormat.dateRange(state.fromDate, state.toDate),
      );
      if (!ref.mounted || requestId != _requestSeq) return true;

      final merged = reset
          ? result.resultData
          : [...state.items, ...result.resultData];
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        isLoadMoreFailed: false,
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
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.salesReturn,
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
  /// Deletes one return, then removes it from the loaded list locally so
  /// the server offset stays in step with [SalesReturnState.items].length.
  /// Returns false on failure ([SalesReturnState.errorMessage] is set) or
  /// when another delete is already running.
  Future<bool> deleteSalesReturn(String returnBillNo) async {
    if (state.isDeleting) return false;
    state = state.copyWith(deletingBillNo: returnBillNo);
    try {
      await _repository.deleteSalesReturn(returnBillNo);
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