import 'package:flutter/material.dart';

import '../../../../core/widgets/utility/error_state.dart';

class DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DashboardErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ErrorState(
          message: message,
          onRetry: onRetry,
          // errorDetails: message,
        ),
      ),
    );
  }
}