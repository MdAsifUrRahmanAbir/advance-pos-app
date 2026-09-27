import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../../data/models/customers_model.dart';
import '../controllers/cart_controller.dart';
import '../widgets/add_customer_sheet.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/cart_top_bar.dart';
import '../widgets/customer_selector_row.dart';
import '../widgets/remarks_reference_row.dart';
import '../widgets/cart_summary_section.dart';

class CartTabView extends ConsumerWidget {
  const CartTabView({super.key});

  Future<void> _openAddCustomer(BuildContext context) async {
    final created = await showModalBottomSheet<ResultDatum>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCustomerSheet(),
    );
    if (created != null && context.mounted) {
      CustomSnackbar.show(context, AppStrings.customerAddedSuccessMessage(created.customerName));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Column(
      children: [
        CartTopBar(
          onBack: () => context.pop(),
          onClearAll: controller.clearAll,
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  children: [
                    CartItemList(
                      items: state.items,
                      onIncrement: controller.incrementQuantity,
                      onDecrement: controller.decrementQuantity,
                      onDelete: controller.removeItem,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomerSelectorRow(
                      selectedCustomer: state.selectedCustomer,
                      onChanged: controller.selectCustomer,
                      onAddCustomer: () => _openAddCustomer(context),
                    ),
                    const SizedBox(height: AppSizes.md),
                    RemarksReferenceRow(
                      onRemarksChanged: controller.updateRemarks,
                      onReferenceChanged: controller.updateReferenceNo,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CartSummarySection(
                      state: state,
                      onProceedToPayment: () => context.push(RouteNames.payment),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}