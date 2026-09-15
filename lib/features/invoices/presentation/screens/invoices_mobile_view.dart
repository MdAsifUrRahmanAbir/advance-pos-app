import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/widget_animation_extension.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../../routes/route_names.dart';
import '../../data/model/invoices_model.dart';
import '../controllers/invoices_controller.dart';
import '../widgets/invoice_card_item.dart';
import '../widgets/invoice_filter_tabs.dart';
import '../widgets/invoice_status_badge.dart';

class InvoicesMobileView extends ConsumerStatefulWidget {
  const InvoicesMobileView({super.key});

  @override
  ConsumerState<InvoicesMobileView> createState() => _InvoicesMobileViewState();
}

class _InvoicesMobileViewState extends ConsumerState<InvoicesMobileView> {
  final _scrollController = ScrollController();
  String _statusFilter = 'all';

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
    // Fires whenever the list is scrolled; loadMore() itself is a no-op
    // if already loading or if hasMore is false, so this is safe to call
    // on every scroll tick near the bottom.
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(invoicesControllerProvider.notifier).loadMore();
    }
  }

  void _openDetail(BuildContext context, ResultDatum invoice) {
    context.push(RouteNames.invoiceDetail, extra: invoice.salesBillNo);
  }

  List<ResultDatum> _applyStatusFilter(List<ResultDatum> invoices) {
    if (_statusFilter == 'all') return invoices;
    return invoices
        .where(
          (invoice) =>
              InvoiceStatusBadge.statusOf(invoice).name == _statusFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoicesControllerProvider);
    final controller = ref.read(invoicesControllerProvider.notifier);
    final isInitialLoading = state.isInvoicesLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;
    final invoices = _applyStatusFilter(state.allItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeaderBar(title: AppStrings.invoicesTitle),
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
                child: InvoiceFilterTabs(
                  selected: _statusFilter,
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: hasError
              ? ErrorState(
                  message: state.errorMessage ?? AppStrings.errorOccurred,
                  onRetry: () => controller.getInvoices(reset: true),
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
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSizes.sm + AppSizes.xs,
                                  ),
                                  child: InvoiceCardItem(
                                    invoice: invoice,
                                    onTap: () => _openDetail(context, invoice),
                                  ).fadeSlideIn(delay: (index * 60).ms),
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
}
