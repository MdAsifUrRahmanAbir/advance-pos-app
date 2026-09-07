import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';
import '../../../../core/widgets/common/settings_tile.dart';

/// Legal group — Terms and Privacy open external links; Licenses
/// navigates to a detail screen.
class SettingsLegalSection extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLicensesTap;

  const SettingsLegalSection({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onLicensesTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: AppStrings.legalSection,
      children: [
        SettingsTile(
          title: AppStrings.termsOfService,
          trailing: SettingsTileTrailing.externalLink,
          onTap: onTermsTap,
        ),
        SettingsTile(
          title: AppStrings.privacyTitle,
          trailing: SettingsTileTrailing.externalLink,
          onTap: onPrivacyTap,
        ),
        SettingsTile(
          title: AppStrings.openSourceLicenses,
          onTap: onLicensesTap,
        ),
      ],
    );
  }
}