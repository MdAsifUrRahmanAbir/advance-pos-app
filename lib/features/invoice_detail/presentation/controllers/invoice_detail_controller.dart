import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/invoice_detail_repository.dart';
import '../states/invoice_detail_state.dart';

final invoiceDetailControllerProvider =
NotifierProvider.autoDispose<InvoiceDetailController, InvoiceDetailState>(InvoiceDetailController.new);

class InvoiceDetailController extends Notifier<InvoiceDetailState> {
  InvoiceDetailRepository get _repository => ref.read(invoiceDetailRepositoryProvider);

  @override
  InvoiceDetailState build() => const InvoiceDetailState();

  /// Fetches the invoice for [invoiceId]. Call this from the view's
  /// `initState` (deferred via `Future.microtask`), NOT from `build()` —
  /// `initState` itself still counts as "building" to Riverpod, so the
  /// first `state = ...` line below must run after the current
  /// synchronous call stack unwinds, which `Future.microtask` guarantees.
  /// Skips re-fetching if this exact [invoiceId] is already
  /// loaded/loading.
  Future<void> loadInvoice(String invoiceId) async {
    if (state.loadedInvoiceId == invoiceId && (state.invoice != null || state.isLoading)) {
      return;
    }

    state = state.copyWith(isLoading: true, loadedInvoiceId: invoiceId, errorMessage: null);
    try {
      final invoice = await _repository.getInvoiceDetail(invoiceId);
      state = state.copyWith(isLoading: false, invoice: invoice);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: getErrorMessage(error));
    }
  }

  Future<void> retry() {
    final id = state.loadedInvoiceId;
    if (id == null) return Future.value();
    // Force a re-fetch by clearing the cached id first.
    state = state.copyWith(loadedInvoiceId: null);
    return loadInvoice(id);
  }

  Future<bool> payDues() async {
    if (state.invoice == null) return false;

    // TODO: wire to invoiceDetailRepositoryProvider.recordPayment(...)
    // once the backend supports it — currently a no-op success signal
    // since there's no real mutation path yet.
    return true;
  }
}