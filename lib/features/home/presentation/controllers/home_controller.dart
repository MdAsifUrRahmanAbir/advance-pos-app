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

/// Dashboard is cache-first:
/// - Opening Home shows the cached dashboard without calling the API.
/// - The cache expires after [_cacheTtl]; the next open then calls the API.
/// - Pull-to-refresh / Retry always call the API.
/// Every successful API response replaces the cached copy. A failed call
/// keeps the old cache and the data already on screen.
class HomeController extends Notifier<HomeState> {
  /// How long a cached dashboard is shown before the API is called again.
  static const Duration _cacheTtl = Duration(days: 2);

  /// Sales figures are business data, so they go to the encrypted box.
  static final CachePolicy _cachePolicy = CachePolicy.sensitive(ttl: _cacheTtl);

  /// Only the latest load may write state.
  int _requestSeq = 0;

  @override
  HomeState build() {
    Future.microtask(() => getDashboard(forceRefresh: false));
    return HomeState.initial().copyWith(isDashboardLoading: true);
  }

  HomeRepository get _repository => ref.read(homeRepositoryProvider);
  LocalCacheService get _cache => ref.read(localCacheServiceProvider);

  /// One cached dashboard per branch, so a branch change never shows
  /// another branch's figures.
  String get _cacheKey =>
      'home_dashboard_${ref.read(apiParamsProvider).branchId}';

  /// Switches the Overview slice (today / monthly) of the fetched dashboard.
  void selectPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }

  /// Switches the chart range (7days / 12months).
  void selectChartRange(String range) {
    state = state.copyWith(selectedChartRange: range);
  }

  /// "View all" / "Show less" on Top Categories.
  void toggleShowAllCategories() {
    state = state.copyWith(showAllCategories: !state.showAllCategories);
  }

  /// "View all" / "Show less" on Top Products.
  void toggleShowAllProducts() {
    state = state.copyWith(showAllProducts: !state.showAllProducts);
  }

  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  /// With [forceRefresh] false (opening Home) a valid cached dashboard is
  /// shown and the API is skipped. With true (pull-to-refresh, Retry) the
  /// API is always called and its response replaces the cache.
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

  /// Cached dashboard, or null when missing / expired (the cache service
  /// deletes expired entries). An unreadable entry is dropped so the API
  /// is used instead.
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

  /// Replaces the cached dashboard. A failed write only costs the next
  /// open an API call, so it never fails the load.
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
