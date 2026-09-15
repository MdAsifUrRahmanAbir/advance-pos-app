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
import '../../data/models/sale_amounts.dart';
import '../controllers/invoice_detail_controller.dart';
import '../widgets/invoice_detail_actions.dart';
import '../widgets/invoice_info_card.dart';
import '../widgets/invoice_products_card.dart';

class InvoiceDetailMobileView extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailMobileView({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailMobileView> createState() =>
      _InvoiceDetailMobileViewState();
}

class _InvoiceDetailMobileViewState
    extends ConsumerState<InvoiceDetailMobileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(invoiceDetailControllerProvider.notifier)
          .loadInvoice(widget.invoiceId),
    );
  }

  Future<void> _handlePayDues(double amountDue, String invoiceNumber) async {
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.invoicePayDuesAction,
      message:
          'Record full payment of ${CurrencyFormatter.format(amountDue, symbol: '৳')} for $invoiceNumber?',
      confirmText: AppStrings.invoicePayDuesAction,
    );
    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(invoiceDetailControllerProvider.notifier)
        .payDues();
    if (!mounted) return;
    CustomSnackbar.show(
      context,
      success
          ? 'Payment recorded for $invoiceNumber'
          : 'Could not record payment',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceDetailControllerProvider);
    final invoice = state.invoice;

    return Column(
      children: [
        CustomAppBar(
          title: AppStrings.invoiceDetailTitle,
          onBackTap: () => context.pop(),
        ),
        Expanded(
          child: state.isLoading && invoice == null
              ? const CustomLoader()
              : state.errorMessage != null && invoice == null
              ? ErrorState(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(invoiceDetailControllerProvider.notifier)
                      .retry(),
                )
              : invoice == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InvoiceInfoCard(resultData: invoice),
                      const SizedBox(height: AppSizes.md),
                      InvoiceProductsCard(resultData: invoice),
                    ],
                  ),
                ),
        ),
        if (invoice != null)
          InvoiceDetailActions(
            sale: invoice.sale,
            onPayDues: () => _handlePayDues(
              invoice.sale.amountDue,
              invoice.sale.salesBillNo,
            ),
          ),
      ],
    );
  }
}
