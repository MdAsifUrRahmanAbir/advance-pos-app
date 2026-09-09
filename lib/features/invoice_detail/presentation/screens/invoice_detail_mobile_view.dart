import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../controllers/invoice_detail_controller.dart';
import '../states/invoice_detail_state.dart';
import '../widgets/invoice_activity_log_card.dart';
import '../widgets/invoice_detail_actions.dart';
import '../widgets/invoice_info_card.dart';
import '../widgets/invoice_products_card.dart';

class InvoiceDetailMobileView extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailMobileView({super.key, required this.invoiceId});

  Future<void> _handlePayDues(BuildContext context, WidgetRef ref, double amountDue, String invoiceNumber) async {
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.invoicePayDuesAction,
      message: 'Record full payment of ${CurrencyFormatter.format(amountDue, symbol: '৳')} for $invoiceNumber?',
      confirmText: AppStrings.invoicePayDuesAction,
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(invoiceDetailControllerProvider.notifier).payDues();
    if (!context.mounted) return;
    CustomSnackbar.show(context, success ? 'Payment recorded for $invoiceNumber' : 'Could not record payment');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safe to call every build — the controller only fetches once per id.
    ref.read(invoiceDetailControllerProvider.notifier).loadInvoice(invoiceId);
    final state = ref.watch(invoiceDetailControllerProvider);

    return Column(
      children: [
        CustomAppBar(title: AppStrings.invoiceDetailTitle, onBackTap: () => context.pop()),
        Expanded(
          child: switch (state) {
            InvoiceDetailState(isLoading: true, invoice: null) => const CustomLoader(),
            InvoiceDetailState(errorMessage: final err?, invoice: null) => ErrorState(
              message: err,
              onRetry: () => ref.read(invoiceDetailControllerProvider.notifier).loadInvoice(invoiceId),
            ),
            InvoiceDetailState(invoice: final invoice?) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceInfoCard(invoice: invoice),
                  const SizedBox(height: AppSizes.md),
                  InvoiceProductsCard(invoice: invoice),
                  const SizedBox(height: AppSizes.md),
                  InvoiceActivityLogCard(entries: invoice.activityLog),
                ],
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
        if (state.invoice != null)
          InvoiceDetailActions(
            invoice: state.invoice!,
            onPayDues: () => _handlePayDues(context, ref, state.invoice!.amountDue, state.invoice!.invoiceNumber),
          ),
      ],
    );
  }
}