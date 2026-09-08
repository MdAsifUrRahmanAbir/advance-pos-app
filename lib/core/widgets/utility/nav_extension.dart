// core/navigation/nav_helpers.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/route_names.dart';

extension NavHelpers on BuildContext {
  void restartFlowFrom(String path) {
    final router = GoRouter.of(this);
    router.go(RouteNames.mainShell);
    router.push(path);
  }
}