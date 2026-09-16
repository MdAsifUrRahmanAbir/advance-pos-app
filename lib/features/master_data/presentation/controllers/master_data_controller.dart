import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/subcategory_model.dart';
import '../../data/repositories/master_data_repository.dart';
import '../states/master_data_state.dart';

/// Not `.autoDispose` — this data is app-wide and session-long (loaded
/// once via MainShell, read by any feature that needs groups/categories/
/// subcategories/brands), so it should never tear down just because the
/// screen that first triggered it was popped.
final masterDataControllerProvider =
NotifierProvider<MasterDataController, MasterDataState>(MasterDataController.new);

class MasterDataController extends Notifier<MasterDataState> {
  static const _ttl = Duration(days: 1);
  static const _groupsKey = 'master_data_groups';
  static const _categoriesKey = 'master_data_categories';
  static const _subcategoriesKey = 'master_data_subcategories';
  static const _brandsKey = 'master_data_brands';

  MasterDataRepository get _repository => ref.read(masterDataRepositoryProvider);
  LocalCacheService get _cache => ref.read(localCacheServiceProvider);

  @override
  MasterDataState build() {
    // Deferred via Future.microtask (same pattern as ProductController)
    // so the first `state = ...` assignment happens after this build()
    // call finishes, not during it.
    Future.microtask(loadAll);
    return MasterDataState.initial();
  }

  /// [forceRefresh] bypasses the cache entirely (pull-to-refresh, a
  /// "Sync now" button, etc.). Otherwise each dataset independently
  /// serves its cached copy if present and not older than 1 day —
  /// [LocalCacheService] already expires/deletes stale entries via
  /// [CacheEntry.isExpired], so a cache hit here always means fresh data.
  Future<void> loadAll({bool forceRefresh = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final groups = await _loadGroups(forceRefresh: forceRefresh);
      final categoryData = await _loadCategories(forceRefresh: forceRefresh);
      final subcategories = await _loadSubcategories(forceRefresh: forceRefresh);
      final brands = await _loadBrands(forceRefresh: forceRefresh);

      state = state.copyWith(
        isLoading: false,
        groups: groups,
        categoryData: categoryData,
        subcategories: subcategories,
        brands: brands,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: getErrorMessage(error));
    }
  }

  Future<void> refresh() => loadAll(forceRefresh: true);

  Future<List<GroupItem>> _loadGroups({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.read<GroupModel>(_groupsKey, CacheSensitivity.standard, GroupModel.fromJson);
      if (cached != null) return cached.resultData;
    }
    final fresh = await _repository.getGroups();
    await _cache.write<GroupModel>(_groupsKey, fresh, CachePolicy.standard(ttl: _ttl), (m) => m.toJson());
    return fresh.resultData;
  }

  Future<CategoryResultData> _loadCategories({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.read<CategoryModel>(_categoriesKey, CacheSensitivity.standard, CategoryModel.fromJson);
      if (cached != null) return cached.resultData;
    }
    final fresh = await _repository.getCategories();
    await _cache.write<CategoryModel>(_categoriesKey, fresh, CachePolicy.standard(ttl: _ttl), (m) => m.toJson());
    return fresh.resultData;
  }

  Future<List<SubcategoryItem>> _loadSubcategories({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.read<SubcategoryModel>(_subcategoriesKey, CacheSensitivity.standard, SubcategoryModel.fromJson);
      if (cached != null) return cached.resultData;
    }
    final fresh = await _repository.getSubcategories();
    await _cache.write<SubcategoryModel>(_subcategoriesKey, fresh, CachePolicy.standard(ttl: _ttl), (m) => m.toJson());
    return fresh.resultData;
  }

  Future<List<BrandItem>> _loadBrands({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.read<BrandModel>(_brandsKey, CacheSensitivity.standard, BrandModel.fromJson);
      if (cached != null) return cached.resultData;
    }
    final fresh = await _repository.getBrands();
    await _cache.write<BrandModel>(_brandsKey, fresh, CachePolicy.standard(ttl: _ttl), (m) => m.toJson());
    return fresh.resultData;
  }
}