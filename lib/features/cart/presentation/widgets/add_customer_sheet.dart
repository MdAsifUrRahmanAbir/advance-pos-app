import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Plain data returned to the caller — not a real server customer record
/// since no create-customer endpoint exists yet to assign an id.
class NewCustomerDraft {
  final String name;
  final String mobile;
  final String email;
  final String address;

  const NewCustomerDraft({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
  });
}

/// Minimal add-customer form, shown as a modal bottom sheet from
/// [CustomerSelectorRow]'s "+" button.
/// ⚠️ Composed manually (same caveat as [RemarksReferenceRow]) pending
/// PrimaryInputField's exact constructor.
/// TODO: wire to cartRepositoryProvider.createCustomer(...) once that
/// endpoint exists — then select the newly created customer for real
/// (with its server id) instead of returning a local draft.
class AddCustomerSheet extends StatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      NewCustomerDraft(
        name: _nameController.text.trim(),
        mobile: _numberController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLg),
          topRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.addCustomerTitle,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                _FormField(
                  label: AppStrings.customerNameLabel,
                  hint: AppStrings.customerNameHint,
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.customerNameRequiredError : null,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerNumberLabel,
                  hint: AppStrings.customerNumberHint,
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.customerNumberRequiredError : null,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerEmailLabel,
                  hint: AppStrings.customerEmailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerAddressLabel,
                  hint: AppStrings.customerAddressHint,
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(label: AppStrings.addCustomerAction, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs, fontWeight: FontWeight.w700, letterSpacing: 0.4),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 4, vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontSm),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
            ),
          ),
        ),
      ],
    );
  }
}