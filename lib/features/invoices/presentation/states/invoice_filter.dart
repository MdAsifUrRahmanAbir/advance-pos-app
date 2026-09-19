import 'package:flutter/foundation.dart';

/// Selected filter values for the Invoices list. Group/Category/
/// Subcategory/Brand mirror Stock's drawer filter; Customer/Employee
/// narrow to a specific person's invoices (no picker UI yet — see
/// [InvoiceFilterDrawer]'s TODO). `startDate`/`endDate` serve BOTH the
/// quick date-preset chips (Today/Yesterday/Last 7 Days/This Month/
/// Last Month) and a custom range picked in the drawer — both write
/// into the same two fields since they're the same "date range" concept
/// as far as the API is concerned.
@immutable
class InvoiceFilter {
  final int? groupId;
  final int? categoryId;
  final int? subCategoryId;
  final int? brandId;
  final int? customerId;
  final int? employeeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const InvoiceFilter({
    this.groupId,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.customerId,
    this.employeeId,
    this.startDate,
    this.endDate,
  });

  bool get isEmpty =>
      groupId == null &&
          categoryId == null &&
          subCategoryId == null &&
          brandId == null &&
          customerId == null &&
          employeeId == null &&
          startDate == null &&
          endDate == null;

  int get activeCount =>
      [groupId, categoryId, subCategoryId, brandId, customerId, employeeId].where((v) => v != null).length +
          (startDate != null || endDate != null ? 1 : 0);

  InvoiceFilter copyWith({
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    int? customerId,
    int? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return InvoiceFilter(
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      brandId: brandId ?? this.brandId,
      customerId: customerId ?? this.customerId,
      employeeId: employeeId ?? this.employeeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Clears one or more fields regardless of whether the caller passes
  /// null (copyWith can't null out a field via `??`) — mirrors
  /// [StockFilter.clearing].
  InvoiceFilter clearing({
    bool groupId = false,
    bool categoryId = false,
    bool subCategoryId = false,
    bool brandId = false,
    bool customerId = false,
    bool employeeId = false,
    bool startDate = false,
    bool endDate = false,
  }) {
    return InvoiceFilter(
      groupId: groupId ? null : this.groupId,
      categoryId: categoryId ? null : this.categoryId,
      subCategoryId: subCategoryId ? null : this.subCategoryId,
      brandId: brandId ? null : this.brandId,
      customerId: customerId ? null : this.customerId,
      employeeId: employeeId ? null : this.employeeId,
      startDate: startDate ? null : this.startDate,
      endDate: endDate ? null : this.endDate,
    );
  }

  static const empty = InvoiceFilter();
}