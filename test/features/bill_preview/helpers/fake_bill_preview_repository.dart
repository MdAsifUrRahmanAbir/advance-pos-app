import 'dart:async';

import 'package:advance_pos_app/features/bill_preview/data/models/sales_bill_preview_model.dart';
import 'package:advance_pos_app/features/bill_preview/data/repositories/bill_preview_repository.dart';

import 'bill_preview_fixtures.dart';

/// In-memory bill API. [gate] holds the response (to see the loading
/// state); [nextError] fails the next call only.
class FakeBillPreviewRepository implements BillPreviewRepository {
  FakeBillPreviewRepository({Map<String, dynamic>? bill})
      : bill = bill ?? billJson();

  Map<String, dynamic> bill;
  Object? nextError;
  Completer<void>? gate;
  final List<String> requested = [];

  @override
  Future<SalesBillPreviewModel> getSalesBillPreview(String billNo) async {
    requested.add(billNo);
    await (gate?.future ?? Future<void>.delayed(Duration.zero));
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    return SalesBillPreviewModel.fromJson(bill);
  }
}