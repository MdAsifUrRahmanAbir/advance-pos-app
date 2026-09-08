import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/nav_extension.dart';
import '../../../../routes/route_names.dart';
import '../controllers/payment_controller.dart';
import '../widgets/payable_amount_card.dart';
import '../widgets/payment_method_grid.dart';
import '../widgets/given_amount_field.dart';
import '../widgets/change_due_banner.dart';
import '../widgets/payment_success_sheet.dart';
import '../widgets/payment_top_bar.dart';
import '../widgets/printer_selection_sheet.dart';
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
                    _showPaymentSuccessSheet(context, ref);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _showPaymentSuccessSheet(BuildContext context, WidgetRef ref) {
    final receiptBoundaryKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        return Consumer(
          builder: (consumerContext, sheetRef, _) {
            final state = sheetRef.watch(paymentControllerProvider);
            final controller = sheetRef.read(paymentControllerProvider.notifier);

            return PaymentSuccessSheet(
              paymentState: state,
              receiptBoundaryKey: receiptBoundaryKey,
              isSharing: state.isSharing,
              isPrinting: state.isPrinting,
              onNewSale: () {
                Navigator.of(sheetContext).pop();
                context.restartFlowFrom(RouteNames.newSale);
              },
              onGoToDashboard: () {
                Navigator.of(sheetContext).pop();
                context.go(RouteNames.mainShell);
              },
              onShareReceipt: () async {
                final success = await controller.shareReceipt(receiptBoundaryKey);
                if (!success && consumerContext.mounted) {
                  ScaffoldMessenger.of(consumerContext).showSnackBar(
                    const SnackBar(content: Text(AppStrings.shareFailedMessage)),
                  );
                }
              },
              onPrintReceipt: () async {
                final device = await showModalBottomSheet(
                  context: consumerContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const PrinterSelectionSheet(),
                );
                if (device == null) return;

                final success = await controller.printReceipt(device.macAdress);
                if (consumerContext.mounted) {
                  ScaffoldMessenger.of(consumerContext).showSnackBar(
                    SnackBar(
                      content: Text(success ? AppStrings.printSuccessMessage : AppStrings.printFailedMessage),
                    ),
                  );
                }
              },
            );
          },
        );
      },
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