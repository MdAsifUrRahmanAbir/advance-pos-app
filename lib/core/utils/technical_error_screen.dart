import 'package:flutter/material.dart';
import '../../features/system/presentation/widgets/error_content.dart';
import '../theme/app_color_scheme.dart';

/// Full-page technical error view — wraps [ErrorContent] in its own
/// `Scaffold` with a close (X) button, so it can be pushed on top of
/// any screen (`Navigator.push`) whenever the person taps "View
/// technical details" from a compact [ErrorState].
///
/// Purely a presentation shell: [errorDetails] and both callbacks are
/// supplied by the caller (usually built via
/// `buildTechnicalErrorDetails()` from `core/utils/error_mapper.dart`).
class TechnicalErrorScreen extends StatelessWidget {
  final String errorDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onReportIssue;

  const TechnicalErrorScreen({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ErrorContent(
                  errorDetails: errorDetails,
                  onRetry: onRetry,
                  onReportIssue: onReportIssue,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}