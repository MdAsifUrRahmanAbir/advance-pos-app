import 'package:advance_pos_app/features/master_data/data/models/category_model.dart';

const groceryId = 10;
const toiletriesId = 20;

/// One /product_stock row. Branch 1 (the signed-in branch) and branch 2
/// hold different stock, so tests prove the right branch is used.
Map<String, dynamic> productJson({
  required int id,
  required String name,
  required String sku,
  required String barcode,
  required String price,
  required int branchStock,
  int otherBranchStock = 50,
}) =>
    {
      'sl': id,
      'product': {
        'id': id,
        'product': {
          'name': name,
          'sku_code': sku,
          'barcode': barcode,
          'sys_barcode': 'SYS$id',
          'sale_price': price,
          'cost_price': '0',
        },
        'stock': {
          'organization_stock': branchStock + otherBranchStock,
          'branch_stock': [
            {'id': 1, 'name': 'Dhanmondi', 'stock': branchStock},
            {'id': 2, 'name': 'Uttara', 'stock': otherBranchStock},
          ],
        },
      },
    };

/// A product row plus the category the fake server files it under.
typedef CatalogEntry = ({Map<String, dynamic> json, int categoryId});

String fillerName(int i) => 'Item ${i.toString().padLeft(2, '0')}';

/// Rice (stock 5), Soap (stock 2), Oil (out of stock), then fillers up to
/// [count] — 25 by default, so there is a second page.
List<CatalogEntry> sampleCatalog({int count = 25}) => [
  (
  json: productJson(
    id: 1,
    name: 'Rice 5kg',
    sku: 'R5',
    barcode: '8901',
    price: '450.00',
    branchStock: 5,
  ),
  categoryId: groceryId,
  ),
  (
  json: productJson(
    id: 2,
    name: 'Soap',
    sku: 'S1',
    barcode: '8902',
    price: '45.00',
    branchStock: 2,
  ),
  categoryId: toiletriesId,
  ),
  (
  json: productJson(
    id: 3,
    name: 'Oil 1L',
    sku: 'O1',
    barcode: '8903',
    price: '180.00',
    branchStock: 0,
  ),
  categoryId: groceryId,
  ),
  for (var i = 4; i <= count; i++)
    (
    json: productJson(
      id: i,
      name: fillerName(i),
      sku: 'F$i',
      barcode: '99$i',
      price: '10.00',
      branchStock: 10,
    ),
    categoryId: groceryId,
    ),
];

TopCategory topCategory(int id, String name) => TopCategory(
  branchId: 1,
  branchName: 'Dhanmondi',
  categoryId: id,
  categoryName: name,
  totalQuantity: 0,
  totalAmount: '0',
);

List<TopCategory> sampleTopCategories() => [
  topCategory(groceryId, 'Grocery'),
  topCategory(toiletriesId, 'Toiletries'),
];