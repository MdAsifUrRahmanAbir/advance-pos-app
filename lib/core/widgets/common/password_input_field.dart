import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'primary_input_field.dart';

/// Password field with a built-in show/hide (eye icon) toggle.
/// Drop-in replacement for [PrimaryInputField] on any password input
/// (login, register, change password...).
class PasswordInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PasswordInputField({
    super.key,
    this.label = 'Password',
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return PrimaryInputField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _obscure,
      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: AppSizes.iconSm),
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: AppSizes.iconSm,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
