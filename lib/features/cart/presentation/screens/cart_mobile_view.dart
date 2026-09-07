import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/cart_top_bar.dart';
import '../widgets/customer_selector_row.dart';
import '../widgets/remarks_reference_row.dart';
import '../widgets/cart_summary_section.dart';

class CartMobileView extends ConsumerWidget {
  const CartMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Column(
      children: [
        CartTopBar(
          onBack: () => context.pop(),
          onClearAll: () => ref.read(cartControllerProvider.notifier).clearAll(),
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
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
                    // the payment cart-handoff (payable amount, saleId) is
                    // passed through — see payment/presentation/controllers.
                    context.push(RouteNames.payment);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}