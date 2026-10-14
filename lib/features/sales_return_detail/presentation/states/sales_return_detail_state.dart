import '../../data/models/sales_return_detail_model.dart';

/// Single-operation flow (load one detail), so a simple state is enough.
class SalesReturnDetailState {
  final bool isLoading;
  final String? errorMessage;

  /// Dev-facing breakdown for the full "Technical Details" screen.
  final String? technicalDetails;
  final SalesReturnDetailModel? detail;

  const SalesReturnDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.technicalDetails,
    this.detail,
  });

  SalesReturnDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? technicalDetails,
    SalesReturnDetailModel? detail,
  }) {
    return SalesReturnDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      detail: detail ?? this.detail,
    );
  }
}