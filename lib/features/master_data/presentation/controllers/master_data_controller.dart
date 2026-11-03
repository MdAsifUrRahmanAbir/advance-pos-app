import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/head_model.dart';
import '../../data/models/payment_accounts_model.dart' as pa;
import '../../data/models/payment_system_model.dart' as ps;
import '../../data/models/subcategory_model.dart';
import '../../data/repositories/master_data_repository.dart';
import '../states/master_data_state.dart';

final masterDataControllerProvider =
NotifierProvider<MasterDataController, MasterDataState>(
  MasterDataController.new,
);

/// Result of loading one master-data set.
typedef _KindResult = ({
MasterDataKind kind,
MasterDataSource? source,
int count,
String? error,
});

class MasterDataController extends Notifier<MasterDataState> {
  static const _ttl = Duration(days: 1);
  static const _keys = {
    MasterDataKind.groups: 'master_data_groups',
    MasterDataKind.categories: 'master_data_categories',
    MasterDataKind.subcategories: 'master_data_subcategories',
    MasterDataKind.brands: 'master_data_brands',
    MasterDataKind.paymentSystems: 'master_data_payment_systems',
    MasterDataKind.paymentAccounts: 'master_data_payment_accounts',
    MasterDataKind.accountHeads: 'master_data_account_heads',
  };

  MasterDataRepository get _repository =>
      ref.read(masterDataRepositoryProvider);
  LocalCacheService get _cache => ref.read(localCacheServiceProvider);

  /// The load in progress, shared by callers that arrive while it runs.
  Future<bool>? _inFlight;

  @override
  MasterDataState build() {
    Future.microtask(loadAll);
    return MasterDataState.initial();
  }

  /// Loads every set. True only when ALL sets arrived and none failed —
  /// check [MasterDataState.missing] / [MasterDataState.failures] for which.
  Future<bool> loadAll({bool forceRefresh = true}) =>
      _run(MasterDataKind.values.toSet(), forceRefresh: forceRefresh);

  Future<bool> refresh() => loadAll(forceRefresh: true);

  /// Reloads only the sets that are missing or failed last time.
  Future<bool> retryFailed() {
    final kinds = {...state.missing, ...state.failures.keys};
    if (kinds.isEmpty) return Future.value(true);
    return _run(kinds, forceRefresh: true);
  }

  Future<bool> _run(Set<MasterDataKind> kinds, {required bool forceRefresh}) {
    final running = _inFlight;
    if (running != null) return running;
    final future = _load(kinds, forceRefresh: forceRefresh);
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<bool> _load(
      Set<MasterDataKind> kinds, {
        required bool forceRefresh,
      }) async {
    state = state.copyWith(isLoading: true);

    final results = await Future.wait([
      for (final kind in kinds) _loadSafely(kind, forceRefresh: forceRefresh),
    ]);
    if (!ref.mounted) return false;

    final loaded = {...state.loaded};
    final failures = {...state.failures};
    final empty = {...state.empty};
    for (final r in results) {
      final error = r.error;
      if (error != null) {
        failures[r.kind] = error;
        continue;
      }
      loaded[r.kind] = r.source!;
      failures.remove(r.kind);
      r.count == 0 ? empty.add(r.kind) : empty.remove(r.kind);
    }

    final allGood =
        loaded.length == MasterDataKind.values.length && failures.isEmpty;
    state = state.copyWith(
      isLoading: false,
      loaded: loaded,
      failures: failures,
      empty: empty,
      errorMessage: failures.isEmpty
          ? null
          : failures.entries.map((e) => '${e.key.name}: ${e.value}').join('\n'),
      lastSyncedAt: allGood ? DateTime.now() : null,
    );

    _report(results);
    return allGood;
  }

  Future<_KindResult> _loadSafely(
      MasterDataKind kind, {
        required bool forceRefresh,
      }) async {
    try {
      final r = await _loadKind(kind, forceRefresh: forceRefresh);
      return (kind: kind, source: r.source, count: r.count, error: null);
    } catch (error, stackTrace) {
      AppLogger.controllerFailed('MasterDataController.${kind.name}', error);
      return (
      kind: kind,
      source: null,
      count: 0,
      error: getErrorMessage(error, stackTrace),
      );
    }
  }

  /// Fetches one set, writes it to state and returns where it came from and
  /// how many rows it has.
  Future<({MasterDataSource source, int count})> _loadKind(
      MasterDataKind kind, {
        required bool forceRefresh,
      }) async {
    switch (kind) {
      case MasterDataKind.groups:
        final r = await _fetch<GroupModel>(
          kind, forceRefresh, GroupModel.fromJson, (m) => m.toJson(),
          _repository.getGroups,
        );
        if (ref.mounted) state = state.copyWith(groups: r.model.resultData);
        return (source: r.source, count: r.model.resultData.length);

      case MasterDataKind.categories:
        final r = await _fetch<CategoryModel>(
          kind, forceRefresh, CategoryModel.fromJson, (m) => m.toJson(),
          _repository.getCategories,
        );
        if (ref.mounted) state = state.copyWith(categoryData: r.model.resultData);
        return (source: r.source, count: r.model.resultData.categories.length);

      case MasterDataKind.subcategories:
        final r = await _fetch<SubcategoryModel>(
          kind, forceRefresh, SubcategoryModel.fromJson, (m) => m.toJson(),
          _repository.getSubcategories,
        );
        if (ref.mounted) {
          state = state.copyWith(subcategories: r.model.resultData);
        }
        return (source: r.source, count: r.model.resultData.length);

      case MasterDataKind.brands:
        final r = await _fetch<BrandModel>(
          kind, forceRefresh, BrandModel.fromJson, (m) => m.toJson(),
          _repository.getBrands,
        );
        if (ref.mounted) state = state.copyWith(brands: r.model.resultData);
        return (source: r.source, count: r.model.resultData.length);

      case MasterDataKind.paymentSystems:
        final r = await _fetch<ps.PaymentSystemModel>(
          kind, forceRefresh, ps.PaymentSystemModel.fromJson, (m) => m.toJson(),
          _repository.getPaymentSystems,
        );
        if (ref.mounted) {
          state = state.copyWith(paymentSystems: r.model.resultData);
        }
        return (source: r.source, count: r.model.resultData.length);

      case MasterDataKind.paymentAccounts:
        final r = await _fetch<pa.PaymentAccountsModel>(
          kind, forceRefresh, pa.PaymentAccountsModel.fromJson, (m) => m.toJson(),
          _repository.getPaymentAccounts,
        );
        if (ref.mounted) {
          state = state.copyWith(paymentAccounts: r.model.resultData);
        }
        return (source: r.source, count: r.model.resultData.length);

      case MasterDataKind.accountHeads:
        final r = await _fetch<HeadModel>(
          kind, forceRefresh, HeadModel.fromJson, (m) => m.toJson(),
          _repository.getAccountHead,
        );
        if (ref.mounted) state = state.copyWith(accountHeads: r.model.headData);
        return (source: r.source, count: r.model.headData.length);
    }
  }

  /// Cache-or-API for one set. With [forceRefresh] the cache is skipped;
  /// a fresh response is always written back to the cache.
  Future<({M model, MasterDataSource source})> _fetch<M>(
      MasterDataKind kind,
      bool forceRefresh,
      M Function(Map<String, dynamic>) fromJson,
      Map<String, dynamic> Function(M) toJson,
      Future<M> Function() request,
      ) async {
    final key = _keys[kind]!;
    if (!forceRefresh) {
      final cached = _cache.read<M>(key, CacheSensitivity.standard, fromJson);
      if (cached != null) return (model: cached, source: MasterDataSource.cache);
    }
    final fresh = await request();
    await _cache.write<M>(key, fresh, CachePolicy.standard(ttl: _ttl), toJson);
    return (model: fresh, source: MasterDataSource.api);
  }

  /// Console summary: which sets arrived, from where, how many rows, and
  /// which failed or came back empty.
  void _report(List<_KindResult> results) {
    String describe(_KindResult r) {
      final error = r.error;
      if (error != null) return 'FAILED  $error';
      final source = r.source?.name.toUpperCase() ?? '';
      return r.count == 0 ? 'EMPTY   ($source)' : '${r.count}  ($source)';
    }

    final lines = [
      for (final r in results) '${r.kind.name.padRight(16)}: ${describe(r)}',
    ];
    AppLogger.masterDataReport(
      lines.join('\n'),
      complete: state.isComplete && !state.hasFailures,
    );
  }
}