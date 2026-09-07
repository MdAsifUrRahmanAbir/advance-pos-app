import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';

class ResetPasswordState {
  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSymbol;
  final bool passwordsMatch;

  const ResetPasswordState({
    this.hasMinLength = false,
    this.hasNumber = false,
    this.hasSymbol = false,
    this.passwordsMatch = false,
  });

  ResetPasswordState copyWith({
    bool? hasMinLength,
    bool? hasNumber,
    bool? hasSymbol,
    bool? passwordsMatch,
  }) {
    return ResetPasswordState(
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasNumber: hasNumber ?? this.hasNumber,
      hasSymbol: hasSymbol ?? this.hasSymbol,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
    );
  }
}

class ResetPasswordController
    extends Notifier<ResetPasswordState> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController passwordController;
  late final TextEditingController confirmController;

  static final _symbolRegExp =
  RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]');

  static final _numberRegExp = RegExp(r'[0-9]');

  @override
  ResetPasswordState build() {
    passwordController = TextEditingController();
    confirmController = TextEditingController();

    ref.onDispose(() {
      passwordController.dispose();
      confirmController.dispose();
    });

    return const ResetPasswordState();
  }

  void onPasswordChanged(String value) {
    _revalidate();
  }

  void onConfirmPasswordChanged(String value) {
    _revalidate();
  }

  void _revalidate() {
    final password = passwordController.text;
    final confirm = confirmController.text;

    state = state.copyWith(
      hasMinLength: password.length >= 8,
      hasNumber: _numberRegExp.hasMatch(password),
      hasSymbol: _symbolRegExp.hasMatch(password),
      passwordsMatch:
      password.isNotEmpty && password == confirm,
    );
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value.length < 8) {
      return AppStrings.reqMinLength;
    }

    return null;
  }

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value != passwordController.text) {
      return AppStrings.reqMatch;
    }

    return null;
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void submit(
      ValueChanged<String> onSubmit,
      ) {
    if (!validate()) {
      return;
    }

    onSubmit(
      passwordController.text,
    );
  }
}

final resetPasswordControllerProvider =
NotifierProvider.autoDispose<
    ResetPasswordController,
    ResetPasswordState>(
  ResetPasswordController.new,
);