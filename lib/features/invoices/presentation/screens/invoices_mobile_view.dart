import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/utils/widget_animation_extension.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../../routes/route_names.dart';
import '../../data/model/invoices_model.dart';
import '../controllers/invoices_controller.dart';
import '../states/invoices_state.dart';
import '../widgets/invoice_card_item.dart';
import '../widgets/invoice_quick_filter_tabs.dart';

class InvoicesMobileView extends ConsumerStatefulWidget {
  const InvoicesMobileView({super.key});

  @override
  ConsumerState<InvoicesMobileView> createState() => _InvoicesMobileViewState();
}

class _InvoicesMobileViewState extends ConsumerState<InvoicesMobileView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(invoicesControllerProvider.notifier).loadMore();
    }
  }

  void _openDetail(BuildContext context, ResultDatum invoice) {
    context.push(RouteNames.invoiceDetail, extra: invoice.salesBillNo);
  }

  void _viewTechnicalDetails(
    BuildContext context,
    InvoicesState state,
    InvoicesController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(context).pop();
            controller.getInvoices(reset: true);
          },
          onReportIssue: () {
            Clipboard.setData(
              ClipboardData(text: state.technicalDetails ?? ''),
            );
            CustomSnackbar.show(context, 'Technical details copied.');
          },
        ),
      ),
    );
  }

  static const int _staggerResetAt = 15;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoicesControllerProvider);
    final controller = ref.read(invoicesControllerProvider.notifier);
    final isInitialLoading = state.isInvoicesLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;
    final invoices = state.filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeaderBar(
          title: AppStrings.invoicesTitle,
          trailingIcon: Icons.filter_alt_sharp,
          onTrailingTap: () => Scaffold.of(context).openEndDrawer(),
        ),
        const SizedBox(height: AppSizes.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: SearchField(
            hintText: AppStrings.invoiceSearchHint,
            controller: controller.searchController,
            onChanged: controller.updateSearchQuery,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        isInitialLoading
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: InvoiceQuickFilterTabs(
                  selectedStatus: state.selectedStatus,
                  selectedDatePreset: state.selectedDatePreset,
                  onStatusSelected: controller.selectStatus,
                  onDatePresetSelected: controller.selectDatePreset,
                ),
              ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: hasError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSizes.bottomNavBarHeight * 2),
                    Expanded(
                      child: ErrorState(
                        message: state.errorMessage ?? AppStrings.errorOccurred,
                        onRetry: () => controller.getInvoices(reset: true),
                      ),
                    ),
                    if (state.technicalDetails != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: TextButton(
                          onPressed: () =>
                              _viewTechnicalDetails(context, state, controller),
                          child: const Text('View technical details'),
                        ),
                      ),
                    SizedBox(height: AppSizes.bottomNavBarHeight * 3),
                  ],
                )
              : (!isInitialLoading && invoices.isEmpty)
              ? EmptyState(
                  title: AppStrings.invoicesTitle,
                  message: AppStrings.invoicesEmptyMessage,
                  icon: Icons.receipt_long_outlined,
                )
              : CustomRefreshWrapper(
                  onRefresh: controller.refresh,
                  child: isInitialLoading
                      ? ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.md,
                            0,
                            AppSizes.md,
                            AppSizes.md,
                          ),
                          itemCount: 6,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSizes.sm + AppSizes.xs),
                          itemBuilder: (context, index) => _placeholderCard()
                              .fadeSlideIn(delay: (index * 60).ms),
                        ).skeletonizer(enabled: true)
                      : ListView(
                          controller: _scrollController,
                          shrinkWrap: true,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(
                                AppSizes.md,
                                0,
                                AppSizes.md,
                                AppSizes.md,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  invoices.length + (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= invoices.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSizes.md,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final invoice = invoices[index];
                                final staggerIndex = index % _staggerResetAt;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSizes.sm + AppSizes.xs,
                                  ),
                                  child: InvoiceCardItem(
                                    invoice: invoice,
                                    onTap: () => _openDetail(context, invoice),
                                    onEdit: () {
                                      // Navigate to edit sale
                                    },
                                    onDelete: () {
                                      _confirmDeleteInvoice(context, ref, invoice.salesBillNo);
                                    },
                                    onReturnSale: () {
                                      // Navigate to return sale
                                    },
                                  ).fadeSlideIn(delay: (staggerIndex * 40).ms),
                                );
                              },
                            ),
                            SizedBox(height: AppSizes.bottomNavBarHeight / 2),
                          ],
                        ),
                ),
        ),
      ],
    );
  }

  Widget _placeholderCard() {
    return InvoiceCardItem(
      onEdit: () {
        // Navigate to edit sale
      },
      onDelete: () {
        // Show delete confirmation
      },
      onReturnSale: () {
        // Navigate to return sale
      },
      invoice: ResultDatum(
        sl: 0,
        salesDate: '',
        salesBillNo: 'INV-000000',
        totalQuantity: '0',
        totalAmount: '0',
        discountRate: '0',
        discountAmount: '0',
        taAfterDiscount: '0',
        vatRate: '0',
        vatAmount: '0',
        deliveryCharge: '0',
        totalPayableAmount: '0',
        paidAmount: '0',
        paymentSystems: const [],
        paymentAccounts: const [],
        productNames: const [],
        referenceNo: '',
        remarks: '',
        customerName: 'Customer name',
        customerMobile: '',
        salesBy: '',
      ),
    );
  }


  Future<void> _confirmDeleteInvoice(
      BuildContext context,
      WidgetRef ref,
      String billNo
      ) async {
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.deleteInvoice,
      message: 'This action is permanent and cannot be undone. Are you sure?',
      confirmText: AppStrings.deleteInvoice,
      destructive: true,
    );

    if (confirmed == true) {
      final success = await ref
          .read(invoicesControllerProvider.notifier)
          .invoiceDelete(billNo);
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        success
            ? 'Invoice $billNo deleted'
            : (ref.read(invoicesControllerProvider).errorMessage ??
            AppStrings.errorOccurred),
        error: !success,
      );
    }
  }
}
