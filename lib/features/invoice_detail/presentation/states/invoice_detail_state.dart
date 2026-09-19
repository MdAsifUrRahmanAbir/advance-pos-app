import 'package:flutter/foundation.dart';
import '../../data/models/invoice_detail_model.dart';

@immutable
class InvoiceDetailState {
  final bool isLoading;
  final String? errorMessage;
  /// Dev-facing breakdown for the full "Technical Details" screen —
  /// built by `buildTechnicalErrorDetails()` alongside [errorMessage].
  /// Null until an error actually occurs.
  final String? technicalDetails;
  final String? loadedInvoiceId;
  final InvoiceDetailModel? invoiceDetailModel;

  const InvoiceDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.technicalDetails,
    this.loadedInvoiceId,
    this.invoiceDetailModel,
  });

  /// Shorthand for the frequently-used nested payload.
  ResultData? get invoice => invoiceDetailModel?.resultData;

  InvoiceDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? technicalDetails,
    String? loadedInvoiceId,
    InvoiceDetailModel? invoiceDetailModel,
  }) {
    return InvoiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      loadedInvoiceId: loadedInvoiceId ?? this.loadedInvoiceId,
      invoiceDetailModel: invoiceDetailModel ?? this.invoiceDetailModel,
    );
  }
}