import 'package:flutter/foundation.dart';

/// Single-operation flow (verify the company code).
@immutable
class CompanyCodeState {
  final bool isVerifying;
  final String? errorMessage;

  const CompanyCodeState({this.isVerifying = false, this.errorMessage});

  CompanyCodeState copyWith({
    bool? isVerifying,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CompanyCodeState(
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}