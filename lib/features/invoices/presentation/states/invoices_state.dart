import 'package:flutter/foundation.dart';
import '../../data/model/invoices_model.dart';
import 'invoice_filter.dart';
import 'invoice_status.dart';

@immutable
class InvoicesState {
  final bool isInvoicesLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? technicalDetails;
  final String searchQuery;
  final String selectedStatus; // 'all' | 'paid' | 'due' | 'partial'
  final String? selectedDatePreset; // one of InvoiceDatePresets.keys, or null (custom range / none)
  final InvoiceFilter filter;
  final InvoicesModel? invoicesModel;
  final List<ResultDatum> allItems;
  final int currentStart;
  final bool hasMore;

  const InvoicesState({
    this.isInvoicesLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.technicalDetails,
    this.searchQuery = '',
    this.selectedStatus = 'all',
    this.selectedDatePreset,
    this.filter = InvoiceFilter.empty,
    this.invoicesModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory InvoicesState.initial() => const InvoicesState();

  /// Client-side status filter over the currently-loaded page(s) — same
  /// caveat as Stock: since this only filters what's already loaded via
  /// infinite scroll, a status with few loaded matches may show few
  /// results until more pages load in.
  List<ResultDatum> get filteredItems {
    if (selectedStatus == 'all') return allItems;
    return allItems.where((invoice) => invoiceStatusOf(invoice).name == selectedStatus).toList();
  }

  InvoicesState copyWith({
    bool? isInvoicesLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? technicalDetails,
    String? searchQuery,
    String? selectedStatus,
    String? selectedDatePreset,
    bool clearSelectedDatePreset = false,
    InvoiceFilter? filter,
    InvoicesModel? invoicesModel,
    List<ResultDatum>? allItems,
    int? currentStart,
    bool? hasMore,
  }) {
    return InvoicesState(
      isInvoicesLoading: isInvoicesLoading ?? this.isInvoicesLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDatePreset: clearSelectedDatePreset ? null : (selectedDatePreset ?? this.selectedDatePreset),
      filter: filter ?? this.filter,
      invoicesModel: invoicesModel ?? this.invoicesModel,
      allItems: allItems ?? this.allItems,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}