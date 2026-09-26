import 'package:flutter/foundation.dart';
import '../../data/models/customers_model.dart';

@immutable
class CustomersState {
  final bool isCustomersLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final String selectedType; // 'all' | '1' | '2' | '3' ...
  final CustomersModel? customersModel;
  final List<ResultDatum> allItems;
  final int currentStart;
  final bool hasMore;

  const CustomersState({
    this.isCustomersLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedType = 'all',
    this.customersModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory CustomersState.initial() => const CustomersState();

  /// Client-side type filter over the currently-loaded page(s) — same
  /// caveat as Stock's status filter: since this only filters what's
  /// already loaded via infinite scroll, a type with few loaded matches
  /// may show few results until more pages load in.
  List<ResultDatum> get filteredItems {
    if (selectedType == 'all') return allItems;
    final typeInt = int.tryParse(selectedType);
    if (typeInt == null) return allItems;
    return allItems.where((c) => c.customerType == typeInt).toList();
  }

  CustomersState copyWith({
    bool? isCustomersLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchQuery,
    String? selectedType,
    CustomersModel? customersModel,
    List<ResultDatum>? allItems,
    int? currentStart,
    bool? hasMore,
  }) {
    return CustomersState(
      isCustomersLoading: isCustomersLoading ?? this.isCustomersLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      customersModel: customersModel ?? this.customersModel,
      allItems: allItems ?? this.allItems,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}