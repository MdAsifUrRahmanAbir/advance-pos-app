import 'dart:async';

import 'package:advance_pos_app/features/home/data/models/dashboard_model.dart';
import 'package:advance_pos_app/features/home/data/repositories/home_repository.dart';

import 'home_fixtures.dart';

/// GET /dashboard. [respond] builds the JSON per call number (1-based);
/// [gate] holds the next call; [nextError] throws on the next call only.
class FakeHomeRepository implements HomeRepository {
  int calls = 0;
  Map<String, dynamic> Function(int call) respond = (_) => dashboardJson();
  Completer<void>? gate;
  Object? nextError;

  @override
  Future<DashboardModel> getDashboard() async {
    final call = ++calls;
    final g = gate;
    gate = null;
    final error = nextError;
    nextError = null;

    if (g != null) {
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    if (error != null) throw error;
    return DashboardModel.fromJson(respond(call));
  }
}