import 'package:flutter/foundation.dart';
import '../../data/model/invoices_model.dart';

@immutable
class InvoicesState {
  final bool isInvoicesLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final InvoicesModel? invoicesModel;
  final List<ResultDatum> allItems;
  final int currentStart;
  final bool hasMore;

  const InvoicesState({
    this.isInvoicesLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.invoicesModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory InvoicesState.initial() => const InvoicesState();

  InvoicesState copyWith({
    bool? isInvoicesLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchQuery,
    InvoicesModel? invoicesModel,
    List<ResultDatum>? allItems,
    int? currentStart,
    bool? hasMore,
  }) {
    return InvoicesState(
      isInvoicesLoading: isInvoicesLoading ?? this.isInvoicesLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      invoicesModel: invoicesModel ?? this.invoicesModel,
      allItems: allItems ?? this.allItems,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}