import '../../../customers/data/models/customers_model.dart' as cust;
import '../../../invoice_detail/data/models/invoice_detail_model.dart'
    show InvoiceDetailModel;
import '../../data/models/bills_model.dart' as bill;
import 'sales_replacement_add_calc.dart';

/// Step 1 (pick the sale and what is returned). Several independent loads
/// — customers, bills, the invoice — so each has its own flags and error.
class SalesReplacementAddState {
  /// 0 = select the sale and returned products, 1 = replacement items.
  final int step;

  // Customer picker (optional)
  final List<cust.ResultDatum> customers;
  final String customerQuery;
  final bool isCustomersLoading;
  final bool isCustomersLoadingMore;
  final bool customersHasMore;
  final String? customersError;
  final cust.ResultDatum? selectedCustomer;

  // Bill picker
  final List<bill.Result> bills;
  final int billsPage;
  final bool isBillsLoading;
  final bool isBillsLoadingMore;
  final bool billsHasMore;
  final String? billsError;
  final String? selectedBillNo;

  // The original sale
  final InvoiceDetailModel? invoice;
  final bool isInvoiceLoading;
  final String? invoiceError;
  final String? technicalDetails;

  /// productId → quantity being returned (absent = not returned).
  final Map<int, int> returnQty;

  const SalesReplacementAddState({
    this.step = 0,
    this.customers = const [],
    this.customerQuery = '',
    this.isCustomersLoading = false,
    this.isCustomersLoadingMore = false,
    this.customersHasMore = true,
    this.customersError,
    this.selectedCustomer,
    this.bills = const [],
    this.billsPage = 0,
    this.isBillsLoading = false,
    this.isBillsLoadingMore = false,
    this.billsHasMore = true,
    this.billsError,
    this.selectedBillNo,
    this.invoice,
    this.isInvoiceLoading = false,
    this.invoiceError,
    this.technicalDetails,
    this.returnQty = const {},
  });

  List<SoldLine> get soldLines => SalesReplacementAddCalc.soldLines(invoice);

  List<ReturnLine> get returnLines =>
      SalesReplacementAddCalc.returnLines(soldLines, returnQty);

  int get returnItemCount => returnLines.fold(0, (s, l) => s + l.quantity);

  /// Credit for everything being returned, after each line's discount.
  double get returnTotal => SalesReplacementAddCalc.round2(
    returnLines.fold(0.0, (s, l) => s + l.net),
  );

  bool get canProceed =>
      invoice != null && !isInvoiceLoading && returnLines.isNotEmpty;

  SalesReplacementAddState copyWith({
    int? step,
    List<cust.ResultDatum>? customers,
    String? customerQuery,
    bool? isCustomersLoading,
    bool? isCustomersLoadingMore,
    bool? customersHasMore,
    String? customersError,
    bool clearCustomersError = false,
    cust.ResultDatum? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<bill.Result>? bills,
    int? billsPage,
    bool? isBillsLoading,
    bool? isBillsLoadingMore,
    bool? billsHasMore,
    String? billsError,
    bool clearBillsError = false,
    String? selectedBillNo,
    bool clearSelectedBill = false,
    InvoiceDetailModel? invoice,
    bool clearInvoice = false,
    bool? isInvoiceLoading,
    String? invoiceError,
    String? technicalDetails,
    bool clearInvoiceError = false,
    Map<int, int>? returnQty,
  }) {
    return SalesReplacementAddState(
      step: step ?? this.step,
      customers: customers ?? this.customers,
      customerQuery: customerQuery ?? this.customerQuery,
      isCustomersLoading: isCustomersLoading ?? this.isCustomersLoading,
      isCustomersLoadingMore:
      isCustomersLoadingMore ?? this.isCustomersLoadingMore,
      customersHasMore: customersHasMore ?? this.customersHasMore,
      customersError: clearCustomersError
          ? null
          : (customersError ?? this.customersError),
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      bills: bills ?? this.bills,
      billsPage: billsPage ?? this.billsPage,
      isBillsLoading: isBillsLoading ?? this.isBillsLoading,
      isBillsLoadingMore: isBillsLoadingMore ?? this.isBillsLoadingMore,
      billsHasMore: billsHasMore ?? this.billsHasMore,
      billsError: clearBillsError ? null : (billsError ?? this.billsError),
      selectedBillNo: clearSelectedBill
          ? null
          : (selectedBillNo ?? this.selectedBillNo),
      invoice: clearInvoice ? null : (invoice ?? this.invoice),
      isInvoiceLoading: isInvoiceLoading ?? this.isInvoiceLoading,
      invoiceError: clearInvoiceError ? null : (invoiceError ?? this.invoiceError),
      technicalDetails: clearInvoiceError
          ? null
          : (technicalDetails ?? this.technicalDetails),
      returnQty: returnQty ?? this.returnQty,
    );
  }
}