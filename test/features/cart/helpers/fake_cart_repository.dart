import 'package:advance_pos_app/features/cart/data/models/add_customer_model.dart';
import 'package:advance_pos_app/features/cart/data/models/customers_model.dart';
import 'package:advance_pos_app/features/cart/data/models/get_discount.dart';
import 'package:advance_pos_app/features/cart/data/repositories/cart_repository.dart';

import 'cart_fixtures.dart';

/// One recorded GET /get_discount request.
class DiscountCall {
  const DiscountCall({
    required this.customerId,
    required this.amounts,
    required this.productIds,
    required this.quantities,
    required this.discountType,
    this.salesDate,
  });

  final String? customerId;
  final List<double> amounts;
  final List<String> productIds;
  final List<int> quantities;
  final String? discountType;

  /// Edit Sale evaluates rules as of the original sale day.
  final DateTime? salesDate;
}

/// In-memory Cart backend. [discount] decides each /get_discount answer;
/// the `next*Error` fields fail the next matching call only.
class FakeCartRepository implements CartRepository {
  FakeCartRepository({
    List<ResultDatum>? customers,
    GetDiscountModel Function(DiscountCall call)? discount,
  })  : customers = customers ?? sampleCustomers(),
        discount = discount ?? ((_) => noDiscount());

  final List<ResultDatum> customers;
  GetDiscountModel Function(DiscountCall call) discount;

  final List<DiscountCall> discountCalls = [];
  final List<String> customerSearches = [];
  final List<Map<String, String>> created = [];

  Object? nextDiscountError;
  Object? nextCustomersError;
  Object? nextCreateError;

  Object? _take(Object? Function() read, void Function() clear) {
    final error = read();
    if (error != null) clear();
    return error;
  }

  @override
  Future<CustomersModel> getCustomers({
    required int start,
    required int length,
    String search = '',
  }) async {
    customerSearches.add(search);
    await Future<void>.delayed(Duration.zero);
    final error =
    _take(() => nextCustomersError, () => nextCustomersError = null);
    if (error != null) throw error;

    final q = search.toLowerCase();
    final matched = customers
        .where((c) =>
    q.isEmpty ||
        c.customerName.toLowerCase().contains(q) ||
        c.customerMobile.contains(q))
        .toList();
    final page = matched.skip(start).take(length).toList();
    return CustomersModel(
      status: 'success',
      message: '',
      draw: 1,
      recordsTotal: matched.length,
      recordsFiltered: matched.length,
      recordsShowing: page.length,
      resultData: page,
    );
  }

  @override
  Future<AddCustomerModel> createCustomer({
    required String customerName,
    required String customerMobile,
    String customerEmail = '',
    String address = '',
    String customerType = '1',
  }) async {
    await Future<void>.delayed(Duration.zero);
    final error = _take(() => nextCreateError, () => nextCreateError = null);
    if (error != null) throw error;

    created.add({
      'name': customerName,
      'mobile': customerMobile,
      'email': customerEmail,
      'address': address,
    });
    final sl = customers.length + 1;
    customers.add(customer(sl, customerName, customerMobile));
    return AddCustomerModel(
      message: 'Customer added',
      alertType: 'success',
      id: '$sl',
      customerName: customerName,
      branchId: 1,
      syncNeeded: false,
    );
  }

  @override
  Future<GetDiscountModel> getGetDiscount({
    String? customerId,
    required List<double> amounts,
    required List<String> productIds,
    required List<int> quantities,
    String? discountType,
    DateTime? salesDate,
  }) async {
    final call = DiscountCall(
      customerId: customerId,
      amounts: amounts,
      productIds: productIds,
      quantities: quantities,
      discountType: discountType,
      salesDate: salesDate,
    );
    discountCalls.add(call);
    await Future<void>.delayed(Duration.zero);
    final error =
    _take(() => nextDiscountError, () => nextDiscountError = null);
    if (error != null) throw error;
    return discount(call);
  }
}