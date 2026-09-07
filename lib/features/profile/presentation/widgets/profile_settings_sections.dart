import 'package:flutter/material.dart';
import 'package:template_test/features/profile/presentation/widgets/settings_tile.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';

/// All three grouped settings lists (Account, Preferences,
/// Security & Support) shown on the profile screen. Taps are
/// reported up via the individual callbacks so navigation stays in
/// the caller's hands.
class ProfileSettingsSections extends StatelessWidget {
  final VoidCallback? onPersonalInfoTap;
  // final VoidCallback? onNotificationSettingsTap;
  // final VoidCallback? onLanguageTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onConnectedAppsTap;
  final VoidCallback? onTwoFactorAuthTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onSettingsTap;

  const ProfileSettingsSections({
    super.key,
    this.onPersonalInfoTap,
    // this.onNotificationSettingsTap,
    // this.onLanguageTap,
    this.onPrivacyTap,
    this.onConnectedAppsTap,
    this.onTwoFactorAuthTap,
    this.onHelpCenterTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          label: AppStrings.accountSection,
          children: [
            SettingsTile(
              icon: Icons.person_outline_rounded,
              title: AppStrings.personalInfoTitle,
              subtitle: AppStrings.personalInfoSubtitle,
              onTap: onPersonalInfoTap,
            ),
            // SettingsTile(
            //   icon: Icons.notifications_outlined,
            //   title: AppStrings.notificationSettingsTitle,
            //   subtitle: AppStrings.notificationSettingsSubtitle,
            //   onTap: onNotificationSettingsTap,
            // ),
            // SettingsTile(
            //   icon: Icons.language_rounded,
            //   title: AppStrings.languageTitle,
            //   subtitle: 'English (US) • UTC -05:00',
            //   onTap: onLanguageTap,
            // ),
            SettingsTile(
              icon: Icons.settings_outlined,
              title: AppStrings.settingsTitle,
              subtitle: AppStrings.settingsSubtitle,
              onTap: onSettingsTap,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          label: AppStrings.preferencesSection,
          children: [
            SettingsTile(
              icon: Icons.shield_outlined,
              title: AppStrings.privacyTitle,
              subtitle: AppStrings.privacySubtitle,
              onTap: onPrivacyTap,
            ),
            SettingsTile(
              icon: Icons.terminal_rounded,
              title: AppStrings.connectedAppsTitle,
              subtitle: 'Slack, GitHub, AWS Gateway, Jira',
              onTap: onConnectedAppsTap,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          label: AppStrings.securitySupportSection,
          children: [
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: AppStrings.twoFactorAuthTitle,
              subtitle: 'Enabled • Authenticator App',
              onTap: onTwoFactorAuthTap,
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppStrings.helpCenterTitle,
              subtitle: AppStrings.helpCenterSubtitle,
              onTap: onHelpCenterTap,
            ),
          ],
        ),
      ],
    );
  }
}