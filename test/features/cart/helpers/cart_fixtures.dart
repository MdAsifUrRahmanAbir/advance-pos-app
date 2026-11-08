import 'package:advance_pos_app/features/cart/data/models/customers_model.dart'
as customers;
import 'package:advance_pos_app/features/cart/data/models/get_discount.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart'
as new_sale;

// ── Cart lines (what New Sale hands to the Cart) ──
// Rice: 2 × 450 = 900 (stock 5). Soap: 2 × 45 = 90 (stock 2, already at cap).
const rice = new_sale.ProductItem(
  id: '1',
  name: 'Rice 5kg',
  sku: 'R5',
  price: 450,
  categoryKey: 'Grocery',
  stock: 5,
);

const soap = new_sale.ProductItem(
  id: '2',
  name: 'Soap',
  sku: 'S1',
  price: 45,
  categoryKey: 'Grocery',
  stock: 2,
);

/// Subtotal 990.00.
List<new_sale.CartLineItem> sampleCart() => const [
  new_sale.CartLineItem(product: rice, quantity: 2),
  new_sale.CartLineItem(product: soap, quantity: 2),
];

// ── Customers ──
customers.ResultDatum customer(int sl, String name, String mobile) =>
    customers.ResultDatum(
      sl: sl,
      customerNo: 'C-$sl',
      customerName: name,
      customerType: 1,
      isPurchase: 0,
      customerMobile: mobile,
      customerEmail: '',
      branchName: 'Dhanmondi',
    );

List<customers.ResultDatum> sampleCustomers() => [
  customer(1, 'Rahim', '01711111111'),
  customer(2, 'Karim', '01722222222'),
  customer(3, 'Salma', '01733333333'),
];

// ── /get_discount responses ──
GetDiscountModel noDiscount() => const GetDiscountModel(
  status: 'success',
  resultData: DiscountResultData(),
);

/// Regular rule: seller types a discount, capped at [rate] %.
GetDiscountModel regularPercent(double rate) => GetDiscountModel(
  status: 'success',
  resultData: DiscountResultData(
    discountApplied: true,
    discountScope: 'regular',
    discountMethod: 'percentage',
    discountRate: rate,
  ),
);

/// Bill rule: a fixed amount off the whole bill.
GetDiscountModel billFixed(double amount, {List<String> codes = const []}) =>
    GetDiscountModel(
      status: 'success',
      resultData: DiscountResultData(
        discountApplied: true,
        discountScope: 'bill',
        discountMethod: 'fixed',
        billDiscountAmount: amount,
        discountCodes: codes,
      ),
    );

/// Product rule: per-line amounts keyed by product id.
GetDiscountModel productWise(Map<String, double> perLine) => GetDiscountModel(
  status: 'success',
  resultData: DiscountResultData(
    discountApplied: true,
    discountScope: 'product',
    discountMethod: 'fixed',
    productDiscounts: perLine,
  ),
);

/// Both rules offered — the seller picks one.
GetDiscountModel bothRules({
  required Map<String, double> perLine,
  required double bill,
}) =>
    GetDiscountModel(
      status: 'success',
      resultData: DiscountResultData(
        discountApplied: true,
        discountScope: 'both',
        discountMethod: 'fixed',
        productDiscounts: perLine,
        billDiscountAmount: bill,
      ),
    );