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

  SalesReplacementDetailRepository get _repository =>
      ref.read(salesReplacementDetailRepositoryProvider);

  @override
  SalesReplacementDetailState build() {
    Future.microtask(() {
      if (ref.mounted) load();
    });
    return const SalesReplacementDetailState(isLoading: true);
  }

  /// First load, retry and pull-to-refresh. Keeps the visible detail while
  /// reloading. Returns false on failure ([errorMessage] is set).
  Future<bool> load() async {
    if (_loading) return false;
    _loading = true;
    state = state.copyWith(isLoading: true);
    try {
      final detail = await _repository.getSalesReplacementDetail(returnBillNo);
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
          endpoint: ApiEndpoints.salesReplacementDetails(returnBillNo),
        ),
      );
      return false;
    } finally {
      _loading = false;
    }
  }

  Future<bool> refresh() => load();
}