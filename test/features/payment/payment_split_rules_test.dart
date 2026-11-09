import 'package:flutter_test/flutter_test.dart';

import 'package:advance_pos_app/features/master_data/data/models/payment_accounts_model.dart'
as pa;
import 'package:advance_pos_app/features/payment/presentation/controllers/payment_split_rules.dart';
import 'package:advance_pos_app/features/payment/presentation/states/payment_state.dart';

pa.PaymentSystem _system(int id, String name, String short) => pa.PaymentSystem(
  id: id,
  paymentSystemName: name,
  shortName: short,
  status: 'active',
  isActive: 1,
);

final cash = SelectedPaymentEntry(system: _system(1, 'Cash', 'CAS'));
final bank = SelectedPaymentEntry(system: _system(2, 'Bank', 'BNK'));
final bkash = SelectedPaymentEntry(system: _system(3, 'bKash', 'MFS'));

const payable = 1575.0;

List<double> amounts(List<SelectedPaymentEntry> e) =>
    e.map((x) => x.amount).toList();

List<SelectedPaymentEntry> edit(
    List<SelectedPaymentEntry> entries,
    SelectedPaymentEntry which,
    double amount,
    ) =>
    PaymentSplitRules.onAmountEdited(
      entries,
      systemId: which.system.id,
      amount: amount,
      payable: payable,
    );

/// Same as PaymentState.changeDue / cashReturn.
double change(List<SelectedPaymentEntry> e) =>
    PaymentState(payableAmount: payable, selectedEntries: e).cashReturn;

void main() {
  group('onSelectionChanged', () {
    test('one method gets the full payable', () {
      expect(amounts(PaymentSplitRules.onSelectionChanged([bank], payable)),
          [payable]);
    });

    test('cash + non-cash both start at 0 (no fixed cash)', () {
      expect(
          amounts(PaymentSplitRules.onSelectionChanged([cash, bank], payable)),
          [0, 0]);
    });

    test('two non-cash: 50/50 that adds up exactly', () {
      final e = PaymentSplitRules.onSelectionChanged([bank, bkash], 1024.65);
      expect(amounts(e), [512.33, 512.32]);
    });

    test('resets the touched flag', () {
      final touched = [cash.copyWith(amountTouched: true), bank];
      final e = PaymentSplitRules.onSelectionChanged(touched, payable);
      expect(e.any((x) => x.amountTouched), isFalse);
    });
  });

  group('cash first', () {
    test('cash 1000 → bank auto 575, no change', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, cash, 1000);
      expect(amounts(e), [1000, 575]);
      expect(change(e), 0);
    });

    test('then bank typed 1000 → cash kept, change 425 from cash', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, cash, 1000);
      e = edit(e, bank, 1000);
      expect(amounts(e), [1000, 1000]);
      expect(change(e), 425);
    });

    test('cash edited again does not overwrite a typed bank amount', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, bank, 1000);
      e = edit(e, cash, 1200);
      expect(amounts(e), [1200, 1000]);
    });

    test('cash above payable → bank 0, change from cash', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, cash, 2000);
      expect(amounts(e), [2000, 0]);
      expect(change(e), 425);
    });
  });

  group('non-cash first', () {
    test('bank 1000 → cash NOT filled, still short', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, bank, 1000);
      expect(amounts(e), [0, 1000]);
      expect(
        PaymentState(payableAmount: payable, selectedEntries: e).shortfall,
        575,
      );
    });

    test('then cash 1000 → change 425', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, bank, 1000);
      e = edit(e, cash, 1000);
      expect(amounts(e), [1000, 1000]);
      expect(change(e), 425);
    });

    test('same for Mobile Bank + Cash', () {
      var e = PaymentSplitRules.onSelectionChanged([bkash, cash], payable);
      e = edit(e, bkash, 1000);
      expect(amounts(e), [1000, 0]);
      e = edit(e, cash, 1000);
      expect(change(e), 425);
    });

    test('non-cash capped at payable', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, bank, 5000);
      expect(e.last.amount, payable);
    });
  });

  group('change only from cash', () {
    test('change never exceeds the cash given', () {
      var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
      e = edit(e, bank, payable);
      e = edit(e, cash, 300);
      expect(change(e), 300);
      expect(PaymentSplitRules.netAmount(e.first, change(e)), 0);
    });

    test('two non-cash always add up to the payable (no change)', () {
      var e = PaymentSplitRules.onSelectionChanged([bank, bkash], payable);
      e = edit(e, bank, 1000);
      expect(amounts(e), [1000, 575]);
      e = edit(e, bkash, 1500);
      expect(amounts(e), [75, 1500]);
      expect(change(e), 0);
    });
  });

  test('negative input becomes 0', () {
    var e = PaymentSplitRules.onSelectionChanged([cash, bank], payable);
    e = edit(e, cash, -5);
    expect(e.first.amount, 0);
  });
}