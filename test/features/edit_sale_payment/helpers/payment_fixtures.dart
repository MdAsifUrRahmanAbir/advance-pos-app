import 'package:advance_pos_app/features/master_data/data/models/payment_accounts_model.dart'
as pa;

const cashSystemId = 1;
const bkashSystemId = 2;
const cardSystemId = 3;

Map<String, dynamic> _system(int id, String name, String short) => {
  'id': id,
  'payment_system_name': name,
  'short_name': short,
  'status': 'active',
  'is_active': 1,
};

pa.ResultDatum account({
  required int id,
  required String provider,
  required int systemId,
  required String systemName,
  required String shortName,
  String accountNo = '',
}) =>
    pa.ResultDatum.fromJson({
      'id': id,
      'status': 'active',
      'provider_name': provider,
      'acc_holder_name': 'Advance Mart',
      'account_no': accountNo,
      'ledger_id': id,
      'payment_system_id': systemId,
      'ledger': provider,
      'payment_system': _system(systemId, systemName, shortName),
    });

/// Cash (one account, no picker), bKash (two accounts, picker), Card
/// (one account, picker).
List<pa.ResultDatum> sampleAccounts() => [
  account(
      id: 11,
      provider: 'Cash in hand',
      systemId: cashSystemId,
      systemName: 'Cash',
      shortName: 'CAS'),
  account(
      id: 21,
      provider: 'bKash Merchant',
      accountNo: '01700000001',
      systemId: bkashSystemId,
      systemName: 'bKash',
      shortName: 'BKS'),
  account(
      id: 22,
      provider: 'bKash Personal',
      accountNo: '01700000002',
      systemId: bkashSystemId,
      systemName: 'bKash',
      shortName: 'BKS'),
  account(
      id: 31,
      provider: 'City Bank',
      accountNo: '4111',
      systemId: cardSystemId,
      systemName: 'Card',
      shortName: 'CRD'),
];

/// The label PaymentAccountDropdown shows for an account.
String accountLabel(String provider, String accountNo) =>
    '$provider ($accountNo)';