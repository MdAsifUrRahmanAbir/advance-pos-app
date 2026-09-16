import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/invoice_detail_repository.dart';
import '../states/invoice_detail_state.dart';

final invoiceDetailControllerProvider =
    NotifierProvider.autoDispose<InvoiceDetailController, InvoiceDetailState>(
      InvoiceDetailController.new,
    );

class InvoiceDetailController extends Notifier<InvoiceDetailState> {
  InvoiceDetailRepository get _repository =>
      ref.read(invoiceDetailRepositoryProvider);

  @override
  InvoiceDetailState build() => const InvoiceDetailState();

  /// Fetches the invoice for [invoiceId]. Call this from the view's
  /// `initState` (deferred via `Future.microtask`), NOT from `build()`.
  /// Skips re-fetching if this exact [invoiceId] is already
  /// loaded/loading.
  Future<void> loadInvoice(String invoiceId) async {
    if (state.loadedInvoiceId == invoiceId &&
        (state.invoiceDetailModel != null || state.isLoading)) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      loadedInvoiceId: invoiceId,
      errorMessage: null,
    );
    try {
      final result = await _repository.getInvoiceDetail(invoiceId);
      state = state.copyWith(isLoading: false, invoiceDetailModel: result);
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

  Future<void> retry() {
    final id = state.loadedInvoiceId;
    if (id == null) return Future.value();
    state = state.copyWith(loadedInvoiceId: null);
    return loadInvoice(id);
  }

  Future<bool> payDues() async {
    if (state.invoice == null) return false;

    // TODO: wire to a real payment-recording endpoint once the backend
    // supports it — currently a no-op success signal.
    return true;
  }
}
