import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/numbered_list_item.dart';
import '../../../../core/widgets/common/custom_card.dart';

/// The body of the Terms & Privacy document — numbered legal
/// sections, a data-collection breakdown, and a contact card. Purely
/// presentational and static; no repository or network calls.
class TermsPrivacyContent extends StatelessWidget {
  const TermsPrivacyContent({super.key});

  Widget _sectionTitle(String text, BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
  );

  Widget _sectionBody(String text, BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary, height: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(AppStrings.termsSection1Title, context),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        _sectionBody(AppStrings.termsSection1Body, context),
        const SizedBox(height: AppSizes.xl),

        _sectionTitle(AppStrings.termsSection2Title, context),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        _sectionBody(AppStrings.termsSection2Body, context),
        const SizedBox(height: AppSizes.sm),
        const NumberedListItem(number: '01', text: 'Secure system telemetry and active diagnostic profiles.'),
        const NumberedListItem(number: '02', text: 'Encrypted performance packets for secure cluster analytics.'),
        const NumberedListItem(number: '03', text: 'OAuth validation tokens for authenticated third-party connections.'),
        const SizedBox(height: AppSizes.md),

        _sectionTitle(AppStrings.termsSection3Title, context),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        _sectionBody(AppStrings.termsSection3Body, context),
        const SizedBox(height: AppSizes.xl),

        _sectionTitle(AppStrings.termsSection4Title, context),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        _sectionBody(AppStrings.termsSection4Body, context),
        const SizedBox(height: AppSizes.xl),

        _sectionTitle(AppStrings.termsSection5Title, context),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        _sectionBody(AppStrings.termsSection5Body, context),
        const SizedBox(height: AppSizes.md),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                AppStrings.termsContactName,
                style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.xs),
               Text(
                AppStrings.termsContactEmail,
                style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
              ),
               Text(
                AppStrings.termsContactSla,
                style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}