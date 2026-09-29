import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/group_model.dart';
import '../models/payment_accounts_model.dart';
import '../models/payment_system_model.dart';
import '../models/subcategory_model.dart';

final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepository(ref.watch(apiClientProvider));
});

class MasterDataRepository {
  final ApiClient _apiClient;
  MasterDataRepository(this._apiClient);

  Future<GroupModel> getGroups() async {
    final response = await _apiClient.get(ApiEndpoints.groups);
    return GroupModel.fromJson(response.data);
  }

  Future<CategoryModel> getCategories({int topSaleCategoryLimit = 10}) async {
    final response = await _apiClient.get(ApiEndpoints.categories(topSaleCategoryLimit: topSaleCategoryLimit));
    return CategoryModel.fromJson(response.data);
  }

  Future<SubcategoryModel> getSubcategories() async {
    final response = await _apiClient.get(ApiEndpoints.subcategories);
    return SubcategoryModel.fromJson(response.data);
  }

  Future<BrandModel> getBrands() async {
    final response = await _apiClient.get(ApiEndpoints.brands);
    return BrandModel.fromJson(response.data);
  }

  /// GET /gnl/payment_system/all — Cash, Bank, bKash, ... Full list, no pagination.
  Future<PaymentSystemModel> getPaymentSystems() async {
    final response = await _apiClient.get(ApiEndpoints.paymentSystem);
    return PaymentSystemModel.fromJson(response.data);
  }

  /// GET /gnl/payment_account/all — every configured account, each tagged
  /// with its owning payment system.
  Future<PaymentAccountsModel> getPaymentAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.paymentAccount);
    return PaymentAccountsModel.fromJson(response.data);
  }
}