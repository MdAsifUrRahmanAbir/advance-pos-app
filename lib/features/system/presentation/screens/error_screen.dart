import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/error_content.dart';
import '../../../../core/utils/responsive.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: const ErrorMobileView(),
        tablet: const ErrorTabView(),
      ),
    );
  }
}



class ErrorMobileView extends StatelessWidget {
  final String? errorDetails;

  const ErrorMobileView({super.key, this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xxl),
      child: ErrorContent(
        // TODO: replace with the real captured exception/stack trace
        // once a crash-reporting provider (e.g. Sentry/Crashlytics) is wired in.
        errorDetails: errorDetails ??
            'Error: Cluster_Database_Failed\n'
                'Code: 0x88F92A\n'
                'Stack: auth_endpoint.go:124',
        onRetry: () {
          // TODO: re-run the failed operation once retry semantics exist
        },
        onReportIssue: () {
          // TODO: open a report-issue flow once that route/service exists
        },
      ),
    );
  }
}



/// Same content as [ErrorMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class ErrorTabView extends StatelessWidget {
  final String? errorDetails;

  const ErrorTabView({super.key, this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: SingleChildScrollView(
            child: ErrorContent(
              errorDetails: errorDetails ??
                  'Error: Cluster_Database_Failed\n'
                      'Code: 0x88F92A\n'
                      'Stack: auth_endpoint.go:124',
              onRetry: () {},
              onReportIssue: () {},
            ),
          ),
        ),
      ),
    );
  }
}