/// A full GET /sales/invoice/:billNo response for the receipt.
Map<String, dynamic> billJson({
  String billNo = 'SB-0001',
  bool duplicate = false,
}) =>
    {
      'status': 'success',
      'message': '',
      'print_type': null,
      'company': {
        'name': 'Advance Mart',
        'logo_url': '', // no network image in tests
        'logo_view_bill': 0,
        'logo_width_pos': '',
        'name_view_bill': 1,
        'br_add_view_bill': 1,
      },
      'branch': {
        'branch_name': 'Dhanmondi',
        'branch_code': 'DH',
        'branch_addr': 'Road 27, Dhaka',
        'branch_phone': '01700000000',
      },
      'counter': {'counter_name': 'Counter 1'},
      'invoice': {
        'sales_bill_no': billNo,
        'vat_chalan_no': null,
        'date': '08-11-2026 10:30',
        'is_duplicate': duplicate,
      },
      'productRowData': [
        {
          'product_id': 1,
          'product_name': 'Rice 5kg',
          'prod_barcode': '8901',
          'unit_price': '450.00',
          'quantity': '2',
          'total_sales_price': '900.00',
        },
        {
          'product_id': 2,
          'product_name': 'Soap',
          'prod_barcode': '8902',
          'unit_price': '45.00',
          'quantity': '2',
          'total_sales_price': '90.00',
        },
      ],
      'summary': {
        'total_amount': '990.00',
        'total_quantity': '4',
        'discount_rate': '0',
        'discount_amount': '0',
        'show_discount_pct': false,
        'adjust_point': '0',
        'vat_rate': '0',
        'vat_amount': '0',
        'delivery_charge': '0',
        'processing_fee': '0',
        'grand_total': 990,
        'grand_total_words': 'Nine Hundred Ninety Taka Only',
        'given_amount': '1000.00',
        'changed_amount': 10,
        'due_amount': 0,
        'sales_type': '1',
      },
      'payments': [
        {
          'payment_acc_id': 1,
          'payment_name': 'Cash',
          'collection_amount': '990.00',
        },
      ],
      'customer': {
        'customer_name': 'Rahim',
        'customer_mobile': '01711111111',
        'customer_no': 'C-1',
        'reward_points': 0,
      },
      'employee': {'emp_name': 'Admin', 'emp_code': 'E-1'},
      'config': {'return_day_time': '', 'terms_and_conditions': null},
    };