import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/password_strength_meter.dart';

class ChangePasswordState {
  final PasswordStrength passwordStrength;

  const ChangePasswordState({
    this.passwordStrength = PasswordStrength.weak,
  });

  ChangePasswordState copyWith({
    PasswordStrength? passwordStrength,
  }) {
    return ChangePasswordState(
      passwordStrength:
      passwordStrength ?? this.passwordStrength,
    );
  }
}

class ChangePasswordController
    extends Notifier<ChangePasswordState> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  ChangePasswordState build() {
    currentPasswordController =
        TextEditingController();

    newPasswordController =
        TextEditingController();

    confirmPasswordController =
        TextEditingController();

    ref.onDispose(() {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });

    return const ChangePasswordState();
  }

  PasswordStrength strengthOf(String password) {
    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(password)) {
      score++;
    }

    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.good,
      _ => PasswordStrength.strong,
    };
  }

  void onNewPasswordChanged(String value) {
    state = state.copyWith(
      passwordStrength: strengthOf(value),
    );
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.currentPasswordRequired;
    }

    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value == currentPasswordController.text) {
      return AppStrings.newPasswordSameAsCurrent;
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }

    if (value != newPasswordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }

    return null;
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void submit(
      void Function(
          String currentPassword,
          String newPassword,
          ) onSave,
      ) {
    if (!validate()) {
      return;
    }

    onSave(
      currentPasswordController.text,
      newPasswordController.text,
    );
  }
}

final changePasswordControllerProvider =
NotifierProvider.autoDispose<
    ChangePasswordController,
    ChangePasswordState>(
  ChangePasswordController.new,
);