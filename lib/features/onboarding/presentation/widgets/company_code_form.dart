import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/primary_input_field.dart';

/// Company code field + "Verify Company" button on the welcome screen.
/// A server error (invalid code, network) shows under the field.
class CompanyCodeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final VoidCallback onVerify;
  final bool isVerifying;
  final String? errorMessage;

  const CompanyCodeForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.onVerify,
    this.isVerifying = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryInputField(
            label: AppStrings.companyCodeLabel,
            hint: AppStrings.companyCodeHint,
            controller: controller,
            validator: validator,
            onChanged: onChanged,
            enabled: !isVerifying,
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSizes.xs),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.lg),
          PrimaryButton(
            label: AppStrings.companyVerifyAction,
            icon: Icons.verified_outlined,
            loading: isVerifying,
            onPressed: onVerify,
          ),
        ],
      ),
    );
  }
}