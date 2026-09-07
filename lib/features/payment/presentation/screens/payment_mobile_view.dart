import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../controllers/payment_controller.dart';
import '../widgets/payable_amount_card.dart';
import '../widgets/payment_method_grid.dart';
import '../widgets/given_amount_field.dart';
import '../widgets/change_due_banner.dart';
import '../widgets/payment_top_bar.dart';
import '../widgets/sales_agent_selector.dart';
import '../widgets/complete_sale_button.dart';

class PaymentMobileView extends ConsumerWidget {
  const PaymentMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentControllerProvider);
    final controller = ref.read(paymentControllerProvider.notifier);

    return Column(
      children: [
        PaymentTopBar(onBack: () => context.pop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              PayableAmountCard(
                amount: state.payableAmount,
                saleId: state.saleId,
                saleDate: state.saleDate,
              ),
              const SizedBox(height: AppSizes.md),
              const _SectionLabel(text: 'SELECT PAYMENT METHOD'),
              const SizedBox(height: AppSizes.sm),
              PaymentMethodGrid(
                selected: state.selectedMethod,
                onSelected: controller.selectMethod,
              ),
              const SizedBox(height: AppSizes.md),
              GivenAmountField(
                amount: state.givenAmount,
                onChanged: controller.updateGivenAmount,
                onOpenKeypad: () {
                  // TODO: wire to a numeric keypad bottom sheet once
                  // CustomBottomSheet's calculator-pad variant is available.
                },
              ),
              const SizedBox(height: AppSizes.md),
              ChangeDueBanner(amount: state.changeDue),
              const SizedBox(height: AppSizes.md),
              SalesAgentSelector(
                selectedAgent: state.salesAgent,
                agents: state.availableAgents,
                onChanged: controller.selectAgent,
              ),
              const SizedBox(height: AppSizes.md),
              CompleteSaleButton(
                isEnabled: state.canComplete,
                isLoading: state.isProcessing,
                onPressed: () async {
                  final success = await controller.completeSale();
                  if (success && context.mounted) {
                    // TODO: navigate to sale-confirmation / receipt screen
                    // once RouteNames.saleConfirmation exists.

                    context.go(RouteNames.mainShell);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}