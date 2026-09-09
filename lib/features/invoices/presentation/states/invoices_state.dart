import 'package:flutter/foundation.dart';
import '../../data/model/invoice_model.dart';

@immutable
class InvoicesState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedStatus; // 'all' | one of InvoiceStatus.name
  final List<InvoiceItem> allInvoices;

  const InvoicesState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatus = 'all',
    this.allInvoices = const [],
  });

  factory InvoicesState.initial() => const InvoicesState();

  List<InvoiceItem> get filteredInvoices {
    return allInvoices.where((invoice) {
      final matchesStatus = selectedStatus == 'all' || invoice.status.name == selectedStatus;
      final matchesQuery = searchQuery.isEmpty ||
          invoice.invoiceNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          invoice.customerName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesQuery;
    }).toList();
  }

  /// Sum of every filtered invoice's outstanding balance — shown as a
  /// quick "Total Due" summary above the list.
  double get totalDue => filteredInvoices.fold(0.0, (sum, invoice) => sum + invoice.amountDue);

  InvoicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedStatus,
    List<InvoiceItem>? allInvoices,
  }) {
    return InvoicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      allInvoices: allInvoices ?? this.allInvoices,
    );
  }
}