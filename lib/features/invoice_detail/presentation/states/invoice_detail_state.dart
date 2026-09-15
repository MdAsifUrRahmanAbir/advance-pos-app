import 'package:flutter/foundation.dart';
import '../../data/models/invoice_detail_model.dart';

@immutable
class InvoiceDetailState {
  final bool isLoading;
  final String? errorMessage;
  final String? loadedInvoiceId;
  final InvoiceDetailModel? invoiceDetailModel;

  const InvoiceDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.loadedInvoiceId,
    this.invoiceDetailModel,
  });

  /// Shorthand for the frequently-used nested payload.
  ResultData? get invoice => invoiceDetailModel?.resultData;

  InvoiceDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? loadedInvoiceId,
    InvoiceDetailModel? invoiceDetailModel,
  }) {
    return InvoiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      loadedInvoiceId: loadedInvoiceId ?? this.loadedInvoiceId,
      invoiceDetailModel: invoiceDetailModel ?? this.invoiceDetailModel,
    );
  }
}
