import '../session/api_params.dart';

class ApiEndpoints {
  static ApiParams get _params => ApiParams.current;

  // static const String baseUrl = "https://test.advanceposbd.com/api";

  static const String baseUrl =
      "http://192.168.68.76/ttl-products/erp/testing_api/public/api";

  static const String clientInfo =
      "http://192.168.68.76/ttl-products/ttl_admin_web/public/api/v1/client/info";

  /// Appended to the verified client's `base_url` to reach its API.
  static const String apiPathSuffix = "api";

  // Auth
  static const String login = "/login";

  // Dashboard
  static const String dashboard = "/dashboard";


  // Master data — fetched once per day, shared across all product features.
  static const String groups = "/group/all";
  static String categories({int topSaleCategoryLimit = 10}) =>
      "/category?top_sale_category_limit=$topSaleCategoryLimit&branch_id=${_params.branchId}";
  static const String subcategories = "/subcategory/all";
  static const String brands = "/model/all";
  static const String accountHead = "/daily_expense/getData?context=loadAccountHeads";

  // Payment Systems and Accounts
  static const String paymentSystem = "/gnl/payment_system/all";
  static const String paymentAccount = "/gnl/payment_account/all";

  // Stock
  /// Path only, for error details where the branch may be unknown.
  static const String stocksPath = "/product_stock";
  static String get stocks => "$stocksPath?branch_id=${_params.branchId}";
  static String stocksDetails(String id) => "/product_stock/view/$id";

  // Sales
  static String get sales => "/sales?sales_type=${_params.salesType}";
  static String salesDetails(String id) => "/sales/view/$id?sales_type=${_params.salesType}";
  static const String salesAdd = "/sales/add";
  static String salesDelete(String billNo) => "/sales/delete/$billNo?sales_type=${_params.salesType}";
  static String salesEdit(String billNo) => "/sales/edit/$billNo";
  static String salesBillPreview(String billNo) => "/sales/invoice/$billNo?sales_type=${_params.salesType}";

  // Get Discount
  static const String getDiscount = "/get_discount";

  // Customers
  static String customers(String length) => "/customer?length=$length";
  static const String customerAdd = "/customer/add";

  // Expense
  static String get expense => "/daily_expense?branch_id=${_params.branchId}";
  static String expenseDetails(String expenseNo) => "/daily_expense/view/$expenseNo";

  static const String expenseAdd = "/daily_expense/add";
  static String expenseEdit(String expenseNo) => "/daily_expense/edit/$expenseNo";
  static String expenseDelete(String expenseNo) => "/daily_expense/delete/$expenseNo";


  // Sales return
  // List filters by the camelCase `branchId` key (backend contract).
  static String get salesReturn => "/sales_return?branchId=${_params.branchId}";
  static String salesReturnDelete(String returnBillNo) => "/sales_return/delete/$returnBillNo";
  static String salesReturnDetails(String returnBillNo) => "/sales_return/view/$returnBillNo";


  // Sales replacement
  static String get salesReplacement => "/s_return?branchId=${_params.branchId}";
  static String salesReplacementDetails(String returnBillNo) => "/s_return/view/$returnBillNo";
  static String salesReplacementDelete(String returnBillNo) => "/s_return/delete/$returnBillNo";
  static String get salesReplacementBills => "/s_return/getData?branch_id=${_params.branchId}";
  static const String salesReplacementAdd = "/s_return/add";
  static String salesReplacementBillPreview(String returnBillNo) => "/s_return/invoice/$returnBillNo";

}