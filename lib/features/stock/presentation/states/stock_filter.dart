import 'package:flutter/foundation.dart';

/// Selected filter IDs for the Stock list — supplier is included in the
/// API contract and the repository, but there's currently no supplier
/// master-data source wired into the app, so [StockFilterDrawer] has no
/// UI control for it yet. Wire one in once a supplier-list endpoint
/// exists.
@immutable
class StockFilter {
  final int? supplierId;
  final int? groupId;
  final int? categoryId;
  final int? subCategoryId;
  final int? brandId;

  const StockFilter({
    this.supplierId,
    this.groupId,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
  });

  bool get isEmpty =>
      supplierId == null && groupId == null && categoryId == null && subCategoryId == null && brandId == null;

  int get activeCount => [supplierId, groupId, categoryId, subCategoryId, brandId].where((v) => v != null).length;

  StockFilter copyWith({
    int? supplierId,
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
  }) {
    return StockFilter(
      supplierId: supplierId ?? this.supplierId,
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      brandId: brandId ?? this.brandId,
    );
  }

  /// Clears one field regardless of whether the caller passes null
  /// (copyWith can't null out a field via `??`), used by the drawer's
  /// per-section "Clear" / reset flow.
  StockFilter clearing({
    bool supplierId = false,
    bool groupId = false,
    bool categoryId = false,
    bool subCategoryId = false,
    bool brandId = false,
  }) {
    return StockFilter(
      supplierId: supplierId ? null : this.supplierId,
      groupId: groupId ? null : this.groupId,
      categoryId: categoryId ? null : this.categoryId,
      subCategoryId: subCategoryId ? null : this.subCategoryId,
      brandId: brandId ? null : this.brandId,
    );
  }

  static const empty = StockFilter();
}