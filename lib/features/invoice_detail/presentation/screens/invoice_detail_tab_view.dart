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

/// Same content as [InvoiceDetailMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class InvoiceDetailTabView extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailTabView({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailTabView> createState() =>
      _InvoiceDetailTabViewState();
}

class _InvoiceDetailTabViewState extends ConsumerState<InvoiceDetailTabView> {
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
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
                      padding: const EdgeInsets.all(AppSizes.lg),
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
