import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../data/models/sale_amounts.dart';
import '../controllers/invoice_detail_controller.dart';
import '../states/invoice_detail_state.dart';
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
      'Record full payment of ${CurrencyFormatter.format(amountDue, )} for $invoiceNumber?',
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

  void _viewTechnicalDetails(InvoiceDetailState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(context).pop();
            ref.read(invoiceDetailControllerProvider.notifier).retry();
          },
          onReportIssue: () {
            Clipboard.setData(ClipboardData(text: state.technicalDetails ?? ''));
            CustomSnackbar.show(context, 'Technical details copied.');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceDetailControllerProvider);
    final invoice = state.invoice;
    final hasError = state.errorMessage != null && invoice == null;

    return Column(
      children: [
        CustomAppBar(
          title: AppStrings.invoiceDetailTitle,
          onBackTap: () => context.pop(),
        ),
        Expanded(
          child: state.isLoading && invoice == null
              ? const CustomLoader()
              : hasError
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ErrorState(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(invoiceDetailControllerProvider.notifier)
                      .retry(),
                ),
              ),
              if (state.technicalDetails != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: TextButton(
                    onPressed: () => _viewTechnicalDetails(state),
                    child: const Text('View technical details'),
                  ),
                ),
            ],
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