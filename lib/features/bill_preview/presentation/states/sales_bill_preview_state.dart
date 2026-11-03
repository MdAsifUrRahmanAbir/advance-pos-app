import 'package:flutter/foundation.dart';

import '../../data/models/sales_bill_preview_model.dart';

/// Bill Preview has independent operations (loading the bill, printing,
/// sharing), so it keeps one flag per operation.
@immutable
class SalesBillPreviewState {
  final bool isLoading;
  final bool isPrinting;
  final bool isSharing;
  final SalesBillPreviewModel? bill;

  /// When the bill was fetched — shown as the receipt's "PRINT:" stamp.
  final DateTime? printedAt;
  final String? errorMessage;

  const SalesBillPreviewState({
    this.isLoading = false,
    this.isPrinting = false,
    this.isSharing = false,
    this.bill,
    this.printedAt,
    this.errorMessage,
  });

  SalesBillPreviewState copyWith({
    bool? isLoading,
    bool? isPrinting,
    bool? isSharing,
    SalesBillPreviewModel? bill,
    DateTime? printedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SalesBillPreviewState(
      isLoading: isLoading ?? this.isLoading,
      isPrinting: isPrinting ?? this.isPrinting,
      isSharing: isSharing ?? this.isSharing,
      bill: bill ?? this.bill,
      printedAt: printedAt ?? this.printedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}