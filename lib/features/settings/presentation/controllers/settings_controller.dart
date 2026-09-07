import 'package:flutter_riverpod/flutter_riverpod.dart';


class SettingsState {
  final bool darkMode;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsAlerts;
  final bool biometricAuth;

  const SettingsState({
    this.darkMode = false,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsAlerts = false,
    this.biometricAuth = true,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsAlerts,
    bool? biometricAuth,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      pushNotifications:
      pushNotifications ?? this.pushNotifications,
      emailNotifications:
      emailNotifications ?? this.emailNotifications,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      biometricAuth:
      biometricAuth ?? this.biometricAuth,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void setDarkMode(bool value) {
    state = state.copyWith(
      darkMode: value,
    );
  }

  void setPushNotifications(bool value) {
    state = state.copyWith(
      pushNotifications: value,
    );
  }

  void setEmailNotifications(bool value) {
    state = state.copyWith(
      emailNotifications: value,
    );
  }

  void setSmsAlerts(bool value) {
    state = state.copyWith(
      smsAlerts: value,
    );
  }

  void setBiometricAuth(bool value) {
    state = state.copyWith(
      biometricAuth: value,
    );
  }

  Future<void> deleteAccount() async {

  }
}

final settingsControllerProvider =
NotifierProvider.autoDispose<
    SettingsController,
    SettingsState>(
  SettingsController.new,
);