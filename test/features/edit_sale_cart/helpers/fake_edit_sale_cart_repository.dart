import 'dart:async';

import 'package:advance_pos_app/features/edit_sale_cart/data/models/edit_sale_source.dart';
import 'package:advance_pos_app/features/edit_sale_cart/data/repositories/edit_sale_cart_repository.dart';
import 'package:advance_pos_app/features/invoice_detail/data/models/invoice_detail_model.dart';
import 'package:advance_pos_app/features/new_sale/data/models/stocks_model.dart';

import '../../new_sale/helpers/new_sale_fixtures.dart';
import 'edit_sale_fixtures.dart';

/// In-memory invoice + product search. Builds [EditSaleSource] the same
/// way the real repository does. [invoiceGate] holds the next invoice
/// load; `next*Error` fail the next matching call only.
class FakeEditSaleCartRepository implements EditSaleCartRepository {
  FakeEditSaleCartRepository({
    Map<String, dynamic>? invoice,
    List<CatalogEntry>? catalog,
  })  : invoice = invoice ?? invoiceJson(),
        catalog = catalog ?? sampleCatalog();

  Map<String, dynamic> invoice;
  final List<CatalogEntry> catalog;

  final List<String> invoiceLoads = [];
  final List<String> searches = [];
  Object? nextInvoiceError;
  Object? nextSearchError;
  Completer<void>? invoiceGate;

  @override
  Future<EditSaleSource> getInvoiceForEdit(String billNo) async {
    invoiceLoads.add(billNo);
    final gate = invoiceGate;
    if (gate != null) {
      invoiceGate = null;
      await gate.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    final error = nextInvoiceError;
    if (error != null) {
      nextInvoiceError = null;
      throw error;
    }
    final detail = InvoiceDetailModel.fromJson(invoice);
    return EditSaleSource(
      detail: detail,
      customerNo: detail.resultData.customerNo,
    );
  }

  @override
  Future<StocksModel> searchProducts({
    required String search,
    int start = 0,
    int length = 20,
  }) async {
    searches.add(search);
    await Future<void>.delayed(Duration.zero);
    final error = nextSearchError;
    if (error != null) {
      nextSearchError = null;
      throw error;
    }
    final q = search.toLowerCase();
    final matched = catalog.where((e) {
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