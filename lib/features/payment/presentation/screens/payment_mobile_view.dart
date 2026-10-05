import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/nav_extension.dart';
import '../../../../routes/route_names.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../controllers/payment_controller.dart';
import '../widgets/change_due_banner.dart';
import '../widgets/complete_sale_button.dart';
import '../widgets/payable_amount_card.dart';
import '../widgets/payment_entry_card.dart';
import '../widgets/payment_success_sheet.dart';
import '../widgets/payment_system_selector.dart';
import '../widgets/payment_top_bar.dart';
import '../widgets/printer_selection_sheet.dart';
import '../states/payment_systems_from_accounts.dart';


class PaymentMobileView extends ConsumerWidget {
  const PaymentMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentControllerProvider);
    final controller = ref.read(paymentControllerProvider.notifier);
    final masterData = ref.watch(masterDataControllerProvider);

    final systems = paymentSystemsFrom(masterData.paymentAccounts);

    final isLoadingMethods = masterData.isLoading && systems.isEmpty;
    final hasMethodsError = masterData.errorMessage != null && systems.isEmpty;

    return Column(
      children: [
        PaymentTopBar(onBack: () => context.pop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              PayableAmountCard(
                amount: state.payableAmount,
                saleDate: state.saleDate,
              ),
              const SizedBox(height: AppSizes.lg),
              _SectionLabel(text: 'PAYMENT METHOD'),
              const SizedBox(height: AppSizes.xs),
              Text(
                AppStrings.selectPaymentMethodsHint,
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: context.appColors.textHint,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              if (isLoadingMethods)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                  child: CustomLoader(),
                )
              else if (hasMethodsError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.paymentMethodsLoadError,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      TextButton(
                        onPressed: ref
                            .read(masterDataControllerProvider.notifier)
                            .refresh,
                        child: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                )
              else
                PaymentSystemSelector(
                  systems: systems,
                  selectedEntries: state.selectedEntries,
                  onToggle: controller.toggleSystem,
                ),
              if (state.selectedEntries.isNotEmpty) ...[
                const SizedBox(height: AppSizes.md),
                for (final entry in state.selectedEntries) ...[
                  PaymentEntryCard(
                    key: ValueKey(entry.system.id), // <-- add this
                    entry: entry,
                    accountsForThisSystem: controller.accountsForSystem(
                      entry.system,
                    ),
                    amountLocked: state.lockSingleNonCashAmount,
                    onAccountChanged: (account) => controller
                        .selectAccountForSystem(entry.system.id, account),
                    onAmountChanged: (amount) => controller
                        .updateAmountForSystem(entry.system.id, amount),
                    onRemove: () => controller.toggleSystem(entry.system),
                  ),
                  const SizedBox(height: AppSizes.sm + AppSizes.xs),
                ],
                if (state.changeDue != 0)
                  ChangeDueBanner(amount: state.changeDue),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.sm),
                  child: Text(
                    AppStrings.selectPaymentMethodToContinue,
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      color: context.appColors.textHint,
                    ),
                  ),
                ),

              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
        BottomActionBar(
          child: CompleteSaleButton(
            isEnabled: state.canComplete,
            isLoading: state.isProcessing,
            onPressed: () async {
              final success = await controller.completeSale();
              if (!context.mounted) return;
              if (success) {
                _showPaymentSuccessSheet(context, ref);
              } else {
                final error = ref.read(paymentControllerProvider).errorMessage;
                if (error != null) {
                  CustomSnackbar.show(context, error, error: true);
                }
              }
            },
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
            final controller = sheetRef.read(
              paymentControllerProvider.notifier,
            );

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
                final success = await controller.shareReceipt(
                  receiptBoundaryKey,
                );
                if (!success && consumerContext.mounted) {
                  ScaffoldMessenger.of(consumerContext).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.shareFailedMessage),
                    ),
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
                      content: Text(
                        success
                            ? AppStrings.printSuccessMessage
                            : AppStrings.printFailedMessage,
                      ),
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
      style: TextStyle(
        color: context.appColors.textSecondary,
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}
