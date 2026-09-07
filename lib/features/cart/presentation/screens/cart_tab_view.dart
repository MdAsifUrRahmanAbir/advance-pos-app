import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/customer_selector_row.dart';
import '../widgets/remarks_reference_row.dart';
import '../widgets/cart_summary_section.dart';

class CartTabView extends ConsumerWidget {
  const CartTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Container(
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
                selectedCustomer: state.customerName,
                customers: const ['Walk-In Customer', 'Rahul Sharma', 'Amit Patel'],
                onChanged: controller.updateCustomer,
                onAddCustomer: () {
                  // TODO: wire to context.push(RouteNames.addCustomer) once
                  // the add-customer route/screen exists.
                },
              ),
              const SizedBox(height: AppSizes.md),
              RemarksReferenceRow(
                onRemarksChanged: controller.updateRemarks,
                onReferenceChanged: controller.updateReferenceNo,
              ),
              const SizedBox(height: AppSizes.md),
              CartSummarySection(
                state: state,
                onProceedToPayment: () {
                  // TODO: wire to context.push(RouteNames.payment) once
                  // the payment cart-handoff is passed through.
                  context.push('/payment');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}