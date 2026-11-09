import 'dart:async';

import 'package:advance_pos_app/features/stock/data/models/stocks_model.dart';
import 'package:advance_pos_app/features/stock/data/repositories/stock_repository.dart';

import 'stock_fixtures.dart';

typedef StockCall = ({
int start,
int length,
String search,
int? groupId,
int? categoryId,
int? subCategoryId,
int? brandId,
});

/// GET /stocks over [catalog] with server-style paging, search (name
/// contains, or exact barcode/SKU) and category filter.
/// [gate] holds the next call; [nextError] throws on the next call only.
class FakeStockRepository implements StockRepository {
  List<Map<String, dynamic>> catalog = sampleCatalog();
  final List<StockCall> calls = [];
  Completer<void>? gate;
  Object? nextError;

  StockCall get lastCall => calls.last;

  @override
  Future<StocksModel> getStocks({
    required int start,
    required int length,
    String search = '',
    int? supplierId,
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
  }) async {
    calls.add((
    start: start,
    length: length,
    search: search,
    groupId: groupId,
    categoryId: categoryId,
    subCategoryId: subCategoryId,
    brandId: brandId,
    ));
    final g = gate;
    gate = null;
    final error = nextError;
    nextError = null;
    // Filter now, with this call's arguments, before any wait.
    final rows = catalog.where((row) {
      final p = (row['product'] as Map)['product'] as Map;
      final matchesSearch = search.isEmpty ||
          (p['name'] as String).contains(search) ||
          p['barcode'] == search ||
          p['sku_code'] == search;
      final matchesCategory =
          categoryId == null || row['_category'] == categoryId;
      return matchesSearch && matchesCategory;
    }).toList();

    if (g != null) {
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    if (error != null) throw error;

    final page = rows.skip(start).take(length).toList();
    return StocksModel.fromJson({
      'status': 'success',
      'message': 'ok',
      'draw': 1,
      'recordsTotal': catalog.length,
      'recordsFiltered': rows.length,
      'recordsShowing': page.length,
      'resultData': [
        for (var i = 0; i < page.length; i++)
          {'sl': start + i + 1, 'product': page[i]['product']},
      ],
    });
  }
}