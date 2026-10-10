class ApiEndpoints {
  // static const String baseUrl = "https://test.advanceposbd.com/api";
  static const String baseUrl =
      "http://192.168.68.76/ttl-products/erp/testing_api/public/api";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Dashboard
  static const String dashboard = "/dashboard";


  // Master data — fetched once per day, shared across all product features.
  static const String groups = "/group/all";
  static String categories({int topSaleCategoryLimit = 10, int branchId = 2}) =>
      "/category?top_sale_category_limit=$topSaleCategoryLimit&branch_id=$branchId";
  static const String subcategories = "/subcategory/all";
  static const String brands = "/model/all";

  // Products /product/view/
  static String products ({int branchId = 2}) =>"/product?branch_id=$branchId";
  static String productDetails(String id) => "/products/$id";

  // Stock /stock/view/
  static String stocks ({int branchId = 2}) => "/product_stock?branch_id=$branchId";
  static String stocksDetails(String id) => "/product_stock/view/$id";

  // Invoices /sales/view/
  static const String invoices = "/sales?sales_type=1";
  static String invoiceDetails(String id) => "/sales/view/$id?sales_type=1";
  static const String salesAdd = "/sales/add";
  static String salesDelete(String billNo) => "/sales/delete/$billNo?sales_type=1";

  // Invoices /sales/view/
  static String customers(String length) => "/customer?length=$length";
  static const String customerAdd = "/customer/add";

  // Get Discount
  static const String getDiscount = "/get_discount";

  // Payment Systems and Accounts
  static const String paymentSystem = "/gnl/payment_system/all";
  static const String paymentAccount = "/gnl/payment_account/all";
}
