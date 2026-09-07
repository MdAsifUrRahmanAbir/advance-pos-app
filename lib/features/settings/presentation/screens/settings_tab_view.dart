import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_toggles_section.dart';
import '../widgets/settings_security_general_section.dart';
import '../widgets/settings_legal_section.dart';
import '../widgets/settings_footer_actions.dart';

/// Same content as [SettingsMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class SettingsTabView extends ConsumerWidget {
  const SettingsTabView({super.key});

  Future<void> _confirmDeleteAccount(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.deleteAccount,
      message:
      'This action is permanent and cannot be undone. Are you sure?',
      confirmText: AppStrings.deleteAccount,
      destructive: true,
    );

    if (confirmed == true) {
      await ref
          .read(settingsControllerProvider.notifier)
          .deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      settingsControllerProvider.notifier,
    );

    final state = ref.watch(
      settingsControllerProvider,
    );

    return Column(
      children: [
        const AppHeaderBar(
          backStyle: HeaderBackStyle.chevron,
          title: AppStrings.settingsTitle,
        ),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 640,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTogglesSection(
                      darkMode: state.darkMode,
                      onDarkModeChanged:
                      controller.setDarkMode,

                      onAppThemeTap: () {
                        // TODO: open app-theme picker
                      },

                      pushNotifications:
                      state.pushNotifications,
                      onPushNotificationsChanged:
                      controller.setPushNotifications,

                      emailNotifications:
                      state.emailNotifications,
                      onEmailNotificationsChanged:
                      controller.setEmailNotifications,

                      smsAlerts: state.smsAlerts,
                      onSmsAlertsChanged:
                      controller.setSmsAlerts,
                    ),

                    const SizedBox(
                      height: AppSizes.xl,
                    ),

                    SettingsSecurityGeneralSection(
                      biometricAuth:
                      state.biometricAuth,
                      onBiometricAuthChanged:
                      controller.setBiometricAuth,

                      onTwoFactorAuthTap: () {
                        // TODO: navigate to 2FA setup
                      },

                      onActiveSessionsTap: () {
                        // TODO: navigate to active sessions
                      },

                      onLanguageTap: () {
                        // TODO: open language picker
                      },

                      onRegionTap: () {
                        // TODO: open region picker
                      },
                    ),

                    const SizedBox(
                      height: AppSizes.xl,
                    ),

                    SettingsLegalSection(
                      onTermsTap: () {
                        // TODO: open Terms of Service
                      },

                      onPrivacyTap: () {
                        // TODO: open Privacy Policy
                      },

                      onLicensesTap: () {
                        // TODO: navigate to licenses
                      },
                    ),

                    const SizedBox(
                      height: AppSizes.xl,
                    ),

                    SettingsFooterActions(
                      versionLabel:
                      'v2.4.1 (Build 2026)',

                      onLogOutTap: () {
                        // TODO: call authControllerProvider.logout()
                      },

                      onDeleteAccountTap: () {
                        _confirmDeleteAccount(
                          context,
                          ref,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}