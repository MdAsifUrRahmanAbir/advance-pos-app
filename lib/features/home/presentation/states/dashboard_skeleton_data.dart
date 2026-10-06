import '../../data/models/dashboard_model.dart';

/// Placeholder dashboard used ONLY while the first load is in flight, so
/// Skeletonizer has realistic widgets (and text lengths) to turn into bones.
/// Never shown as real data.
class DashboardSkeletonData {
  const DashboardSkeletonData._();

  static final DashboardModel model = DashboardModel.fromJson(_json);

  static const Map<String, dynamic> _sales = {
    'amount': 123456,
    'count': 12,
    'quantity': 24,
    'discount': 0,
    'vat': 0,
  };

  static const Map<String, dynamic> _amountOnly = {
    'amount': 123456,
    'count': 12,
    'quantity': 24,
  };

  static const Map<String, dynamic> _collection = {
    'amount': 123456,
    'vatAmount': 0,
    'deliveryChargeAmount': 0,
    'otherChargeAmount': 0,
    'cashAmount': 60000,
    'bankAmount': 0,
    'cardAmount': 0,
    'mobileAmount': 20000,
    'bankCardAmount': 43456,
  };

  static const Map<String, dynamic> _balance = {
    'balance': 123456,
    'totalReceive': 123456,
    'totalExpense': 12345,
  };

  static const Map<String, dynamic> _chart7 = {
    'labels': 'Sun,Mon,Tue,Wed,Thu,Fri,Sat',
    'series': '100,200,150,300,250,180,220',
    'maxAmount': 300,
    'count': 12,
    'quantity': 24,
    'amount': 123456,
  };

  static const Map<String, dynamic> _chart12 = {
    'labels': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
    'series': '1,2,3,4,5,6,7,8,9,10,11,12',
    'maxAmount': 12,
    'count': 12,
    'quantity': 24,
    'amount': 123456,
  };

  static const Map<String, dynamic> _category = {
    'prod_cat_id': 1,
    'cat_name': 'Category name',
    'total_quantity': 24,
    'total_amount': 123456,
  };

  static const Map<String, dynamic> _product = {
    'id': 1,
    'product_name': 'Product name placeholder text',
    'prod_barcode': '0000000000000',
    'total_quantity': 24,
    'total_amount': 123456,
  };

  static final Map<String, dynamic> _json = {
    'status': 'success',
    'message': {
      'today': {
        'sales': _sales,
        'salesReturn': _amountOnly,
        'collection': _collection,
        'balance': _balance,
      },
      'thisMonth': {
        'sales': _amountOnly,
        'salesReturn': _amountOnly,
        'collection': _collection,
        'balance': _balance,
      },
      'charts': {'last7DaysSales': _chart7, 'last12MonthsSales': _chart12},
      'topSelling': {
        'categories': List.filled(5, _category),
        'categoryNames': <String>[],
        'products': List.filled(5, _product),
      },
    },
  };
}