import 'package:flutter/foundation.dart';
import '../../data/models/customers_model.dart';

@immutable
class CustomerPickerState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final List<ResultDatum> items;
  final int currentStart;
  final bool hasMore;

  const CustomerPickerState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.items = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory CustomerPickerState.initial() => const CustomerPickerState();

  CustomerPickerState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchQuery,
    List<ResultDatum>? items,
    int? currentStart,
    bool? hasMore,
  }) {
    return CustomerPickerState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}