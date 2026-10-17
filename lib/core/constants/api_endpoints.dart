class ApiEndpoints {
  // static const String baseUrl = "https://test.advanceposbd.com/api";
  static const String baseUrl =
      "http://192.168.68.76/ttl-products/erp/testing_api/public/api";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Dashboard
  static const String dashboard = "/dashboard"; /// DONE


  // Master data — fetched once per day, shared across all product features.
  static const String groups = "/group/all"; /// DONE
  static String categories({int topSaleCategoryLimit = 10, int branchId = 2}) =>
      "/category?top_sale_category_limit=$topSaleCategoryLimit&branch_id=$branchId"; /// DONE
  static const String subcategories = "/subcategory/all"; /// DONE
  static const String brands = "/model/all"; /// DONE


  // Get Discount
  static const String getDiscount = "/get_discount"; /// DONE

  // Account Head
  static const String accountHead = "/daily_expense/getData?context=loadAccountHeads"; /// DONE

  // Payment Systems and Accounts
  static const String paymentSystem = "/gnl/payment_system/all"; /// DONE
  static const String paymentAccount = "/gnl/payment_account/all"; /// DONE
  ///
  // Products /product/view/
  static String products ({int branchId = 2}) =>"/product?branch_id=$branchId";
  static String productDetails(String id) => "/products/$id";

  // Stock /stock/view/
  static String stocks ({int branchId = 2}) => "/product_stock?branch_id=$branchId"; /// DONE
  static String stocksDetails(String id) => "/product_stock/view/$id"; /// DONE

  // Invoices /sales/view/
  static const String invoices = "/sales?sales_type=1"; /// DONE
  static String invoiceDetails(String id) => "/sales/view/$id?sales_type=1"; /// DONE
  static const String salesAdd = "/sales/add"; /// DONE
  static String salesDelete(String billNo) => "/sales/delete/$billNo?sales_type=1"; /// DONE
  static String salesEdit(String billNo) => "/sales/edit/${Uri.encodeComponent(billNo)}";

  // Invoices /sales/view/
  static String customers(String length) => "/customer?length=$length"; /// DONE
  static const String customerAdd = "/customer/add"; /// DONE

  // Expense
  static const String expense = "/daily_expense"; /// DONE
  static String expenseDetails(String expenseNo) => "/daily_expense/view/$expenseNo"; /// DONE

  static const String expenseAdd = "/daily_expense/add"; /// DONE
  static String expenseEdit(String expenseNo) => "/daily_expense/edit/$expenseNo"; /// DONE
  static String expenseDelete(String expenseNo) => "/daily_expense/delete/$expenseNo"; /// DONE


  // Expense
  static const String salesReturn = "/sales_return";
  static String salesReturnDelete(String returnBillNo) => "/sales_return/delete/$returnBillNo";
  static String salesReturnDetails(String returnBillNo) => "/sales_return/view/$returnBillNo";
  // static String expenseDetails(String expenseNo) => "/daily_expense/view/$expenseNo"; /// DONE

  // static const String expenseAdd = "/daily_expense/add"; /// DONE
  // static String expenseEdit(String expenseNo) => "/daily_expense/edit/$expenseNo"; /// DONE
  // static String expenseDelete(String expenseNo) => "/daily_expense/delete/$expenseNo"; /// DONE



}
