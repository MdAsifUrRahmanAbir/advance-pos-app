class ApiEndpoints {
  static const String baseUrl = "https://test.advanceposbd.com/api";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Products
  static const String products = "/product?length=10";
  static String productDetails(String id) => "/products/$id";

}
