import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/password_strength_meter.dart';
import '../../data/repositories/register_repository.dart';

class RegisterFormState {
  final bool agreedToTerms;

  const RegisterFormState({
    this.agreedToTerms = false,
  });

  RegisterFormState copyWith({
    bool? agreedToTerms,
  }) {
    return RegisterFormState(
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }
}

class RegisterController extends Notifier<RegisterFormState> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  RegisterFormState build() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    ref.onDispose(() {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });

    return const RegisterFormState();
  }

  void setAgreedToTerms(bool value) {
    state = state.copyWith(
      agreedToTerms: value,
    );
  }

  PasswordStrength passwordStrength() {
    final password = passwordController.text;

    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(password)) score++;

    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.good,
      _ => PasswordStrength.strong,
    };
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fullNameRequired;
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }

    if (!value.contains('@')) {
      return AppStrings.emailInvalid;
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }

    if (value != passwordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }

    return null;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool canRegister() {
    return state.agreedToTerms;
  }


  RegisterRepository get _repository => ref.read(registerRepositoryProvider);

  void submit(
      void Function(
          String fullName,
          String email,
          String password,
          ) onRegister,
      ) {
    if (!validateForm()) {
      return;
    }

    if (!state.agreedToTerms) {
      return;
    }

    onRegister(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );
  }
}

final registerControllerProvider =
NotifierProvider.autoDispose<RegisterController, RegisterFormState>(
  RegisterController.new,
);