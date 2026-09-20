class ApiEndpoints {
  // static const String baseUrl = "https://test.advanceposbd.com/api";
  static const String baseUrl =
      "http://192.168.68.76/ttl-products/erp/testing_api/public/api";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Products /product/view/
  static String products ({int branchId = 2}) =>"/product?branch_id=$branchId";
  static String productDetails(String id) => "/products/$id";

  // Stock /stock/view/
  static String stocks ({int branchId = 2}) => "/product_stock?branch_id=$branchId";
  static String stocksDetails(String id) => "/product_stock/view/$id";

  // Invoices /sales/view/
  static const String invoices = "/sales?length=15";
  static String invoiceDetails(String id) => "/sales/view/$id";

  // Master data — fetched once per day, shared across all product features.
  static const String groups = "/group/all";
  static String categories({int topSaleCategoryLimit = 10, int branchId = 2}) =>
      "/category?top_sale_category_limit=$topSaleCategoryLimit&branch_id=$branchId";
  static const String subcategories = "/subcategory/all";
  static const String brands = "/model/all";
}
