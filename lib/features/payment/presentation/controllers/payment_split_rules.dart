import 'dart:math' as math;

import '../states/payment_state.dart';

/// Amount rules for up to two selected payment methods. Shared by
/// Payment and Edit Sale Payment so both screens behave the same.
///
/// Cash + a non-cash method (Bank, Mobile Bank, Card…):
/// - Both start at 0 — cash is never pre-filled.
/// - Editing cash fills the non-cash side with `payable − cash`, but only
///   until the user types into the non-cash side themselves.
/// - Editing the non-cash side never touches cash.
/// - Anything collected above the payable is change, returned from cash
///   only (non-cash is capped at the payable, so change ≤ cash).
///
/// Two non-cash methods: start 50/50, editing one fills the other.
/// One method: the full payable.
abstract final class PaymentSplitRules {
  static double _round2(double v) => (v * 100).round() / 100;

  /// Amounts after a method was added or removed.
  static List<SelectedPaymentEntry> onSelectionChanged(
      List<SelectedPaymentEntry> entries,
      double payable,
      ) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) {
      return [entries.first.copyWith(amount: payable, amountTouched: false)];
    }
    if (entries.any((e) => e.isCash)) {
      return [
        for (final e in entries) e.copyWith(amount: 0, amountTouched: false),
      ];
    }
    // First half rounded, second takes the rest, so they add up exactly.
    final half = _round2(payable / 2);
    return [
      entries[0].copyWith(amount: half, amountTouched: false),
      entries[1].copyWith(
        amount: _round2(payable - half),
        amountTouched: false,
      ),
    ];
  }

  /// Amounts after the user typed [amount] for [systemId].
  ///
  /// [keepTypedAmounts]: never recalculate an amount that was typed or
  /// came from somewhere meaningful (Edit Sale's previous payments), also
  /// between two non-cash methods.
  static List<SelectedPaymentEntry> onAmountEdited(
      List<SelectedPaymentEntry> entries, {
        required int systemId,
        required double amount,
        required double payable,
        bool keepTypedAmounts = false,
      }) {
    final edited = entries.where((e) => e.system.id == systemId).firstOrNull;
    if (edited == null) return entries;

    var value = amount < 0 ? 0.0 : amount;
    if (!edited.isCash) value = math.min(value, payable);
    final complement = _round2(math.max(payable - value, 0));

    return [
      for (final e in entries)
        if (e.system.id == systemId)
          e.copyWith(amount: value, amountTouched: true)
        else if (entries.length == 2 && _fillsOther(edited, e, keepTypedAmounts))
          e.copyWith(amount: complement)
        else
          e,
    ];
  }

  /// Whether editing [edited] recalculates [other].
  static bool _fillsOther(
      SelectedPaymentEntry edited,
      SelectedPaymentEntry other,
      bool keepTypedAmounts,
      ) {
    // Cash is what the customer hands over: only they decide it.
    if (other.isCash) return false;
    // Cash fills the non-cash side until it was typed by hand.
    if (edited.isCash) return !other.amountTouched;
    // Two non-cash methods add up to the payable (unless kept as typed).
    return !keepTypedAmounts || !other.amountTouched;
  }

  /// What actually goes to [entry]'s account: cash minus the change.
  static double netAmount(SelectedPaymentEntry entry, double cashReturn) =>
      entry.isCash ? entry.amount - cashReturn : entry.amount;
}