import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../widgets/terms_privacy_content.dart';

/// Same content as [TermsMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class TermsTabView extends ConsumerWidget {
  const TermsTabView({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const AppHeaderBar(
          title: AppStrings.termsPrivacyTitle,
          subtitle: AppStrings.termsLastUpdated,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.xl),
                child: TermsPrivacyContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}