import 'package:flutter/material.dart';

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