import 'dart:async';

import 'package:advance_pos_app/features/new_sale/data/models/stocks_model.dart';
import 'package:advance_pos_app/features/new_sale/data/repositories/new_sale_repository.dart';

import 'new_sale_fixtures.dart';

/// One recorded /product_stock request.
typedef ProductsCall = ({int start, int length, String search, int? categoryId});

/// In-memory /product_stock with real paging, search (name, SKU,
/// barcode) and category filtering. [gate] holds the next response;
/// [nextError] fails the next call only.
class FakeNewSaleRepository implements NewSaleRepository {
  FakeNewSaleRepository([List<CatalogEntry>? catalog])
      : catalog = catalog ?? sampleCatalog();

  final List<CatalogEntry> catalog;
  final List<ProductsCall> calls = [];
  Object? nextError;
  Completer<void>? gate;

  @override
  Future<StocksModel> getProducts({
    required int start,
    required int length,
    String search = '',
    int? categoryId,
  }) async {
    calls.add((
    start: start,
    length: length,
    search: search,
    categoryId: categoryId,
    ));
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }

    final q = search.toLowerCase();
    final matched = catalog.where((e) {
      if (categoryId != null && e.categoryId != categoryId) return false;
      if (q.isEmpty) return true;
      final p = (e.json['product'] as Map)['product'] as Map;
      return [p['name'], p['sku_code'], p['barcode']]
          .any((v) => (v as String).toLowerCase().contains(q));
    }).toList();
    final page = matched.skip(start).take(length).map((e) => e.json).toList();

    return StocksModel.fromJson({
      'status': 'success',
      'message': '',
      'draw': 1,
      'recordsTotal': matched.length,
      'recordsFiltered': matched.length,
      'recordsShowing': page.length,
      'resultData': page,
    });
  }
}