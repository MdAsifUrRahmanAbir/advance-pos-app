import '../../data/model/sales_bill_preview_model.dart';

/// Fake bill used only as Skeletonizer bones during the first load, so the
/// skeleton has the real receipt's shape. Never shown as data.
class SalesBillPreviewPlaceholder {
  SalesBillPreviewPlaceholder._();

  static final SalesBillPreviewModel bill = SalesBillPreviewModel.fromJson({
    'status': '',
    'message': '',
    'print_type': null,
    'company': {
      'name': '',
      'logo_url': '',
      'logo_view_bill': 0,
      'logo_width_pos': '',
      'name_view_bill': 0,
      'br_add_view_bill': 1,
    },
    'branch': {
      'branch_name': 'Branch name here',
      'branch_code': '000000000-0000',
      'branch_addr': 'Branch address line goes here, City - 0000',
      'branch_phone': '00000000000',
    },
    'counter': {'counter_name': null},
    'invoice': {
      'sales_bill_no': 'SL00000000000',
      'vat_chalan_no': null,
      'date': '00/00/00 00:00 AM',
      'is_duplicate': false,
    },
    'productRowData': List.generate(
      3,
          (i) => {
        'product_id': i,
        'product_name': 'Product name here',
        'prod_barcode': '0000000000000',
        'unit_price': '0000.00',
        'quantity': '1',
        'total_sales_price': '0000.00',
      },
    ),
    'summary': {
      'total_amount': '0000.00',
      'total_quantity': '0',
      'discount_rate': '0',
      'discount_amount': '000.00',
      'show_discount_pct': false,
      'adjust_point': '0.00',
      'vat_rate': '',
      'vat_amount': '00.00',
      'delivery_charge': '0',
      'processing_fee': '0',
      'grand_total': 0,
      'grand_total_words': 'Amount in words goes here',
      'given_amount': '0000.00',
      'changed_amount': 0.0,
      'due_amount': null,
      'sales_type': '',
    },
    'payments': [
      {'payment_acc_id': 0, 'payment_name': 'Cash', 'collection_amount': '0'},
    ],
    'customer': {
      'customer_name': 'Customer',
      'customer_mobile': '00000000000',
      'customer_no': '',
      'reward_points': 0,
    },
    'employee': {'emp_name': 'Employee', 'emp_code': '00'},
    'config': {'return_day_time': '', 'terms_and_conditions': null},
  });
}