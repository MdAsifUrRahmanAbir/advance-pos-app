import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/password_input_field.dart';
import '../../../../core/widgets/common/primary_checkbox.dart';
import '../../../../core/widgets/common/link_button.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Username + password fields, "Remember me" / "Forgot password?" row,
/// and the Sign In button. Pure UI: all state and actions come in.
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? Function(String?) usernameValidator;
  final String? Function(String?) passwordValidator;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onForgotPassword;
  final bool loading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.usernameValidator,
    required this.passwordValidator,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onSubmit,
    this.onForgotPassword,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryInputField(
            label: AppStrings.loginUsernameLabel,
            hint: AppStrings.loginUsernameHint,
            controller: usernameController,
            keyboardType: TextInputType.text,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            validator: usernameValidator,
          ),
          const SizedBox(height: AppSizes.md),
          PasswordInputField(
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            controller: passwordController,
            validator: passwordValidator,
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Expanded(
                child: PrimaryCheckbox(
                  value: rememberMe,
                  label: AppStrings.rememberMe,
                  onChanged: (value) => onRememberMeChanged(value ?? false),
                ),
              ),
              // Hidden when no handler is given (Forgot Password not offered yet).
              if (onForgotPassword != null)
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
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}