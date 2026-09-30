import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Best-effort icon for a payment system, inferred from its short name
/// / full name — the API doesn't provide an icon, so this keeps the UI
/// from looking generic for the common payment rails.
IconData paymentSystemIcon(String shortName, [String? fullName]) {
  final key = '$shortName ${fullName ?? ''}'.toUpperCase();

  if (key.contains('CASH')) return Icons.payments_outlined;
  if (key.contains('BKASH') || key.contains('NAGAD') || key.contains('ROCKET') || key.contains('MOBILE')) {
    return Icons.phone_iphone_outlined;
  }
  if (key.contains('CARD') || key.contains('VISA') || key.contains('MASTER')) {
    return Icons.credit_card_outlined;
  }
  if (key.contains('BANK')) return Icons.account_balance_outlined;
  return Icons.account_balance_wallet_outlined;
}


Color paymentSystemColor(String shortName, [String? fullName]) {
  final key = '$shortName ${fullName ?? ''}'.toUpperCase();

  if (key.contains('CAS')) return AppColors.success;
  if (key.contains('BKASH')) return const Color(0xFFE2136E);
  if (key.contains('NAGAD')) return const Color(0xFFF6921E);
  if (key.contains('ROCKET')) return const Color(0xFF8C3494);
  if (key.contains('CARD') || key.contains('VISA') || key.contains('MASTER')) {
    return AppColors.info;
  }
  if (key.contains('BANK')) return AppColors.primary;
  return AppColors.accent;
}