const editBillNo = 'SL0001';

Map<String, dynamic> saleDetailJson({
  required int productId,
  required String barcode,
  required String name,
  required int qty,
  required double unitPrice,
}) =>
    {
      'product_id': productId,
      'product_barcode': barcode,
      'product_name': name,
      'quantity': '$qty',
      'unit_price': unitPrice.toStringAsFixed(2),
      'total_price': unitPrice * qty,
      'dis_rate': '0',
      'dis_amount': '0',
      'ta_after_discount': unitPrice * qty,
    };

/// Rice ×2 @450 and Soap split over two rows (1 + 1) — the cart must
/// merge them into one Soap ×2 line. Subtotal 990.00.
List<Map<String, dynamic>> sampleSaleDetails() => [
  saleDetailJson(
      productId: 1, barcode: '8901', name: 'Rice 5kg', qty: 2, unitPrice: 450),
  saleDetailJson(
      productId: 2, barcode: '8902', name: 'Soap', qty: 1, unitPrice: 45),
  saleDetailJson(
      productId: 2, barcode: '8902', name: 'Soap', qty: 1, unitPrice: 45),
];

/// GET /sales/view/:billNo. Defaults: customer Rahim (C-1, matches the
/// cart fixtures), VAT 5 %, no discount, sold on 17-10-2026.
Map<String, dynamic> invoiceJson({
  String billNo = editBillNo,
  String salesDate = '17-10-2026',
  String customerName = 'Rahim',
  String? customerMobile = '01711111111',
  String customerNo = 'C-1',
  String discountRate = '0',
  String vatRate = '5',
  List<Map<String, dynamic>>? details,
}) =>
    {
      'status': 'success',
      'message': '',
      'resultData': {
        'sale': {
          'sales_date': salesDate,
          'sales_bill_no': billNo,
          'total_quantity': '4',
          'total_amount': '990.00',
          'discount_rate': discountRate,
          'discount_amount': '0',
          'ta_after_discount': '990.00',
          'vat_rate': vatRate,
          'vat_amount': '49.50',
          'delivery_charge': '0',
          'total_payable_amount': '1039.50',
          'paid_amount': '1039.50',
        },
        'payment': {
          'payment_systems': [
            {'id': '1', 'name': 'Cash'},
          ],
          'payment_accounts': [],
          'collection': [
            {
              'payment_system_id': 1,
              'payment_system_name': 'Cash',
              'amount': 1039.5,
            },
          ],
        },
        'reference_no': '',
        'remarks': '',
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'customer_no': customerNo,
        'sales_by': 'Admin',
        'saleDetails': details ?? sampleSaleDetails(),
      },
    };