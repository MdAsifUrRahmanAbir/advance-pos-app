import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/api_params.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/session_profile.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/login_repository.dart';
import '../states/login_state.dart';

class LoginController extends Notifier<LoginState> {
  /// FLAG: login response has no seller type yet.
  static const String _unknownSellerType = '';

  final formKey = GlobalKey<FormState>();

  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  LoginRepository get _repository => ref.read(loginRepositoryProvider);

  @override
  LoginState build() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    ref.onDispose(() {
      usernameController.dispose();
      passwordController.dispose();
    });

    return const LoginState();
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.loginUsernameRequired;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    return null;
  }

  /// Signs in and saves the session. True when the user is signed in;
  /// on false, [LoginState.errorMessage] holds the reason (null when the
  /// form itself was invalid).
  Future<bool> submit() async {
    if (state.isSubmitting) return false;
    state = state.copyWith(clearError: true);
    if (!(formKey.currentState?.validate() ?? false)) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repository.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      if (!ref.mounted) return false;

      final data = result.data;
      if (!result.success || data == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result.message ?? AppStrings.loginFailed,
        );
        return false;
      }

      final config = data.userConfig;

      // Cache branch_id / employee_id / sales_type for every API call.
      // Done before the session turns authenticated so the params exist
      // as soon as any screen can make a request.
      await ref.read(apiParamsControllerProvider.notifier).cacheFromLogin(
        branchId: config.branchId,
        employeeId: config.empId,
      );
      if (!ref.mounted) return false;

      await ref.read(authSessionControllerProvider.notifier).onLoginSuccess(
        profile: SessionProfile(
          sellerType: _unknownSellerType,
          userName: config.fullName,
          userId: config.userId,
          companyId: config.companyId,
          companyType: config.companyType,
          historyId: data.historysId,
          employeeId: config.empId,
          employeeNo: config.employeeNo,
        ),
      );
      if (!ref.mounted) return true;

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}

final loginFormControllerProvider =
NotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);