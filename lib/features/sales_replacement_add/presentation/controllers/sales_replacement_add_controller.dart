import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../customers/data/models/customers_model.dart' as cust;
import '../../data/models/bills_model.dart' as bill;
import '../../data/repositories/sales_replacement_add_repository.dart';
import '../states/sales_replacement_add_state.dart';

final salesReplacementAddControllerProvider = NotifierProvider.autoDispose<
    SalesReplacementAddController, SalesReplacementAddState>(
  SalesReplacementAddController.new,
);

/// Step 1 of "New Replacement": optional customer → sales bill → the
/// original sale's products → which of them (and how many) come back.
class SalesReplacementAddController extends Notifier<SalesReplacementAddState> {
  static const int _customerPageLength = 20;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Timer? _customerDebounce;
  int _customerSeq = 0;
  int _billSeq = 0;
  int _invoiceSeq = 0;

  SalesReplacementAddRepository get _repository =>
      ref.read(salesReplacementAddRepositoryProvider);

  @override
  SalesReplacementAddState build() {
    ref.onDispose(() => _customerDebounce?.cancel());
    return const SalesReplacementAddState();
  }

  // ───────────────────────────────────────────────
  // Customers (optional filter for the bill list)
  // ───────────────────────────────────────────────
  /// Called when the customer sheet opens: load the first page if needed.
  void ensureCustomersLoaded() {
    if (state.customers.isEmpty && !state.isCustomersLoading) {
      loadCustomers(reset: true);
    }
  }

  void onCustomerSearch(String value) {
    _customerDebounce?.cancel();
    _customerDebounce = Timer(_searchDebounce, () {
      if (!ref.mounted) return;
      final query = value.trim();
      if (query == state.customerQuery) return;
      state = state.copyWith(customerQuery: query);
      loadCustomers(reset: true);
    });
  }

  Future<void> loadCustomers({bool reset = false}) async {
    if (!reset &&
        (state.isCustomersLoading ||
            state.isCustomersLoadingMore ||
            !state.customersHasMore)) {
      return;
    }
    final seq = ++_customerSeq; // newer request wins; stale ones dropped
    final start = reset ? 0 : state.customers.length;
    state = state.copyWith(
      isCustomersLoading: reset,
      isCustomersLoadingMore: !reset,
      customers: reset ? const <cust.ResultDatum>[] : null,
      clearCustomersError: true,
    );
    try {
      final result = await _repository.getCustomers(
        start: start,
        length: _customerPageLength,
        search: state.customerQuery,
      );
      if (!ref.mounted || seq != _customerSeq) return;
      final merged = reset
          ? result.resultData
          : [...state.customers, ...result.resultData];
      state = state.copyWith(
        isCustomersLoading: false,
        isCustomersLoadingMore: false,
        customers: merged,
        customersHasMore:
        result.resultData.isNotEmpty && merged.length < result.recordsFiltered,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _customerSeq) return;
      state = state.copyWith(
        isCustomersLoading: false,
        isCustomersLoadingMore: false,
        customersError: getErrorMessage(error, stackTrace),
      );
    }
  }

  void selectCustomer(cust.ResultDatum customer) {
    state = state.copyWith(selectedCustomer: customer);
    _resetBillSelection();
  }

  void clearCustomer() {
    state = state.copyWith(clearSelectedCustomer: true);
    _resetBillSelection();
  }

  /// The bill list depends on the customer, so a customer change empties
  /// the bills and drops the chosen bill, its invoice and the returns.
  void _resetBillSelection() {
    _billSeq++;
    _invoiceSeq++;
    state = state.copyWith(
      bills: const <bill.Result>[],
      billsPage: 0,
      billsHasMore: true,
      isBillsLoading: false,
      isBillsLoadingMore: false,
      clearBillsError: true,
      clearSelectedBill: true,
      clearInvoice: true,
      isInvoiceLoading: false,
      clearInvoiceError: true,
      returnQty: const {},
    );
  }

  // ───────────────────────────────────────────────
  // Sales bills (paged, filtered by customer when one is chosen)
  // ───────────────────────────────────────────────
  void ensureBillsLoaded() {
    if (state.bills.isEmpty && !state.isBillsLoading) loadBills(reset: true);
  }

  Future<void> loadBills({bool reset = false}) async {
    if (!reset &&
        (state.isBillsLoading || state.isBillsLoadingMore || !state.billsHasMore)) {
      return;
    }
    final seq = ++_billSeq;
    final page = reset ? 1 : state.billsPage + 1;
    state = state.copyWith(
      isBillsLoading: reset,
      isBillsLoadingMore: !reset,
      clearBillsError: true,
    );
    try {
      final result = await _repository.getSalesBills(
        branchId: ref.read(sessionBranchIdProvider),
        customerNo: state.selectedCustomer?.customerNo,
        page: page,
      );
      if (!ref.mounted || seq != _billSeq) return;
      state = state.copyWith(
        isBillsLoading: false,
        isBillsLoadingMore: false,
        bills: reset ? result.result : [...state.bills, ...result.result],
        billsPage: page,
        billsHasMore: result.hasMore,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _billSeq) return;
      state = state.copyWith(
        isBillsLoading: false,
        isBillsLoadingMore: false,
        billsError: getErrorMessage(error, stackTrace),
      );
    }
  }

  // ───────────────────────────────────────────────
  // The original sale
  // ───────────────────────────────────────────────
  Future<void> selectBill(String billNo) {
    state = state.copyWith(
      selectedBillNo: billNo,
      clearInvoice: true,
      clearInvoiceError: true,
      returnQty: const {},
    );
    return loadInvoice();
  }

  /// Loads the chosen bill's invoice; also the error state's Retry.
  Future<void> loadInvoice() async {
    final billNo = state.selectedBillNo;
    if (billNo == null) return;
    final seq = ++_invoiceSeq;
    state = state.copyWith(isInvoiceLoading: true, clearInvoiceError: true);
    try {
      final invoice = await _repository.getInvoiceDetail(billNo);
      if (!ref.mounted || seq != _invoiceSeq) return;
      state = state.copyWith(isInvoiceLoading: false, invoice: invoice);
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _invoiceSeq) return;
      state = state.copyWith(
        isInvoiceLoading: false,
        invoiceError: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.invoiceDetails(billNo),
        ),
      );
    }
  }

  // ───────────────────────────────────────────────
  // Returned products
  // ───────────────────────────────────────────────
  int _soldQty(int productId) =>
      state.soldLines.where((l) => l.productId == productId).firstOrNull?.soldQty ??
          0;

  /// Selects a line (1 unit) or deselects it.
  void toggleReturn(int productId) {
    final next = {...state.returnQty};
    if (next.containsKey(productId)) {
      next.remove(productId);
    } else if (_soldQty(productId) > 0) {
      next[productId] = 1;
    }
    state = state.copyWith(returnQty: next);
  }

  /// Capped at the quantity that was sold. Quantity already returned by an
  /// earlier replacement isn't known here; the server rejects an excess.
  void incrementReturn(int productId) {
    final current = state.returnQty[productId] ?? 0;
    if (current >= _soldQty(productId)) return;
    state = state.copyWith(returnQty: {...state.returnQty, productId: current + 1});
  }

  void decrementReturn(int productId) {
    final current = state.returnQty[productId] ?? 0;
    final next = {...state.returnQty};
    if (current <= 1) {
      next.remove(productId);
    } else {
      next[productId] = current - 1;
    }
    state = state.copyWith(returnQty: next);
  }

  // ───────────────────────────────────────────────
  // Steps
  // ───────────────────────────────────────────────
  void goToReplace() {
    if (state.canProceed) state = state.copyWith(step: 1);
  }

  void backToSelect() => state = state.copyWith(step: 0);
}