import 'package:advance_pos_app/features/master_data/data/models/brand_model.dart';
import 'package:advance_pos_app/features/master_data/data/models/category_model.dart';
import 'package:advance_pos_app/features/master_data/data/models/group_model.dart';
import 'package:advance_pos_app/features/master_data/data/models/subcategory_model.dart';

const stockBranchId = 3;
const otherBranchId = 9;
const beveragesId = 5;
const snacksId = 6;
const catalogSize = 20;

String two(int i) => i.toString().padLeft(2, '0');
String productName(int i) => 'Product ${two(i)}';

/// Stock in this branch: 0 for every 5th product, else i × 2.
int branchQty(int i) => i % 5 == 0 ? 0 : i * 2;

bool isOutOfStock(int i) => branchQty(i) == 0;

/// One catalog row: `_category` is only used by the fake's filter,
/// `product` is the API's `resultData[].product`.
Map<String, dynamic> catalogRow(int i) => {
  '_category': i.isOdd ? beveragesId : snacksId,
  'product': {
    'id': i,
    'product': {
      'name': productName(i),
      'sku_code': 'SKU-${two(i)}',
      // Product 02 has no barcode: the card falls back to sys_barcode.
      'barcode': i == 2 ? '' : 'BC-${two(i)}',
      'sys_barcode': 'SYS-${two(i)}',
      'sale_price': '${100 + i}.00',
      'cost_price': '${80 + i}.00',
    },
    'stock': {
      'organization_stock': 999,
      // Another branch is listed first on purpose (the old
      // branchStock.first bug showed its 0).
      'branch_stock': [
        {'id': otherBranchId, 'name': 'Gulshan', 'stock': 0},
        {'id': stockBranchId, 'name': 'Dhanmondi', 'stock': branchQty(i)},
      ],
    },
  },
};

List<Map<String, dynamic>> sampleCatalog([int count = catalogSize]) =>
    [for (var i = 1; i <= count; i++) catalogRow(i)];

// ── Master data ──

List<TopCategory> sampleTopCategories() => [
  TopCategory(
    branchId: stockBranchId,
    branchName: 'Dhanmondi',
    categoryId: beveragesId,
    categoryName: 'Beverages',
    totalQuantity: 100,
    totalAmount: '10000',
  ),
  TopCategory(
    branchId: stockBranchId,
    branchName: 'Dhanmondi',
    categoryId: snacksId,
    categoryName: 'Snacks',
    totalQuantity: 80,
    totalAmount: '8000',
  ),
];

Category _category(int id, String name) => Category.fromJson({
  'id': id,
  'category_name': name,
  'category_code': 'C$id',
  'group_id': [1],
  'group_info': '',
  'other_cost': '0',
  'product_type': '',
  'processing_fee': '0',
  'serial_barcode': '',
});

CategoryResultData sampleCategoryData() => CategoryResultData(
  branch: Branch(branchId: stockBranchId, branchName: 'Dhanmondi'),
  topCategories: sampleTopCategories(),
  categories: [
    _category(beveragesId, 'Beverages'),
    _category(snacksId, 'Snacks'),
  ],
);

List<GroupItem> sampleGroups() => [
  GroupItem.fromJson({'sl': 1, 'id': 1, 'group_name': 'Grocery', 'group_code': 'G1'}),
];

List<SubcategoryItem> sampleSubcategories() => [
  SubcategoryItem.fromJson({
    'sl': 1,
    'id': 51,
    'prod_cat_id': [beveragesId],
    'sub_category_name': 'Soft Drinks',
    'sub_category_code': 'S51',
  }),
  SubcategoryItem.fromJson({
    'sl': 2,
    'id': 61,
    'prod_cat_id': [snacksId],
    'sub_category_name': 'Chips',
    'sub_category_code': 'S61',
  }),
];

List<BrandItem> sampleBrands() => [
  BrandItem.fromJson({'sl': 1, 'id': 7, 'model_name': 'Acme', 'model_code': 'B7'}),
];