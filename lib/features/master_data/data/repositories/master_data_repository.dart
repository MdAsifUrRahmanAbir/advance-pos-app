import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/group_model.dart';
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
}