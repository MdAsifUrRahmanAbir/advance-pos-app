import 'package:advance_pos_app/features/invoices/data/model/invoices_model.dart';

String billNoFor(int i) => 'SB-${i.toString().padLeft(4, '0')}';

/// One sales row exactly as GET /api/sales returns it.
Map<String, dynamic> invoiceRowJson({
  int sl = 1,
  String? billNo,
  String customerName = 'Rahim Uddin',
  String totalPayable = '1000.00',
  String paid = '1000.00',
  String totalQuantity = '2',
  List<String> productNames = const ['Rice 5kg'],
  List<String> blockedActions = const [],
  String? blockedReason,
}) =>
    {
      'sl': sl,
      'sales_date': '08-11-2026',
      'sales_bill_no': billNo ?? billNoFor(sl),
      'total_quantity': totalQuantity,
      'total_amount': totalPayable,
      'discount_rate': '0',
      'discount_amount': '0',
      'ta_after_discount': totalPayable,
      'vat_rate': '0',
      'vat_amount': '0',
      'delivery_charge': '0',
      'total_payable_amount': totalPayable,
      'paid_amount': paid,
      'payment_systems': [
        {'id': '1', 'name': 'Cash'},
      ],
      'payment_accounts': [
        {'id': '1', 'name': 'Cash in hand'},
      ],
      'product_names': productNames,
      'reference_no': '',
      'remarks': '',
      'customer_name': customerName,
      'customer_mobile': '',
      'sales_by': 'Admin',
      'blocked_actions': blockedActions,
      'blocked_reason': blockedReason,
    };

/// [count] rows numbered from [from]; [overrides] patches row i (1-based).
List<Map<String, dynamic>> rowsJson(
    int count, {
      int from = 1,
      Map<int, Map<String, dynamic>> overrides = const {},
    }) =>
    [
      for (var i = from; i < from + count; i++)
        {...invoiceRowJson(sl: i), ...?overrides[i]},
    ];

Map<String, dynamic> invoicesPageJson(
    List<Map<String, dynamic>> rows, {
      int? recordsFiltered,
    }) =>
    {
      'status': 'success',
      'message': '',
      'draw': 1,
      'recordsTotal': recordsFiltered ?? rows.length,
      'recordsFiltered': recordsFiltered ?? rows.length,
      'recordsShowing': rows.length,
      'resultData': rows,
    };

InvoicesModel invoicesPage(
    List<Map<String, dynamic>> rows, {
      int? recordsFiltered,
    }) =>
    InvoicesModel.fromJson(
      invoicesPageJson(rows, recordsFiltered: recordsFiltered),
    );

ResultDatum invoiceRow({
  List<String> blockedActions = const [],
  String? blockedReason,
  String customerName = 'Rahim Uddin',
  String totalPayable = '1000.00',
  String paid = '1000.00',
}) =>
    ResultDatum.fromJson(
      invoiceRowJson(
        blockedActions: blockedActions,
        blockedReason: blockedReason,
        customerName: customerName,
        totalPayable: totalPayable,
        paid: paid,
      ),
    );