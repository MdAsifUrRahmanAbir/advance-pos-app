import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Email field + Send Reset Link button.
///
/// Purely presentational — owns only local UI state (controller,
/// validation). The actual reset-link request is supplied by the
/// caller via [onSend], so this widget doesn't reach into
/// data/repositories.
class ForgotPasswordForm extends StatefulWidget {
  final bool loading;
  final ValueChanged<String> onSend;

  const ForgotPasswordForm({
    super.key,
    required this.onSend,
    this.loading = false,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emailRequired;
    if (!value.contains('@')) return AppStrings.emailInvalid;
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSend(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryInputField(
            label: AppStrings.emailAddress,
            hint: AppStrings.registerEmailHint,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.mail_outline_rounded),
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: AppStrings.sendResetLink,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}