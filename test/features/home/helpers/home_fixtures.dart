import 'package:advance_pos_app/features/home/data/models/dashboard_model.dart';

/// Values chosen so no formatted number collides with another card or
/// with DashboardSkeletonData (123,456 / 12 orders).
const todayAmount = 54321.0; // "54,321"
const todayOrders = 7;
const monthAmount = 987654.0; // "987,654"
const monthOrders = 210;

Map<String, dynamic> _collection(double cash, double mobile) => {
  'amount': cash + mobile,
  'vatAmount': 500.0,
  'deliveryChargeAmount': 0.0,
  'otherChargeAmount': 0.0,
  'cashAmount': cash,
  'bankAmount': 0.0,
  'cardAmount': 0.0,
  'mobileAmount': mobile,
  'bankCardAmount': 0.0,
};

Map<String, dynamic> _balance(double receive, double expense) => {
  'balance': receive - expense,
  'totalReceive': receive,
  'totalExpense': expense,
};

Map<String, dynamic> _return(double amount, int count, int qty) =>
    {'amount': amount, 'count': count, 'quantity': qty};

/// GET /dashboard. [today] changes the Today sales amount so tests can
/// tell two responses apart.
Map<String, dynamic> dashboardJson({
  double today = todayAmount,
  int categoryCount = 7,
  int productCount = 6,
}) =>
    {
      'status': 'success',
      'message': {
        'today': {
          'sales': {
            'amount': today,
            'count': todayOrders,
            'quantity': 15,
            'discount': 250.0,
            'vat': 300.0,
          },
          'salesReturn': _return(1200, 2, 3),
          'collection': _collection(30000, 20000),
          'balance': _balance(45000, 5000),
        },
        'thisMonth': {
          'sales': {
            'amount': monthAmount,
            'count': monthOrders,
            'quantity': 450,
            'discount': 0.0,
            'vat': 0.0,
          },
          'salesReturn': _return(8800, 9, 14),
          'collection': _collection(600000, 300000),
          'balance': _balance(880000, 70000),
        },
        'charts': {
          'last7DaysSales': {
            'labels': 'Mon,Tue,Wed,Thu,Fri,Sat,Sun',
            'series': '100,200,300,400,500,900,800',
            'maxAmount': 900.0,
            'count': 30,
            'quantity': 60,
            'amount': 3200.0,
          },
          'last12MonthsSales': {
            'labels': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
            'series': '10000,20000,30000,40000,50000,60000,'
                '70000,80000,90000,100000,110000,120000',
            'maxAmount': 120000.0,
            'count': 900,
            'quantity': 2000,
            'amount': 780000.0,
          },
        },
        'topSelling': {
          'categories': [
            for (var i = 1; i <= categoryCount; i++)
              {
                'prod_cat_id': i,
                'cat_name': 'Category $i',
                'total_quantity': 100 - i,
                'total_amount': 1000.0 * (10 - i),
              },
          ],
          'categoryNames': [
            for (var i = 1; i <= categoryCount; i++) 'Category $i',
          ],
          'products': [
            for (var i = 1; i <= productCount; i++)
              {
                'id': i,
                'product_name': 'Product $i',
                'prod_barcode': 'BC-$i',
                'total_quantity': 50 - i,
                'total_amount': 500.0 * (10 - i),
              },
          ],
        },
      },
    };

DashboardModel dashboard({double today = todayAmount}) =>
    DashboardModel.fromJson(dashboardJson(today: today));