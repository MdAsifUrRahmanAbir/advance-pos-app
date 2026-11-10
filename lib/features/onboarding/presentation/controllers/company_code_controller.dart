import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/client_profile.dart';
import '../../../../core/session/client_session_controller.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/client_repository.dart';
import '../states/company_code_state.dart';

final companyCodeControllerProvider =
NotifierProvider.autoDispose<CompanyCodeController, CompanyCodeState>(
  CompanyCodeController.new,
);

/// Welcome screen: verifies the company code and, on success, binds the
/// device to that company (name, logo, API base URL, client token).
class CompanyCodeController extends Notifier<CompanyCodeState> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController codeController;

  ClientRepository get _repository => ref.read(clientRepositoryProvider);

  @override
  CompanyCodeState build() {
    codeController = TextEditingController();
    ref.onDispose(codeController.dispose);
    return const CompanyCodeState();
  }

  String? validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.companyCodeRequired;
    }
    return null;
  }

  /// Clears a shown server error once the user edits the code.
  void onCodeChanged(String _) {
    if (state.errorMessage != null) state = state.copyWith(clearError: true);
  }

  /// True when the company was verified and saved.
  Future<bool> verify() async {
    if (state.isVerifying) return false;
    if (!(formKey.currentState?.validate() ?? false)) return false;

    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      final response = await _repository.getClientInfo(
        codeController.text.trim(),
      );
      if (!ref.mounted) return false;

      final data = response.data;
      // Without a client token no one could sign in to this company.
      final verified = response.status.toLowerCase() == 'success' &&
          data != null &&
          data.baseUrl.isNotEmpty &&
          data.clientToken.isNotEmpty;
      if (!verified) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : AppStrings.companyCodeInvalid,
        );
        return false;
      }

      await ref.read(clientSessionControllerProvider.notifier).save(
        ClientProfile(
          name: data.name,
          compCode: data.compCode,
          logo: data.logo,
          product: data.product,
          baseUrl: data.baseUrl,
        ),
        clientToken: data.clientToken,
      );
      if (!ref.mounted) return true;
      state = state.copyWith(isVerifying: false);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isVerifying: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}