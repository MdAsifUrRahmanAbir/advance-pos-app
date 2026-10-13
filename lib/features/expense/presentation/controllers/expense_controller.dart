import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/expense_repository.dart';
import '../states/expense_format.dart';
import '../states/expense_state.dart';

final expenseControllerProvider =
NotifierProvider.autoDispose<ExpenseController, ExpenseState>(
  ExpenseController.new,
);

class ExpenseController extends Notifier<ExpenseState> {
  static const int _pageSize = 20;
  static const int _branchId = 2; // TODO: take from session / branch picker
  static const double _loadMoreThreshold = 240;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  late final TextEditingController searchController;
  late final ScrollController scrollController;
  Timer? _debounce;
  int _requestSeq = 0;

  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider);

  @override
  ExpenseState build() {
    searchController = TextEditingController();
    scrollController = ScrollController()..addListener(_onScroll);
    ref.onDispose(() {
      _debounce?.cancel();
      searchController.dispose();
      scrollController.dispose();
    });
    Future.microtask(loadExpenses);
    return const ExpenseState(isInitialLoading: true);
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
      loadExpenses();
    });
  }

  void applyDatePreset(ExpenseDatePreset preset, {DateTimeRange? range}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? from;
    DateTime? to;

    switch (preset) {
      case ExpenseDatePreset.all:
        break;
      case ExpenseDatePreset.today:
        from = to = today;
      case ExpenseDatePreset.yesterday:
        from = to = today.subtract(const Duration(days: 1));
      case ExpenseDatePreset.last7Days:
        from = today.subtract(const Duration(days: 6));
        to = today;
      case ExpenseDatePreset.thisMonth:
        from = DateTime(today.year, today.month, 1);
        to = DateTime(today.year, today.month + 1, 0);
      case ExpenseDatePreset.lastMonth:
        from = DateTime(today.year, today.month - 1, 1);
        to = DateTime(today.year, today.month, 0);
      case ExpenseDatePreset.custom:
        from = range?.start;
        to = range?.end;
    }

    state = state.copyWith(
      datePreset: from == null ? ExpenseDatePreset.all : preset,
      fromDate: from,
      toDate: to,
      clearDates: from == null,
    );
    loadExpenses();
  }

  // ───────────────────────────────────────────────
  // GET (list + pagination)
  // ───────────────────────────────────────────────
  /// Full reload. [keepCurrent] keeps the visible list (pull-to-refresh);
  /// otherwise the list is cleared and the skeleton shows.
  Future<bool> loadExpenses({bool keepCurrent = false}) {
    state = keepCurrent
        ? state.copyWith(isLoadMoreFailed: false)
        : state.copyWith(
      expenses: const [],
      isInitialLoading: true,
      hasMore: false,
      totalCount: 0,
      isLoadMoreFailed: false,
    );
    return _fetch(reset: true);
  }

  Future<bool> refresh() => loadExpenses(keepCurrent: true);

  Future<bool> loadMore() {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasMore) {
      return Future.value(false);
    }
    state = state.copyWith(isLoadingMore: true, isLoadMoreFailed: false);
    return _fetch(reset: false);
  }

  Future<bool> _fetch({required bool reset}) async {
    final requestId = ++_requestSeq; // newer request wins; stale ones dropped
    try {
      final result = await _repository.getExpenses(
        start: reset ? 0 : state.expenses.length,
        length: _pageSize,
        branchId: _branchId,
        search: state.searchQuery,
        fromDate: state.fromDate == null
            ? null
            : ExpenseFormat.apiDate(state.fromDate!),
        toDate: state.toDate == null
            ? null
            : ExpenseFormat.apiDate(state.toDate!),
      );
      if (!ref.mounted || requestId != _requestSeq) return true;

      final merged = reset
          ? result.resultData
          : [...state.expenses, ...result.resultData];
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        isLoadMoreFailed: false,
        expenses: merged,
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
      );
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // DELETE
  // ───────────────────────────────────────────────
  /// Deletes one expense, then removes it from the loaded list locally so
  /// the server offset stays in step with [ExpenseState.expenses.length].
  /// Returns false on failure ([ExpenseState.errorMessage] is set) or when
  /// another delete is already running.
  Future<bool> deleteExpense(String expenseNo) async {
    if (state.isDeleting) return false;
    state = state.copyWith(deletingExpenseNo: expenseNo);
    try {
      await _repository.deleteExpense(expenseNo);
      if (!ref.mounted) return true;

      final remaining =
      state.expenses.where((e) => e.expenseNo != expenseNo).toList();
      final removed = state.expenses.length - remaining.length;
      final total = state.totalCount - removed;
      state = state.copyWith(
        clearDeleting: true,
        expenses: remaining,
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

  /// Tall screens may show the first page without any scrolling, so no
  /// scroll event would ever request page 2.
  void _fillViewportIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted || !scrollController.hasClients) return;
      if (scrollController.position.maxScrollExtent <= 0) loadMore();
    });
  }
}