import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/password_input_field.dart';
import '../../../../core/widgets/common/password_strength_meter.dart';
import '../../../../core/widgets/common/primary_checkbox.dart';
import '../../../../core/widgets/common/link_button.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../controllers/register_controller.dart';

class RegisterForm extends ConsumerWidget {
  final bool loading;
  final void Function(
      String fullName,
      String email,
      String password,
      ) onRegister;
  final VoidCallback? onTermsTap;

  const RegisterForm({
    super.key,
    required this.onRegister,
    this.onTermsTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      registerControllerProvider.notifier,
    );

    final state = ref.watch(
      registerControllerProvider,
    );

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryInputField(
            label: AppStrings.fullName,
            hint: AppStrings.fullNameHint,
            controller: controller.nameController,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
            ),
            validator: controller.validateName,
          ),

          const SizedBox(height: AppSizes.md),

          PrimaryInputField(
            label: AppStrings.emailAddress,
            hint: AppStrings.registerEmailHint,
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
            ),
            validator: controller.validateEmail,
          ),

          const SizedBox(height: AppSizes.md),

          PasswordInputField(
            label: AppStrings.password,
            hint: AppStrings.registerPasswordHint,
            controller: controller.passwordController,
            validator: controller.validatePassword,
            onChanged: (_) {
              ref.invalidate(registerControllerProvider);
            },
          ),

          const SizedBox(height: AppSizes.sm),

          PasswordStrengthMeter(
            strength: controller.passwordStrength(),
          ),

          const SizedBox(height: AppSizes.md),

          PasswordInputField(
            label: AppStrings.confirmPassword,
            hint: AppStrings.registerPasswordHint,
            controller: controller.confirmPasswordController,
            validator: controller.validateConfirmPassword,
          ),

          const SizedBox(height: AppSizes.sm),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PrimaryCheckbox(
                value: state.agreedToTerms,
                onChanged: (value) {
                  controller.setAgreedToTerms(
                    value ?? false,
                  );
                },
              ),

               Text(
                AppStrings.agreeToTermsPrefix,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: context.appColors.textPrimary,
                ),
              ),

              LinkButton(
                label: AppStrings.termsAndConditions,
                fontSize: AppSizes.fontSm,
                onPressed: onTermsTap,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.sm),

          PrimaryButton(
            label: AppStrings.createAccount,
            loading: loading,
            onPressed: () {
              if (!state.agreedToTerms) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      AppStrings.mustAgreeToTerms,
                    ),
                  ),
                );
                return;
              }

              controller.submit(onRegister);
            },
          ),
        ],
      ),
    );
  }
}