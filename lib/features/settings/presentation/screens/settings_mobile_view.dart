import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/radio_option.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../routes/route_names.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_toggles_section.dart';
import '../widgets/settings_security_general_section.dart';
import '../widgets/settings_legal_section.dart';
import '../widgets/settings_footer_actions.dart';

class SettingsMobileView extends ConsumerWidget {
  const SettingsMobileView({super.key});

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppStrings.themeSystem,
    ThemeMode.light => AppStrings.themeLight,
    ThemeMode.dark => AppStrings.themeDark,
  };

  Future<void> _openThemePicker(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider.notifier);
    final current = ref.read(themeControllerProvider);

    return CustomBottomSheet.show<void>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.appTheme, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          for (final mode in ThemeMode.values)
            RadioOption<ThemeMode>(
              value: mode,
              groupValue: current,
              title: _themeLabel(mode),
              onChanged: (v) {
                themeController.setThemeMode(v!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.deleteAccount,
      message: 'This action is permanent and cannot be undone. Are you sure?',
      confirmText: AppStrings.deleteAccount,
      destructive: true,
    );

    if (confirmed == true) {
      await ref.read(settingsControllerProvider.notifier).deleteAccount();

      await ref.read(authSessionControllerProvider.notifier).logout();
      if(!context.mounted) return;
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(settingsControllerProvider.notifier);
    final state = ref.watch(settingsControllerProvider);

    final themeMode = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    return Column(
      children: [
        const AppHeaderBar(title: AppStrings.settingsTitle,         backStyle: HeaderBackStyle.chevron,),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SettingsTogglesSection(
                  darkMode: themeMode == ThemeMode.dark,
                  onDarkModeChanged: (val) => themeController
                      .setThemeMode(val ? ThemeMode.dark : ThemeMode.light),

                  appThemeValue: _themeLabel(themeMode),
                  onAppThemeTap: () => _openThemePicker(context, ref),

                  pushNotifications: state.pushNotifications,
                  onPushNotificationsChanged: controller.setPushNotifications,

                  emailNotifications: state.emailNotifications,
                  onEmailNotificationsChanged: controller.setEmailNotifications,

                  smsAlerts: state.smsAlerts,
                  onSmsAlertsChanged: controller.setSmsAlerts,
                ),

                const SizedBox(height: AppSizes.lg),

                SettingsSecurityGeneralSection(
                  biometricAuth: state.biometricAuth,
                  onBiometricAuthChanged: controller.setBiometricAuth,

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

                  onChangePssword: () {
                    context.push(RouteNames.changePassword);
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                SettingsLegalSection(
                  onTermsTap: () {
                    context.push(RouteNames.termsPrivacy);
                  },

                  onPrivacyTap: () {
                    context.push(RouteNames.termsPrivacy);
                  },

                  onLicensesTap: () {
                    context.push(RouteNames.helpSupport);
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                SettingsFooterActions(
                  versionLabel: 'v2.4.1 (Build 2026)',

                  onLogOutTap: () async{
                    await ref.read(authSessionControllerProvider.notifier).logout();
                    if(!context.mounted) return;
                    context.go(RouteNames.login);
                  },

                  onDeleteAccountTap: () {
                    _confirmDeleteAccount(context, ref);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}