import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/api_params.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/session_profile.dart';
import '../../../../core/storage/secure_storage_service.dart';
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
  SecureStorageService get _storage => ref.read(secureStorageServiceProvider);

  @override
  LoginState build() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    ref.onDispose(() {
      usernameController.dispose();
      passwordController.dispose();
    });

    Future.microtask(_restoreRememberedUsername);
    return const LoginState();
  }

  /// "Remember me" from the last sign-in: prefill the username and keep
  /// the box ticked. Best-effort — a storage error just leaves the form
  /// empty.
  Future<void> _restoreRememberedUsername() async {
    String? saved;
    try {
      saved = await _storage.readRememberedUsername();
    } catch (_) {
      return;
    }
    if (!ref.mounted || saved == null || saved.isEmpty) return;
    // Never overwrite something the user already started typing.
    if (usernameController.text.isEmpty) usernameController.text = saved;
    state = state.copyWith(rememberMe: true);
  }

  /// Saves the username when Remember me is ticked, forgets it when not.
  /// Best-effort: a storage error must not fail a sign-in that succeeded.
  Future<void> _applyRememberedUsername(String username) async {
    try {
      if (state.rememberMe) {
        await _storage.saveRememberedUsername(username);
      } else {
        await _storage.clearRememberedUsername();
      }
    } catch (_) {
      // Remembering the username is a convenience; ignore storage failures.
    }
  }

  /// The verified company's client token, or null when it is missing
  /// (company verified before tokens existed) or unreadable.
  Future<String?> _readClientToken() async {
    try {
      final token = await _storage.readClientToken();
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      return null;
    }
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
    final username = usernameController.text.trim();

    final clientToken = await _readClientToken();
    if (!ref.mounted) return false;
    if (clientToken == null) {
      // Fixed by "Switch company" → verifying the code again.
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AppStrings.loginClientTokenMissing,
      );
      return false;
    }

    try {
      final result = await _repository.loginWithClientToken(
        username: username,
        password: passwordController.text,
        clientToken: clientToken,
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

      // Only a successful sign-in updates what is remembered.
      await _applyRememberedUsername(username);
      if (!ref.mounted) return false;

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
        // Unticked: signed in until the app is closed, then Login again.
        rememberSession: state.rememberMe,
        profile: SessionProfile(
          sellerType: _unknownSellerType,
          userName: config.fullName,
          userId: config.userId,
          companyId: config.companyId,
          companyType: config.companyType,
          historyId: data.historysId,
          employeeId: config.empId,
          employeeNo: config.employeeNo,
          branchName: config.branchName,
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