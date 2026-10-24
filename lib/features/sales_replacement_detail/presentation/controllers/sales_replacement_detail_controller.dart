import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/sales_replacement_detail_repository.dart';
import '../states/sales_replacement_detail_state.dart';

/// Family arg: the return bill number (sent as the {id} path parameter).
final salesReplacementDetailControllerProvider = NotifierProvider.autoDispose
    .family<SalesReplacementDetailController, SalesReplacementDetailState, String>(
  SalesReplacementDetailController.new,
);

class SalesReplacementDetailController extends Notifier<SalesReplacementDetailState> {
  SalesReplacementDetailController(this.returnBillNo);

  final String returnBillNo;
  bool _loading = false;
  bool _invoiceLoading = false;

  SalesReplacementDetailRepository get _repository =>
      ref.read(salesReplacementDetailRepositoryProvider);

  @override
  SalesReplacementDetailState build() {
    Future.microtask(() {
      if (ref.mounted) load();
    });
    return const SalesReplacementDetailState(isLoading: true);
  }

  /// First load, retry and pull-to-refresh: the replacement detail, then
  /// the original invoice. Keeps the visible data while reloading. Returns
  /// false only when the replacement detail fails ([errorMessage] is set);
  /// an invoice failure is reported separately by [loadInvoice].
  Future<bool> load() async {
    if (_loading) return false;
    _loading = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.getSalesReplacementDetail(returnBillNo);
      if (!ref.mounted) return true;
      state = state.copyWith(isLoading: false, detail: detail);
      await loadInvoice();
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.salesReplacementDetails(returnBillNo),
        ),
      );
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Loads the original sale ("Sales Information") using the original sales
  /// bill number from the replacement detail. Also the card's Retry.
  Future<bool> loadInvoice() async {
    final billNo = state.detail?.resultData.resultDataReturn.originalSalesBillNo;
    if (billNo == null || billNo.isEmpty || _invoiceLoading) return false;
    _invoiceLoading = true;
    state = state.copyWith(isInvoiceLoading: true, clearInvoiceError: true);
    try {
      final invoice = await _repository.getInvoiceDetail(billNo);
      if (!ref.mounted) return true;
      state = state.copyWith(isInvoiceLoading: false, invoice: invoice);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isInvoiceLoading: false,
        invoiceErrorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    } finally {
      _invoiceLoading = false;
    }
  }

  Future<bool> refresh() => load();
}