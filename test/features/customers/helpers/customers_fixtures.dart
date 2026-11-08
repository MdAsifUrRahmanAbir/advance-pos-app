String fillerCustomerName(int i) => 'Customer ${i.toString().padLeft(2, '0')}';

/// One /customer row as the API returns it.
Map<String, dynamic> customerJson({
  required int sl,
  required String name,
  required String mobile,
  int type = 1,
  String? email,
  String? remarks,
  Object? isPurchase,
  String branch = 'Dhanmondi',
}) =>
    {
      'sl': sl,
      'customer_no': 'C-$sl',
      'customer_name': name,
      'customer_type': type,
      'is_purchase': isPurchase,
      'customer_mobile': mobile,
      'customer_email': email, // null -> '' in the model
      'par_remarks': remarks, // null -> '' in the model
      'branch_name': branch,
    };

/// Rahim (full profile), Karim (no email/address, no purchases), Salma,
/// then fillers up to [count] — 25 by default, so there is a page 2.
List<Map<String, dynamic>> sampleCustomers({int count = 25}) => [
  customerJson(
    sl: 1,
    name: 'Rahim',
    mobile: '01711111111',
    type: 1,
    email: 'rahim@example.com',
    remarks: 'Road 27, Dhanmondi',
    isPurchase: 1,
  ),
  customerJson(sl: 2, name: 'Karim', mobile: '01722222222', type: 2),
  customerJson(sl: 3, name: 'Salma', mobile: '01733333333', type: 3),
  for (var i = 4; i <= count; i++)
    customerJson(
      sl: i,
      name: fillerCustomerName(i),
      mobile: '0180000${i.toString().padLeft(4, '0')}',
    ),
];