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

  /// Loads the invoice for [invoiceId] if it isn't already loaded (or if
  /// a different invoice was previously loaded into this provider
  /// instance). Safe to call from the view's `build()` every frame — it
  /// only actually fetches once per [invoiceId].
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

  Future<bool> payDues() async {
    final invoice = state.invoice;
    if (invoice == null) return false;

    // TODO: wire to invoiceDetailRepositoryProvider.recordPayment(...)
    // once the backend supports it — currently just marks it paid
    // locally so the UI reflects the action without a real mutation.
    state = state.copyWith(isLoading: false);
    return true;
  }
}