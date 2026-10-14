import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/sales_return_detail_repository.dart';
import '../states/sales_return_detail_state.dart';

/// Family arg: the return bill number (sent as the {id} path parameter).
final salesReturnDetailControllerProvider = NotifierProvider.autoDispose
    .family<SalesReturnDetailController, SalesReturnDetailState, String>(
  SalesReturnDetailController.new,
);

class SalesReturnDetailController extends Notifier<SalesReturnDetailState> {
  SalesReturnDetailController(this.returnBillNo);

  final String returnBillNo;
  bool _loading = false;

  SalesReturnDetailRepository get _repository =>
      ref.read(salesReturnDetailRepositoryProvider);

  @override
  SalesReturnDetailState build() {
    Future.microtask(() {
      if (ref.mounted) load();
    });
    return const SalesReturnDetailState(isLoading: true);
  }

  /// First load, retry and pull-to-refresh. Keeps the visible detail while
  /// reloading. Returns false on failure ([errorMessage] is set).
  Future<bool> load() async {
    if (_loading) return false;
    _loading = true;
    state = state.copyWith(isLoading: true);
    try {
      final detail = await _repository.getSalesReturnDetail(returnBillNo);
      if (!ref.mounted) return true;
      state = state.copyWith(isLoading: false, detail: detail);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.salesReturnDetails(returnBillNo),
        ),
      );
      return false;
    } finally {
      _loading = false;
    }
  }

  Future<bool> refresh() => load();
}