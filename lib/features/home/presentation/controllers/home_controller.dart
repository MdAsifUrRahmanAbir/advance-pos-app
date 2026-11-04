import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/api_params.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/home_repository.dart';
import '../states/home_state.dart';

final homeControllerProvider =
NotifierProvider.autoDispose<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  static const Duration _cacheTtl = Duration(days: 2);

  static final CachePolicy _cachePolicy = CachePolicy.sensitive(ttl: _cacheTtl);

  int _requestSeq = 0;

  @override
  HomeState build() {
    Future.microtask(() => getDashboard(forceRefresh: false));
    return HomeState.initial().copyWith(isDashboardLoading: true);
  }

  HomeRepository get _repository => ref.read(homeRepositoryProvider);
  LocalCacheService get _cache => ref.read(localCacheServiceProvider);

  String get _cacheKey =>
      'home_dashboard_${ref.read(apiParamsProvider).branchId}';

  void selectPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }

  void selectChartRange(String range) {
    state = state.copyWith(selectedChartRange: range);
  }

  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getDashboard({bool forceRefresh = true}) async {
    final seq = ++_requestSeq;

    if (!forceRefresh) {
      final cached = _readCache();
      if (cached != null) {
        state = state.copyWith(
          isDashboardLoading: false,
          dashboardModel: cached,
        );
        return true;
      }
    }

    state = state.copyWith(isDashboardLoading: true);
    try {
      final dashboard = await _repository.getDashboard();
      if (!ref.mounted || seq != _requestSeq) return false;
      state = state.copyWith(
        isDashboardLoading: false,
        dashboardModel: dashboard,
      );
      await _writeCache(dashboard);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted || seq != _requestSeq) return false;
      state = state.copyWith(
        isDashboardLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }


  DashboardModel? _readCache() {
    try {
      return _cache.read<DashboardModel>(
        _cacheKey,
        _cachePolicy.sensitivity,
        DashboardModel.fromJson,
      );
    } catch (_) {
      _cache.invalidate(_cacheKey, _cachePolicy.sensitivity);
      return null;
    }
  }


  Future<void> _writeCache(DashboardModel dashboard) async {
    try {
      await _cache.write<DashboardModel>(
        _cacheKey,
        dashboard,
        _cachePolicy,
            (m) => m.toJson(),
      );
    } catch (_) {}
  }
}