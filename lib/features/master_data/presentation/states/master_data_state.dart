import 'package:flutter/foundation.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/head_model.dart';
import '../../data/models/payment_accounts_model.dart' as pa;
import '../../data/models/payment_system_model.dart' as ps;
import '../../data/models/subcategory_model.dart';

/// Every master-data set the app loads. [MasterDataState.isComplete] is true
/// only when each one has arrived.
enum MasterDataKind {
  groups,
  categories,
  subcategories,
  brands,
  paymentSystems,
  paymentAccounts,
  accountHeads,
}

/// Where a loaded set came from in its last successful load.
enum MasterDataSource { api, cache }

@immutable
class MasterDataState {
  final bool isLoading;

  /// One line per failed set ("brands: <message>"); null when none failed.
  final String? errorMessage;

  final List<GroupItem> groups;
  final CategoryResultData? categoryData;
  final List<SubcategoryItem> subcategories;
  final List<BrandItem> brands;
  final List<ps.ResultDatum> paymentSystems;
  final List<pa.ResultDatum> paymentAccounts;
  final List<HeadDatum> accountHeads;

  /// Sets that have data in state, and where it came from. A set stays here
  /// after a failed refresh — its earlier data is still usable.
  final Map<MasterDataKind, MasterDataSource> loaded;

  /// Sets whose last load failed, with the user-safe error message.
  final Map<MasterDataKind, String> failures;

  /// Sets that loaded successfully but returned no rows.
  final Set<MasterDataKind> empty;

  /// Time of the last load in which every set arrived without a failure.
  final DateTime? lastSyncedAt;

  const MasterDataState({
    this.isLoading = false,
    this.errorMessage,
    this.groups = const [],
    this.categoryData,
    this.subcategories = const [],
    this.brands = const [],
    this.paymentSystems = const [],
    this.paymentAccounts = const [],
    this.accountHeads = const [],
    this.loaded = const {},
    this.failures = const {},
    this.empty = const {},
    this.lastSyncedAt,
  });

  factory MasterDataState.initial() => const MasterDataState();

  /// At least one set has data to show.
  bool get isReady => loaded.isNotEmpty;

  /// Every set has arrived (from the API or the cache).
  bool get isComplete => loaded.length == MasterDataKind.values.length;

  /// Some set failed in the last load (it may still hold older data).
  bool get hasFailures => failures.isNotEmpty;

  /// Sets with no data at all.
  List<MasterDataKind> get missing =>
      [for (final k in MasterDataKind.values) if (!loaded.containsKey(k)) k];

  bool isLoaded(MasterDataKind kind) => loaded.containsKey(kind);

  MasterDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GroupItem>? groups,
    CategoryResultData? categoryData,
    List<SubcategoryItem>? subcategories,
    List<BrandItem>? brands,
    List<ps.ResultDatum>? paymentSystems,
    List<pa.ResultDatum>? paymentAccounts,
    List<HeadDatum>? accountHeads,
    Map<MasterDataKind, MasterDataSource>? loaded,
    Map<MasterDataKind, String>? failures,
    Set<MasterDataKind>? empty,
    DateTime? lastSyncedAt,
  }) {
    return MasterDataState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      groups: groups ?? this.groups,
      categoryData: categoryData ?? this.categoryData,
      subcategories: subcategories ?? this.subcategories,
      brands: brands ?? this.brands,
      paymentSystems: paymentSystems ?? this.paymentSystems,
      paymentAccounts: paymentAccounts ?? this.paymentAccounts,
      accountHeads: accountHeads ?? this.accountHeads,
      loaded: loaded ?? this.loaded,
      failures: failures ?? this.failures,
      empty: empty ?? this.empty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}