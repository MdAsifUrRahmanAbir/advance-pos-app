import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/password_input_field.dart';
import '../../../../core/widgets/common/primary_checkbox.dart';
import '../../../../core/widgets/common/link_button.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../controllers/login_controller.dart';

/// Email + password fields, "Remember me" / "Forgot password?" row, and
/// the Sign In button.
class LoginForm extends ConsumerWidget {
  final bool loading;
  final void Function(String email, String password, bool rememberMe) onSignIn;
  final VoidCallback? onForgotPassword;

  const LoginForm({
    super.key,
    required this.onSignIn,
    this.onForgotPassword,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(loginFormControllerProvider.notifier);
    final state = ref.watch(loginFormControllerProvider);

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryInputField(
            label: AppStrings.emailAddress,
            hint: AppStrings.emailHint,
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.mail_outline_rounded),
            validator: controller.validateEmail,
          ),
          const SizedBox(height: AppSizes.md),
          PasswordInputField(
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            controller: controller.passwordController,
            validator: controller.validatePassword,
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Expanded(
                child: PrimaryCheckbox(
                  value: state.rememberMe,
                  label: AppStrings.rememberMe,
                  onChanged: (value) => controller.setRememberMe(value ?? false),
                ),
              ),
              LinkButton(
                label: AppStrings.forgotPassword,
                fontSize: AppSizes.fontSm,
                onPressed: onForgotPassword,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          PrimaryButton(
            label: AppStrings.signIn,
            loading: loading,
            onPressed: () => controller.submit(onSignIn),
          ),
        ],
      ),
    );
  }
}
