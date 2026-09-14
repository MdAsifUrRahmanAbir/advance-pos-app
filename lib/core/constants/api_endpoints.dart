class ApiEndpoints {
  static const String baseUrl = "https://test.advanceposbd.com/api";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Products /product/view/
  static const String products = "/product?length=10";
  static String productDetails(String id) => "/products/$id";


  // Stock /stock/view/
  static const String stocks = "/product_stock";
  static String stocksDetails(String id) => "/product_stock/view/$id";

  // Stock /stock/view/
  static const String invoices = "/sales?length=15";
  static String invoiceDetails(String id) => "/sales/view/$id";
}
