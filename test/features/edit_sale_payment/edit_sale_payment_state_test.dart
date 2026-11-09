import 'package:flutter_test/flutter_test.dart';

import 'package:advance_pos_app/features/edit_sale_payment/presentation/states/edit_sale_payment_state.dart';
import 'package:advance_pos_app/features/master_data/data/models/payment_accounts_model.dart'
as pa;
import 'package:advance_pos_app/features/payment/presentation/states/payment_state.dart';

import 'helpers/payment_fixtures.dart';

pa.ResultDatum accountOf(int systemId) =>
    sampleAccounts().firstWhere((a) => a.paymentSystem.id == systemId);

SelectedPaymentEntry entryOf(int systemId, double amount) {
  final account = accountOf(systemId);
  return SelectedPaymentEntry(
    system: account.paymentSystem,
    account: account,
    amount: amount,
    amountTouched: true,
  );
}

EditSalePaymentState stateOf({
  required double payable,
  required List<PreviousPayment> previous,
  required List<SelectedPaymentEntry> entries,
  bool withCashAccount = true,
}) =>
    EditSalePaymentState(
      billNo: 'SL0001',
      payableAmount: payable,
      receiptItems: const [
        ReceiptLineItem(name: 'Rice', quantity: 1, lineTotal: 1),
      ],
      previousPayments: previous,
      cashAccount: withCashAccount ? accountOf(cashSystemId) : null,
      selectedEntries: entries,
    );

const _cashBefore = PreviousPayment(
    systemId: cashSystemId, systemName: 'Cash', amount: 500);
const _bkashBefore = PreviousPayment(
    systemId: bkashSystemId, systemName: 'bKash', amount: 1000);

void main() {
  test('more to pay: short until added', () {
    final s = stateOf(
      payable: 700,
      previous: [_cashBefore],
      entries: [entryOf(cashSystemId, 500)],
    );
    expect(s.previousTotal, 500);
    expect(s.difference, 200);
    expect(s.shortfall, 200);
    expect(s.canSubmit, isFalse);
  });

  test('less to pay with cash before: returned from cash', () {
    final s = stateOf(
      payable: 300,
      previous: [_cashBefore],
      entries: [entryOf(cashSystemId, 500)],
    );
    expect(s.difference, -200);
    expect(s.cashReturn, 200);
    expect(s.netCashAmount, 300);
    expect(s.canSubmit, isTrue);
  });

  test('bKash only before, less to pay: cash pays out (negative)', () {
    final s = stateOf(
      payable: 800,
      previous: [_bkashBefore],
      entries: [entryOf(bkashSystemId, 1000)],
    );
    expect(s.cashReturn, 200);
    expect(s.netCashAmount, -200);
    expect(s.canSubmit, isTrue);

    final cashRow =
    s.methodChanges.firstWhere((c) => c.systemId == cashSystemId);
    expect(cashRow.previous, 0);
    expect(cashRow.now, -200);
    final bkashRow =
    s.methodChanges.firstWhere((c) => c.systemId == bkashSystemId);
    expect(bkashRow.delta, 0);
  });

  test('return needed but no Cash account: blocked', () {
    final s = stateOf(
      payable: 800,
      previous: [_bkashBefore],
      entries: [entryOf(bkashSystemId, 1000)],
      withCashAccount: false,
    );
    expect(s.canReturnCash, isFalse);
    expect(s.canSubmit, isFalse);
  });

  test('method changes: previous method removed shows → 0', () {
    final s = stateOf(
      payable: 1500,
      previous: [_cashBefore, _bkashBefore],
      entries: [entryOf(bkashSystemId, 1500)],
    );
    final cash = s.methodChanges.firstWhere((c) => c.systemId == cashSystemId);
    expect(cash.previous, 500);
    expect(cash.now, 0);
    final bkash =
    s.methodChanges.firstWhere((c) => c.systemId == bkashSystemId);
    expect(bkash.delta, 500);
  });

  test('no collection lines: previous total falls back to paid', () {
    const s = EditSalePaymentState(billNo: 'X', originalPaid: 900);
    expect(s.previousTotal, 900);
  });
}