import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../data/models/customers_model.dart';
import '../controllers/cart_controller.dart';

/// Add-customer form, shown as a modal bottom sheet from
/// [CustomerSelectorRow]'s "+" button. Submits POST /customer/add via
/// [CartController.createAndSelectCustomer]; pops with the created
/// [ResultDatum] on success (already selected as the cart's customer by
/// the controller) or stays open showing an inline error on failure.
///
/// ⚠️ Composed manually (same caveat as [RemarksReferenceRow]) pending
/// PrimaryInputField's exact constructor.
class AddCustomerSheet extends ConsumerStatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  ConsumerState<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends ConsumerState<AddCustomerSheet> {
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final created = await ref.read(cartControllerProvider.notifier).createAndSelectCustomer(
      name: _nameController.text.trim(),
      mobile: _numberController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (created != null && mounted) {
      Navigator.of(context).pop(created);
    }
    // On failure the sheet stays open — the error banner below re-renders
    // from `state.addCustomerErrorMessage` via ref.watch.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);

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
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: state.isAddingCustomer ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                if (state.addCustomerErrorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      state.addCustomerErrorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: AppSizes.fontSm),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                _FormField(
                  label: AppStrings.customerNameLabel,
                  hint: AppStrings.customerNameHint,
                  controller: _nameController,
                  enabled: !state.isAddingCustomer,
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.customerNameRequiredError : null,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerNumberLabel,
                  hint: AppStrings.customerNumberHint,
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  enabled: !state.isAddingCustomer,
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.customerNumberRequiredError : null,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerEmailLabel,
                  hint: AppStrings.customerEmailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !state.isAddingCustomer,
                ),
                const SizedBox(height: AppSizes.md),
                _FormField(
                  label: AppStrings.customerAddressLabel,
                  hint: AppStrings.customerAddressHint,
                  controller: _addressController,
                  maxLines: 2,
                  enabled: !state.isAddingCustomer,
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(
                  label: AppStrings.addCustomerAction,
                  loading: state.isAddingCustomer,
                  onPressed: state.isAddingCustomer ? null : _submit,
                ),
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
  final bool enabled;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
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
            enabled: enabled,
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