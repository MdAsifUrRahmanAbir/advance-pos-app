import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/repositories/login_repository.dart';

class LoginFormState {
  final bool rememberMe;

  const LoginFormState({
    this.rememberMe = false,
  });

  LoginFormState copyWith({
    bool? rememberMe,
  }) {
    return LoginFormState(
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}


/*
final editProfileControllerProvider = NotifierProvider.autoDispose<EditProfileController, EditProfileState>(
  EditProfileController.new,
);
 */

class LoginController extends Notifier<LoginFormState> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  LoginFormState build() {
    emailController = TextEditingController(text: "user@test.com");
    passwordController = TextEditingController(text: "12345678");

    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });

    return const LoginFormState();
  }

  void setRememberMe(bool value) {
    state = state.copyWith(
      rememberMe: value,
    );
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

  LoginRepository get _repository => ref.read(loginRepositoryProvider);

  bool submit(
      void Function(
          String email,
          String password,
          bool rememberMe,
          ) onSignIn,
      ) {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    onSignIn(
      emailController.text.trim(),
      passwordController.text,
      state.rememberMe,
    );

    return true;
  }
}

final loginFormControllerProvider =
NotifierProvider.autoDispose<LoginController, LoginFormState>(
  LoginController.new,
);