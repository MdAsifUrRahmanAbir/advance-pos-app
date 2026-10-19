import '../../data/models/sales_replacement_detail_model.dart';

/// Single-operation flow (load one detail), so a simple state is enough.
class SalesReplacementDetailState {
  final bool isLoading;
  final String? errorMessage;

  /// Dev-facing breakdown for the full "Technical Details" screen.
  final String? technicalDetails;
  final SalesReplacmentDetailModel? detail;

  const SalesReplacementDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.technicalDetails,
    this.detail,
  });

  SalesReplacementDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? technicalDetails,
    SalesReplacmentDetailModel? detail,
  }) {
    return SalesReplacementDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      detail: detail ?? this.detail,
    );
  }
}