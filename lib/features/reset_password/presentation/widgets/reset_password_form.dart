import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/password_input_field.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/utility/password_requirement_item.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordForm extends ConsumerWidget {
  final bool loading;
  final ValueChanged<String> onSubmit;

  const ResetPasswordForm({
    super.key,
    required this.onSubmit,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      resetPasswordControllerProvider.notifier,
    );

    final state = ref.watch(
      resetPasswordControllerProvider,
    );

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordInputField(
            label: AppStrings.newPassword,
            controller: controller.passwordController,
            validator: controller.validatePassword,
            onChanged:
            controller.onPasswordChanged,
          ),

          const SizedBox(
            height: AppSizes.lg,
          ),

          PasswordInputField(
            label: AppStrings.confirmPassword,
            controller: controller.confirmController,
            validator: controller.validateConfirm,
            onChanged:
            controller.onConfirmPasswordChanged,
          ),

          const SizedBox(
            height: AppSizes.xs,
          ),

          PasswordRequirementItem(
            label: AppStrings.reqMinLength,
            met: state.hasMinLength,
          ),

          PasswordRequirementItem(
            label: AppStrings.reqNumber,
            met: state.hasNumber,
          ),

          PasswordRequirementItem(
            label: AppStrings.reqSymbol,
            met: state.hasSymbol,
          ),

          PasswordRequirementItem(
            label: AppStrings.reqMatch,
            met: state.passwordsMatch,
          ),

          const SizedBox(
            height: AppSizes.md,
          ),

          PrimaryButton(
            label: AppStrings.updatePassword,
            loading: loading,
            onPressed: () {
              controller.submit(onSubmit);
            },
          ),
        ],
      ),
    );
  }
}