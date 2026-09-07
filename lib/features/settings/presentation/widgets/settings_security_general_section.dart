import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';
import '../../../../core/widgets/common/settings_tile.dart';

/// Security and General groups — a toggle plus several
/// navigate-to-detail rows.
class SettingsSecurityGeneralSection extends StatelessWidget {
  final bool biometricAuth;
  final ValueChanged<bool>? onBiometricAuthChanged;
  final VoidCallback? onTwoFactorAuthTap;
  final VoidCallback? onActiveSessionsTap;
  final String languageValue;
  final VoidCallback? onLanguageTap;
  final String regionValue;
  final VoidCallback? onRegionTap;
  final VoidCallback? onChangePssword;

  const SettingsSecurityGeneralSection({
    super.key,
    this.biometricAuth = false,
    this.onBiometricAuthChanged,
    this.onTwoFactorAuthTap,
    this.onActiveSessionsTap,
    this.languageValue = 'English',
    this.onLanguageTap,
    this.regionValue = 'United States',
    this.onRegionTap,
    this.onChangePssword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          label: AppStrings.securitySection,
          children: [
            SettingsTile(
              title: AppStrings.biometricAuth,
              switchValue: biometricAuth,
              onSwitchChanged: onBiometricAuthChanged,
            ),
            SettingsTile(
              title: AppStrings.twoFactorAuth,
              onTap: onTwoFactorAuthTap,
            ),
            SettingsTile(
              title: AppStrings.activeSessions,
              onTap: onActiveSessionsTap,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        SettingsGroup(
          label: AppStrings.generalSection,
          children: [
            SettingsTile(
              title: AppStrings.language,
              value: languageValue,
              onTap: onLanguageTap,
            ),
            SettingsTile(
              title: AppStrings.region,
              value: regionValue,
              onTap: onRegionTap,
            ),
            SettingsTile(
              title: AppStrings.changePasswordTitle,
              // value: regionValue,
              onTap: onChangePssword,
            ),
          ],
        ),
      ],
    );
  }
}