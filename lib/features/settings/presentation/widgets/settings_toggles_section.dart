import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';
import '../../../../core/widgets/common/settings_tile.dart';

/// Appearance and Notifications groups — toggles and a picker row.
/// Purely presentational: reports changes up via the callbacks, does
/// not persist anything itself.
class SettingsTogglesSection extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool>? onDarkModeChanged;
  final String appThemeValue;
  final VoidCallback? onAppThemeTap;
  final bool pushNotifications;
  final ValueChanged<bool>? onPushNotificationsChanged;
  final bool emailNotifications;
  final ValueChanged<bool>? onEmailNotificationsChanged;
  final bool smsAlerts;
  final ValueChanged<bool>? onSmsAlertsChanged;

  const SettingsTogglesSection({
    super.key,
    this.darkMode = false,
    this.onDarkModeChanged,
    this.appThemeValue = 'System Default',
    this.onAppThemeTap,
    this.pushNotifications = false,
    this.onPushNotificationsChanged,
    this.emailNotifications = false,
    this.onEmailNotificationsChanged,
    this.smsAlerts = false,
    this.onSmsAlertsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          label: AppStrings.appearanceSection,
          children: [
            SettingsTile(
              title: AppStrings.darkMode,
              switchValue: darkMode,
              onSwitchChanged: onDarkModeChanged,
            ),
            SettingsTile(
              title: AppStrings.appTheme,
              value: appThemeValue,
              onTap: onAppThemeTap,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        SettingsGroup(
          label: AppStrings.notificationsSection,
          children: [
            SettingsTile(
              title: AppStrings.pushNotifications,
              switchValue: pushNotifications,
              onSwitchChanged: onPushNotificationsChanged,
            ),
            SettingsTile(
              title: AppStrings.emailNotifications,
              switchValue: emailNotifications,
              onSwitchChanged: onEmailNotificationsChanged,
            ),
            SettingsTile(
              title: AppStrings.smsAlerts,
              switchValue: smsAlerts,
              onSwitchChanged: onSmsAlertsChanged,
            ),
          ],
        ),
      ],
    );
  }
}