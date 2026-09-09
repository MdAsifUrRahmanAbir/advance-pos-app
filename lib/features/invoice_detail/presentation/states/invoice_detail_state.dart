import 'package:flutter/foundation.dart';
import '../../data/models/invoice_detail_model.dart';

@immutable
class InvoiceDetailState {
  final bool isLoading;
  final String? errorMessage;
  final String? loadedInvoiceId;
  final InvoiceDetailModel? invoice;

  const InvoiceDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.loadedInvoiceId,
    this.invoice,
  });

  InvoiceDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? loadedInvoiceId,
    InvoiceDetailModel? invoice,
  }) {
    return InvoiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      loadedInvoiceId: loadedInvoiceId ?? this.loadedInvoiceId,
      invoice: invoice ?? this.invoice,
    );
  }
}