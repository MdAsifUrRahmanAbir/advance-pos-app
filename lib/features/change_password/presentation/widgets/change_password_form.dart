import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/password_input_field.dart';
import '../../../../core/widgets/common/password_strength_meter.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordForm extends ConsumerWidget {
  final bool loading;

  final void Function(
      String currentPassword,
      String newPassword,
      ) onSave;

  const ChangePasswordForm({
    super.key,
    required this.onSave,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      changePasswordControllerProvider.notifier,
    );

    final state = ref.watch(
      changePasswordControllerProvider,
    );

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordInputField(
            label: AppStrings.currentPassword,
            controller:
            controller.currentPasswordController,
            validator:
            controller.validateCurrentPassword,
          ),

          const SizedBox(
            height: AppSizes.lg,
          ),

          PasswordInputField(
            label: AppStrings.newPassword,
            controller:
            controller.newPasswordController,
            validator:
            controller.validateNewPassword,
            onChanged:
            controller.onNewPasswordChanged,
          ),

          const SizedBox(
            height: AppSizes.lg,
          ),

          PasswordInputField(
            label: AppStrings.confirmPassword,
            controller:
            controller.confirmPasswordController,
            validator:
            controller.validateConfirmPassword,
          ),

          const SizedBox(
            height: AppSizes.xs,
          ),

          PasswordStrengthMeter(
            strength: state.passwordStrength,
          ),

          const SizedBox(
            height: AppSizes.lg,
          ),

          PrimaryButton(
            label: AppStrings.saveChanges,
            loading: loading,
            onPressed: () {
              controller.submit(onSave);
            },
          ),
        ],
      ),
    );
  }
}