import '../../../invoice_detail/data/models/invoice_detail_model.dart'
    show InvoiceDetailModel;
import '../../data/models/sales_replacement_detail_model.dart'
    show SalesReplacementDetailModel;

/// Two independent loads: the replacement detail, and — once its original
/// bill number is known — the original invoice (Sales Information). A
/// failed invoice never hides the replacement, so the flags and errors
/// are kept apart.
class SalesReplacementDetailState {
  final bool isLoading;
  final String? errorMessage;

  /// Dev-facing breakdown for the full "Technical Details" screen.
  final String? technicalDetails;
  final SalesReplacementDetailModel? detail;

  final bool isInvoiceLoading;
  final String? invoiceErrorMessage;
  final InvoiceDetailModel? invoice;

  const SalesReplacementDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.technicalDetails,
    this.detail,
    this.isInvoiceLoading = false,
    this.invoiceErrorMessage,
    this.invoice,
  });

  SalesReplacementDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? technicalDetails,
    SalesReplacementDetailModel? detail,
    bool clearError = false,
    bool? isInvoiceLoading,
    String? invoiceErrorMessage,
    InvoiceDetailModel? invoice,
    bool clearInvoiceError = false,
  }) {
    return SalesReplacementDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      technicalDetails:
      clearError ? null : (technicalDetails ?? this.technicalDetails),
      detail: detail ?? this.detail,
      isInvoiceLoading: isInvoiceLoading ?? this.isInvoiceLoading,
      invoiceErrorMessage: clearInvoiceError
          ? null
          : (invoiceErrorMessage ?? this.invoiceErrorMessage),
      invoice: invoice ?? this.invoice,
    );
  }
}