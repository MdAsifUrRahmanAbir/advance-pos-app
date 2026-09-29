import 'package:flutter/foundation.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/payment_accounts_model.dart' as pa;
import '../../data/models/payment_system_model.dart' as ps;
import '../../data/models/subcategory_model.dart';

@immutable
class MasterDataState {
  final bool isLoading;
  final String? errorMessage;
  final List<GroupItem> groups;
  final CategoryResultData? categoryData;
  final List<SubcategoryItem> subcategories;
  final List<BrandItem> brands;
  final List<ps.ResultDatum> paymentSystems;
  final List<pa.ResultDatum> paymentAccounts;
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
    this.lastSyncedAt,
  });

  factory MasterDataState.initial() => const MasterDataState();

  bool get isReady => lastSyncedAt != null;

  MasterDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GroupItem>? groups,
    CategoryResultData? categoryData,
    List<SubcategoryItem>? subcategories,
    List<BrandItem>? brands,
    List<ps.ResultDatum>? paymentSystems,
    List<pa.ResultDatum>? paymentAccounts,
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
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}