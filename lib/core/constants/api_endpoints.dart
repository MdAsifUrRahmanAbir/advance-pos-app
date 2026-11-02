class ApiEndpoints {
  // static const String baseUrl = "https://test.advanceposbd.com/api";

  static const String baseUrl =
      "http://192.168.68.76/ttl-products/erp/testing_api/public/api";

  // Company (client) verification — central admin server, NOT the client's
  // base URL, so this is an absolute URL (Dio ignores baseUrl for it).
  static const String clientInfo =
      "http://192.168.68.76/ttl-products/ttl_admin_web/public/api/v1/client/info";
  static const String clientApp = "pos";

  /// Appended to the verified client's `base_url` to reach its API.
  static const String apiPathSuffix = "public/api";


  // Dashboard
  static const String dashboard = "/dashboard"; 


  // Master data — fetched once per day, shared across all product features.
  static const String groups = "/group/all"; 
  static String categories({int topSaleCategoryLimit = 10, int branchId = 2}) =>
      "/category?top_sale_category_limit=$topSaleCategoryLimit&branch_id=$branchId"; 
  static const String subcategories = "/subcategory/all"; 
  static const String brands = "/model/all"; 
  static const String accountHead = "/daily_expense/getData?context=loadAccountHeads"; 

  // Payment Systems and Accounts
  static const String paymentSystem = "/gnl/payment_system/all"; 
  static const String paymentAccount = "/gnl/payment_account/all"; 

  // Stock
  static String stocks ({int branchId = 2}) => "/product_stock?branch_id=$branchId"; 
  static String stocksDetails(String id) => "/product_stock/view/$id"; 

  // Sales
  static const String sales = "/sales?sales_type=1"; 
  static String salesDetails(String id) => "/sales/view/$id?sales_type=1"; 
  static const String salesAdd = "/sales/add"; 
  static String salesDelete(String billNo) => "/sales/delete/$billNo?sales_type=1"; 
  static String salesEdit(String billNo) => "/sales/edit/$billNo";
  static String salesBillPreview(String billNo) => "/sales/invoice/$billNo?sales_type=1";

  // Get Discount
  static const String getDiscount = "/get_discount"; 

  // Customers
  static String customers(String length) => "/customer?length=$length"; 
  static const String customerAdd = "/customer/add"; 

  // Expense
  static const String expense = "/daily_expense"; 
  static String expenseDetails(String expenseNo) => "/daily_expense/view/$expenseNo"; 

  static const String expenseAdd = "/daily_expense/add"; 
  static String expenseEdit(String expenseNo) => "/daily_expense/edit/$expenseNo"; 
  static String expenseDelete(String expenseNo) => "/daily_expense/delete/$expenseNo"; 


  // Sales return
  static const String salesReturn = "/sales_return";
  static String salesReturnDelete(String returnBillNo) => "/sales_return/delete/$returnBillNo";
  static String salesReturnDetails(String returnBillNo) => "/sales_return/view/$returnBillNo";


  // Sales replacement
  static const String salesReplacement = "/s_return";
  static String salesReplacementDetails(String returnBillNo) => "/s_return/view/$returnBillNo";
  static String salesReplacementDelete(String returnBillNo) => "/s_return/delete/$returnBillNo";
  static const String salesReplacementBills = "/s_return/getData";
  static const String salesReplacementAdd = "/s_return/add";
  static String salesReplacementBillPreview(String returnBillNo) => "/s_return/invoice/$returnBillNo";

}
