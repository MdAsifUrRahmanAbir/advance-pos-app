import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../controllers/edit_sale_cart_controller.dart';

/// Add-customer form for Edit Sale (POST /customer/add). On success the
/// new customer is already selected on the edited invoice and the sheet
/// pops with them; on failure it stays open with an inline error.
class EditSaleAddCustomerSheet extends ConsumerStatefulWidget {
  final String billNo;

  const EditSaleAddCustomerSheet({super.key, required this.billNo});

  @override
  ConsumerState<EditSaleAddCustomerSheet> createState() => _EditSaleAddCustomerSheetState();
}

class _EditSaleAddCustomerSheetState extends ConsumerState<EditSaleAddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final created = await ref
        .read(editSaleCartControllerProvider(widget.billNo).notifier)
        .createAndSelectCustomer(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cart = ref.watch(editSaleCartControllerProvider(widget.billNo)).cart;
    final busy = cart.isAddingCustomer;

    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.addCustomerTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: busy ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                if (cart.addCustomerErrorMessage != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    cart.addCustomerErrorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: AppSizes.fontSm),
                  ),
                ],
                const SizedBox(height: AppSizes.md),
                PrimaryInputField(
                  label: AppStrings.customerNameLabel,
                  hint: AppStrings.customerNameHint,
                  controller: _nameController,
                  enabled: !busy,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.customerNameRequiredError
                      : null,
                ),
                const SizedBox(height: AppSizes.md),
                PrimaryInputField(
                  label: AppStrings.customerNumberLabel,
                  hint: AppStrings.customerNumberHint,
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  enabled: !busy,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.customerNumberRequiredError
                      : null,
                ),
                const SizedBox(height: AppSizes.md),
                PrimaryInputField(
                  label: AppStrings.customerEmailLabel,
                  hint: AppStrings.customerEmailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !busy,
                ),
                const SizedBox(height: AppSizes.md),
                PrimaryInputField(
                  label: AppStrings.customerAddressLabel,
                  hint: AppStrings.customerAddressHint,
                  controller: _addressController,
                  maxLines: 2,
                  enabled: !busy,
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(
                  label: AppStrings.addCustomerAction,
                  loading: busy,
                  onPressed: busy ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}