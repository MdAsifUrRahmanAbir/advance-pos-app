import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../payment/presentation/states/payment_systems_from_accounts.dart';
import '../../../payment/presentation/widgets/payable_amount_card.dart';
import '../controllers/edit_sale_payment_controller.dart';
import '../widgets/edit_sale_amount_comparison.dart';
import '../widgets/edit_sale_payment_methods_section.dart';
import '../widgets/edit_sale_payment_top_bar.dart';
import 'edit_sale_payment_view_actions.dart';

class EditSalePaymentMobileView extends ConsumerStatefulWidget {
  final String billNo;

  const EditSalePaymentMobileView({super.key, required this.billNo});

  @override
  ConsumerState<EditSalePaymentMobileView> createState() => _EditSalePaymentMobileViewState();
}

class _EditSalePaymentMobileViewState extends ConsumerState<EditSalePaymentMobileView>
    with EditSalePaymentViewActions<EditSalePaymentMobileView> {
  @override
  String get billNo => widget.billNo;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editSalePaymentControllerProvider(billNo));
    final controller = paymentController;
    final masterData = ref.watch(masterDataControllerProvider);
    final systems = paymentSystemsFrom(masterData.paymentAccounts);

    return Column(
      children: [
        EditSalePaymentTopBar(billNo: billNo, onBack: goBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              PayableAmountCard(amount: state.payableAmount, saleDate: state.saleDate),
              const SizedBox(height: AppSizes.sm),
              EditSaleAmountComparison(
                originalPayable: state.originalPayable,
                originalPaid: state.originalPaid,
                newPayable: state.payableAmount,
              ),
              const SizedBox(height: AppSizes.lg),
              EditSalePaymentMethodsSection(
                state: state,
                systems: systems,
                isLoadingMethods: masterData.isLoading && systems.isEmpty,
                hasMethodsError: masterData.errorMessage != null && systems.isEmpty,
                onRetryMethods: ref.read(masterDataControllerProvider.notifier).refresh,
                accountsFor: controller.accountsForSystem,
                onToggle: controller.toggleSystem,
                onAccountChanged: controller.selectAccountForSystem,
                onAmountChanged: controller.updateAmountForSystem,
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
        BottomActionBar(
          child: PrimaryButton(
            label: AppStrings.editSaleUpdateAction,
            icon: Icons.check_rounded,
            loading: state.isUpdating,
            backgroundColor: AppColors.success,
            onPressed: state.canSubmit ? submitUpdate : null,
          ),
        ),
      ],
    );
  }
}