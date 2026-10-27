import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/session_profile.dart';
import '../../../../core/utils/currency_formatter.dart' show parseAmount;
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/utils/receipt_share_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';
import '../../../cart/presentation/states/cart_state.dart' show CartLineItem;
import '../../../invoice_detail/data/models/invoice_detail_model.dart'
    show InvoiceDetailModel;
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../new_sale/data/models/stocks_model.dart' as stock;
import '../../../new_sale/presentation/states/new_sale_state.dart'
    show ProductItem, ScanOutcome, ScanResult;
import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem, SelectedPaymentEntry;
import '../../data/repositories/sales_replacement_add_repository.dart';
import '../states/sales_replacement_add_calc.dart';
import '../states/sales_replacement_add_state.dart';
import '../states/sales_replacement_receipt.dart';
import '../states/sales_replacement_replace_state.dart';
import 'sales_replacement_add_controller.dart';

enum ReplaceAddOutcome { added, noStock }

final salesReplacementReplaceControllerProvider = NotifierProvider.autoDispose<
    SalesReplacementReplaceController, SalesReplacementReplaceState>(
  SalesReplacementReplaceController.new,
);

/// Step 2 of "New Replacement": the replacement items, totals against the
/// return credit, payment of the difference, and the submit.
///
/// Payment selection and split follow the same rules as the regular
/// Payment screen; that feature itself is not touched.
class SalesReplacementReplaceController
    extends Notifier<SalesReplacementReplaceState> {
  static const Duration _debounceDelay = Duration(milliseconds: 400);
  static const int _productPageLength = 20;

  /// Retail sales — same value the other sale endpoints send.
  static const String _salesType = '1';

  late TextEditingController productSearchController;
  late TextEditingController reasonController;
  Timer? _productDebounce;
  int _productSeq = 0;

  SalesReplacementAddRepository get _repository =>
      ref.read(salesReplacementAddRepositoryProvider);

  @override
  SalesReplacementReplaceState build() {
    productSearchController = TextEditingController();
    reasonController = TextEditingController();
    ref.onDispose(() {
      _productDebounce?.cancel();
      productSearchController.dispose();
      reasonController.dispose();
    });

    // Step 1 can still change while this step exists (the user goes back):
    // keep the return credit in sync and start over when the bill changes.
    ref.listen(
      salesReplacementAddControllerProvider.select((s) => s.returnTotal),
          (_, next) {
        final payable = _payableFor(state.newTotal, next);
        state = state.copyWith(
          returnTotal: next,
          selectedEntries: _resync(state.selectedEntries, payable),
        );
      },
    );
    ref.listen(
      salesReplacementAddControllerProvider.select((s) => s.selectedBillNo),
          (previous, next) {
        if (previous != next) _reset();
      },
    );
    return SalesReplacementReplaceState(
      returnTotal: ref.read(salesReplacementAddControllerProvider).returnTotal,
    );
  }

  void _reset() {
    _productDebounce?.cancel();
    _productSeq++;
    productSearchController.clear();
    reasonController.clear();
    state = SalesReplacementReplaceState(
      returnTotal: ref.read(salesReplacementAddControllerProvider).returnTotal,
    );
  }

  double _round2(double v) => SalesReplacementAddCalc.round2(v);
  String _money(double v) => v.toStringAsFixed(2);

  double _payableFor(double newTotal, double returnTotal) {
    final net = _round2(newTotal - returnTotal);
    return net > 0.005 ? net : 0;
  }

  // ───────────────────────────────────────────────
  // Product search
  // ───────────────────────────────────────────────
  void updateProductQuery(String query) {
    _productDebounce?.cancel();
    state = state.copyWith(productQuery: query, clearProductSearchError: true);
    if (query.trim().length < SalesReplacementReplaceState.minProductSearchLength) {
      _productSeq++; // drop any in-flight response
      state = state.copyWith(
        productResults: const <ProductItem>[],
        isProductSearching: false,
      );
      return;
    }
    _productDebounce = Timer(_debounceDelay, () => _searchProducts(query.trim()));
  }

  Future<void> retryProductSearch() => _searchProducts(state.productQuery.trim());

  Future<void> _searchProducts(String query) async {
    final seq = ++_productSeq;
    state = state.copyWith(isProductSearching: true, clearProductSearchError: true);
    try {
      final branchId = ref.read(sessionBranchIdProvider);
      final result = await _repository.searchProducts(
        branchId: branchId,
        search: query,
        length: _productPageLength,
      );
      if (!ref.mounted || seq != _productSeq) return;
      state = state.copyWith(
        isProductSearching: false,
        productResults: [for (final r in result.resultData) _mapProduct(r, branchId)],
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _productSeq) return;
      state = state.copyWith(
        isProductSearching: false,
        productSearchError: getErrorMessage(error, stackTrace),
      );
    }
  }

  void clearProductSearch() {
    _productDebounce?.cancel();
    _productSeq++;
    productSearchController.clear();
    state = state.copyWith(
      productQuery: '',
      productResults: const <ProductItem>[],
      isProductSearching: false,
      clearProductSearchError: true,
    );
  }

  /// Exact barcode/SKU lookup for the scanner: adds the product straight
  /// to the replacement items without touching the search box. Returns
  /// null when the lookup itself failed.
  Future<ScanResult?> handleScannedCode(String code) async {
    try {
      final branchId = ref.read(sessionBranchIdProvider);
      final result = await _repository.searchProducts(
        branchId: branchId,
        search: code,
        length: 10,
      );
      if (!ref.mounted) return null;
      final match = result.resultData
          .map((r) => _mapProduct(r, branchId))
          .where((p) => p.barcode == code || p.sku == code)
          .firstOrNull;
      if (match == null) {
        return const ScanResult(product: null, outcome: ScanOutcome.notFound);
      }
      final outcome = addProduct(match);
      return ScanResult(
        product: match,
        outcome: outcome == ReplaceAddOutcome.added
            ? ScanOutcome.added
            : ScanOutcome.outOfStock,
      );
    } catch (_) {
      return null;
    }
  }

  int _branchStock(stock.Stock s, int branchId) {
    final entry = s.branchStock.where((b) => b.id == branchId).firstOrNull;
    return entry?.stock ?? s.organizationStock;
  }

  ProductItem _mapProduct(stock.ResultDatum r, int branchId) {
    final product = r.product.product;
    return ProductItem(
      id: r.product.id.toString(),
      name: product.name,
      sku: product.skuCode,
      price: parseAmount(product.salePrice),
      categoryKey: '',
      stock: _branchStock(r.product.stock, branchId),
      barcode: product.barcode.isNotEmpty ? product.barcode : product.sysBarcode,
    );
  }

  // ───────────────────────────────────────────────
  // Replacement lines
  // ───────────────────────────────────────────────
  ReplaceAddOutcome addProduct(ProductItem product) {
    if (state.remainingFor(product) <= 0) return ReplaceAddOutcome.noStock;

    final lines = List<CartLineItem>.from(state.newLines);
    final index = lines.indexWhere((l) => l.id == product.id);
    if (index == -1) {
      lines.add(CartLineItem(
        id: product.id,
        name: product.name,
        unitPrice: product.price,
        quantity: 1,
      ));
    } else {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    }
    _setLines(lines, caps: {...state.stockCaps, product.id: product.stock});
    return ReplaceAddOutcome.added;
  }

  /// False when the line is already at the stock it was added with.
  bool incrementLine(String id) {
    final lines = List<CartLineItem>.from(state.newLines);
    final index = lines.indexWhere((l) => l.id == id);
    if (index == -1) return false;
    final cap = state.stockCaps[id];
    if (cap != null && lines[index].quantity >= cap) return false;
    lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    _setLines(lines);
    return true;
  }

  void decrementLine(String id) {
    final lines = List<CartLineItem>.from(state.newLines);
    final index = lines.indexWhere((l) => l.id == id);
    if (index == -1) return;
    if (lines[index].quantity <= 1) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity - 1);
    }
    _setLines(lines);
  }

  void removeLine(String id) {
    _setLines(state.newLines.where((l) => l.id != id).toList());
  }

  /// Every line change moves the payable amount, so the payment amounts
  /// are re-derived with it.
  void _setLines(List<CartLineItem> lines, {Map<String, int>? caps}) {
    final newTotal = _round2(lines.fold(0.0, (s, l) => s + l.lineTotal));
    final payable = _payableFor(newTotal, state.returnTotal);
    state = state.copyWith(
      newLines: lines,
      stockCaps: caps,
      selectedEntries: _resync(state.selectedEntries, payable),
      clearError: true,
    );
  }

  // ───────────────────────────────────────────────
  // Payment (same rules as PaymentController)
  // ───────────────────────────────────────────────
  List<pa.ResultDatum> accountsForSystem(pa.PaymentSystem system) {
    final accounts = ref.read(masterDataControllerProvider).paymentAccounts;
    return accounts.where((a) => a.paymentSystem.id == system.id).toList();
  }

  void toggleSystem(pa.PaymentSystem system) {
    final current = List<SelectedPaymentEntry>.from(state.selectedEntries);
    final index = current.indexWhere((e) => e.system.id == system.id);

    if (index != -1) {
      current.removeAt(index);
    } else {
      if (current.length >= SalesReplacementReplaceState.maxPaymentMethods) return;
      var entry = SelectedPaymentEntry(system: system);
      // Cash / Reward have no dropdown — bind their account right away.
      if (!entry.needsAccountPicker) {
        final accounts = accountsForSystem(system);
        if (accounts.isNotEmpty) entry = entry.copyWith(account: accounts.first);
      }
      current.add(entry);
    }
    state = state.copyWith(
      selectedEntries: _startingSplit(current, state.payable),
      clearError: true,
    );
  }

  /// 1 entry → the full payable; 2 entries → 50/50 starting split.
  List<SelectedPaymentEntry> _startingSplit(
      List<SelectedPaymentEntry> entries,
      double payable,
      ) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) return [entries.first.copyWith(amount: payable)];
    final half = _round2(payable / 2);
    return [
      entries[0].copyWith(amount: half),
      entries[1].copyWith(amount: _round2(payable - half)),
    ];
  }

  /// After the payable amount changed: one method takes it all; with two,
  /// the first keeps its amount (up to the payable) and the second covers
  /// the rest.
  List<SelectedPaymentEntry> _resync(
      List<SelectedPaymentEntry> entries,
      double payable,
      ) {
    if (entries.isEmpty) return entries;
    if (entries.length == 1) return [entries.first.copyWith(amount: payable)];
    final first = _round2(math.min(entries[0].amount, payable));
    return [
      entries[0].copyWith(amount: first),
      entries[1].copyWith(amount: _round2(math.max(payable - first, 0))),
    ];
  }

  void selectAccountForSystem(int systemId, pa.ResultDatum account) {
    state = state.copyWith(
      selectedEntries: [
        for (final e in state.selectedEntries)
          if (e.system.id == systemId) e.copyWith(account: account) else e,
      ],
    );
  }

  /// Editing one amount auto-fills the other with `payable - edited`
  /// (never below 0). Non-cash is capped at payable; cash may exceed it
  /// (the difference is change).
  void updateAmountForSystem(int systemId, double amount) {
    final payable = state.payable;
    final entries = state.selectedEntries;
    final edited = entries.where((e) => e.system.id == systemId).firstOrNull;
    if (edited == null) return;

    var value = amount < 0 ? 0.0 : amount;
    if (!edited.isCash) value = math.min(value, payable);
    final complement = _round2(math.max(payable - value, 0));

    state = state.copyWith(
      selectedEntries: [
        for (final e in entries)
          if (e.system.id == systemId)
            e.copyWith(amount: value)
          else if (entries.length == 2)
            e.copyWith(amount: complement)
          else
            e,
      ],
    );
  }

  // ───────────────────────────────────────────────
  // POST /s_return/add
  // ───────────────────────────────────────────────
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    final profile = ref.read(sessionProfileProvider);
    if (profile == null) {
      state = state.copyWith(errorMessage: AppStrings.editSaleNotSignedIn);
      return false;
    }
    final add = ref.read(salesReplacementAddControllerProvider);
    final invoice = add.invoice;
    final billNo = add.selectedBillNo;
    if (invoice == null || billNo == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final created = await _repository.createSalesReplacement(
        _buildPayload(profile, add, invoice, billNo),
      );
      if (!ref.mounted) return true;
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
        createdBillNo: created,
        receipt: _buildReceipt(created, add, invoice),
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  /// Frozen copy of what was just created, for the success sheet, the
  /// shared image and the printed slip.
  SalesReplacementReceipt _buildReceipt(
      String billNo,
      SalesReplacementAddState add,
      InvoiceDetailModel invoice,
      ) {
    return SalesReplacementReceipt(
      billNo: billNo,
      originalBillNo: add.selectedBillNo ?? '',
      date: _formatDate(DateTime.now()),
      customerName: invoice.resultData.customerName,
      methodLabel: state.selectedEntries.isEmpty
          ? AppStrings.emptyValue
          : state.selectedEntries.map((e) => e.system.paymentSystemName).join(' + '),
      returned: [
        for (final l in add.returnLines)
          ReceiptLineItem(name: l.sold.name, quantity: l.quantity, lineTotal: l.net),
      ],
      replacement: [
        for (final l in state.newLines)
          ReceiptLineItem(name: l.name, quantity: l.quantity, lineTotal: l.lineTotal),
      ],
      returnTotal: add.returnTotal,
      newTotal: state.newTotal,
      netPayable: state.payable,
      collected: state.needsPayment ? state.totalCollected : 0,
      change: state.cashReturn,
    );
  }

  // ───────────────────────────────────────────────
  // Share / print the created replacement
  // ───────────────────────────────────────────────
  Future<bool> shareReceipt(GlobalKey boundaryKey) async {
    final receipt = state.receipt;
    if (receipt == null) return false;
    state = state.copyWith(isSharing: true);
    try {
      await ReceiptShareService.shareReceiptImage(
        boundaryKey: boundaryKey,
        saleId: receipt.billNo,
      );
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return true;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isSharing: false);
      return false;
    }
  }

  Future<bool> printReceipt(String printerMac) async {
    final receipt = state.receipt;
    if (receipt == null) return false;
    state = state.copyWith(isPrinting: true);
    try {
      final connected = await ThermalPrinterService.isConnected() ||
          await ThermalPrinterService.connect(printerMac);
      final success = connected &&
          await ThermalPrinterService.printReceipt(
            storeName: AppStrings.appBrandName,
            billNo: receipt.billNo,
            saleDate: receipt.date,
            methodLabel: receipt.methodLabel,
            returnedItems: receipt.returned,
            returnedHeading: AppStrings.repdReturnedSectionTitle,
            itemsHeading: AppStrings.repdReplacementSectionTitle,
            items: receipt.replacement,
            subtotal: receipt.newTotal,
            discount: receipt.returnTotal,
            discountLabel: AppStrings.repdReturnAmountLabel,
            total: receipt.netPayable,
            givenAmount: receipt.collected,
            changeDue: receipt.change,
          );
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return success;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isPrinting: false);
      return false;
    }
  }

  /// Field names follow the raw request sample of `POST /s_return/add`.
  Map<String, dynamic> _buildPayload(
      SessionProfile profile,
      SalesReplacementAddState add,
      InvoiceDetailModel invoice,
      String billNo,
      ) {
    final returned = add.returnLines;
    final lines = state.newLines;
    final payments = state.selectedEntries.where((e) => e.amount > 0.005).toList();
    final cashReturn = state.cashReturn;
    final customerNo = invoice.resultData.customerNo;

    return {
      'sales_type': _salesType,
      'branch_id': '${profile.branchId}',
      'employee_id': '${profile.employeeId}',
      if (customerNo.isNotEmpty) 'customer_id': customerNo,
      'sales_bill_no': billNo,
      // Returned products
      'product_id_arr': {
        for (var i = 0; i < returned.length; i++) '$i': '${returned[i].sold.productId}',
      },
      'product_quantity_arr': {
        for (var i = 0; i < returned.length; i++) '$i': '${returned[i].quantity}',
      },
      'prod_dis_amount_arr': {
        for (var i = 0; i < returned.length; i++)
          '$i': _money(returned[i].discountAmount),
      },
      'prod_dis_rate_arr': {
        for (var i = 0; i < returned.length; i++)
          '$i': _money(returned[i].sold.discountRate),
      },
      'total_quantity': '${add.returnItemCount}',
      'total_return_amount': _money(add.returnTotal),
      // Replacement products (no discount is applied to these)
      'total_quantity_new': '${state.newItemCount}',
      'total_payable_amount_new': _money(state.newTotal),
      'ta_after_discount_new': _money(state.newTotal),
      'product_id_arr_new': {
        for (var i = 0; i < lines.length; i++) '$i': lines[i].id,
      },
      'product_quantity_arr_new': {
        for (var i = 0; i < lines.length; i++) '$i': '${lines[i].quantity}',
      },
      'prod_dis_rate_new_arr': {
        for (var i = 0; i < lines.length; i++) '$i': '0.00',
      },
      // Payment of the difference
      'payment_sys_id_arr': {
        for (var i = 0; i < payments.length; i++) '$i': '${payments[i].system.id}',
      },
      'payment_acc_id_arr': {
        for (final e in payments)
          if (e.account != null) '${e.system.id}': '${e.account!.id}',
      },
      'have_to_pay_amount': _money(state.payable),
      'given_amount_arr': {
        for (final e in payments)
          '${e.system.id}': _money(e.isCash ? e.amount - cashReturn : e.amount),
      },
      'given_amount_new': _money(state.payable),
      'return_reason': reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    };
  }
}