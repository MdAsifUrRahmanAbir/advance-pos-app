import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/payment_accounts_model.dart' as pa;
import '../../data/models/payment_system_model.dart' as ps;
import '../../data/models/subcategory_model.dart';
import '../../data/repositories/master_data_repository.dart';
import '../states/master_data_state.dart';

final masterDataControllerProvider =
    NotifierProvider<MasterDataController, MasterDataState>(
      MasterDataController.new,
    );

class MasterDataController extends Notifier<MasterDataState> {
  static const _ttl = Duration(days: 1);
  static const _groupsKey = 'master_data_groups';
  static const _categoriesKey = 'master_data_categories';
  static const _subcategoriesKey = 'master_data_subcategories';
  static const _brandsKey = 'master_data_brands';
  static const _paymentSystemsKey = 'master_data_payment_systems';
  static const _paymentAccountsKey = 'master_data_payment_accounts';

  MasterDataRepository get _repository =>
      ref.read(masterDataRepositoryProvider);
  LocalCacheService get _cache => ref.read(localCacheServiceProvider);

  @override
  MasterDataState build() {
    Future.microtask(loadAll);
    return MasterDataState.initial();
  }

  Future<void> loadAll({bool forceRefresh = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final groupsResult = await _loadGroups(forceRefresh: forceRefresh);
      final subcategoriesResult = await _loadSubcategories(
        forceRefresh: forceRefresh,
      );
      final brandsResult = await _loadBrands(forceRefresh: forceRefresh);
      final categoriesResult = await _loadCategories(
        forceRefresh: forceRefresh,
      );
      final paymentSystemsResult = await _loadPaymentSystems(
        forceRefresh: forceRefresh,
      );
      final paymentAccountsResult = await _loadPaymentAccounts(
        forceRefresh: forceRefresh,
      );

      state = state.copyWith(
        isLoading: false,
        groups: groupsResult.data,
        categoryData: categoriesResult.data,
        subcategories: subcategoriesResult.data,
        brands: brandsResult.data,
        paymentSystems: paymentSystemsResult.data,
        paymentAccounts: paymentAccountsResult.data,
        lastSyncedAt: DateTime.now(),
      );
      AppLogger.masterDataSynced(
        groups: groupsResult.data.length,
        categories: categoriesResult.data.categories.length,
        subcategories: subcategoriesResult.data.length,
        brands: brandsResult.data.length,
        groupsFromCache: groupsResult.fromCache,
        categoriesFromCache: categoriesResult.fromCache,
        subcategoriesFromCache: subcategoriesResult.fromCache,
        brandsFromCache: brandsResult.fromCache,
      );
    } catch (error, stackTrace) {
      AppLogger.controllerFailed('MasterDataController.loadAll', error);
      state = state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

  Future<void> refresh() => loadAll(forceRefresh: true);

  Future<({List<GroupItem> data, bool fromCache})> _loadGroups({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<GroupModel>(
        _groupsKey,
        CacheSensitivity.standard,
        GroupModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getGroups();
    await _cache.write<GroupModel>(
      _groupsKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }

  Future<({CategoryResultData data, bool fromCache})> _loadCategories({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<CategoryModel>(
        _categoriesKey,
        CacheSensitivity.standard,
        CategoryModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getCategories();
    await _cache.write<CategoryModel>(
      _categoriesKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }

  Future<({List<SubcategoryItem> data, bool fromCache})> _loadSubcategories({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<SubcategoryModel>(
        _subcategoriesKey,
        CacheSensitivity.standard,
        SubcategoryModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getSubcategories();
    await _cache.write<SubcategoryModel>(
      _subcategoriesKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }

  Future<({List<BrandItem> data, bool fromCache})> _loadBrands({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<BrandModel>(
        _brandsKey,
        CacheSensitivity.standard,
        BrandModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getBrands();
    await _cache.write<BrandModel>(
      _brandsKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }

  Future<({List<ps.ResultDatum> data, bool fromCache})> _loadPaymentSystems({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<ps.PaymentSystemModel>(
        _paymentSystemsKey,
        CacheSensitivity.standard,
        ps.PaymentSystemModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getPaymentSystems();
    await _cache.write<ps.PaymentSystemModel>(
      _paymentSystemsKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }

  Future<({List<pa.ResultDatum> data, bool fromCache})> _loadPaymentAccounts({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.read<pa.PaymentAccountsModel>(
        _paymentAccountsKey,
        CacheSensitivity.standard,
        pa.PaymentAccountsModel.fromJson,
      );
      if (cached != null) return (data: cached.resultData, fromCache: true);
    }
    final fresh = await _repository.getPaymentAccounts();
    await _cache.write<pa.PaymentAccountsModel>(
      _paymentAccountsKey,
      fresh,
      CachePolicy.standard(ttl: _ttl),
      (m) => m.toJson(),
    );
    return (data: fresh.resultData, fromCache: false);
  }
}
