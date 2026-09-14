import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(invoicesControllerProvider.notifier).loadMore();
    }
  }

  void _openDetail(BuildContext context, ResultDatum invoice) {
    context.push(RouteNames.invoiceDetail, extra: invoice.salesBillNo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoicesControllerProvider);
    final controller = ref.read(invoicesControllerProvider.notifier);
    final isInitialLoading = state.isInvoicesLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeaderBar(title: AppStrings.invoicesTitle),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: SearchField(
            hintText: AppStrings.invoiceSearchHint,
            controller: controller.searchController,
            onChanged: controller.updateSearchQuery,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        //   child: InvoiceFilterTabs(selected: state.selectedStatus, onChanged: controller.selectStatus),
        // ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: hasError
              ? ErrorState(message: state.errorMessage ?? AppStrings.errorOccurred, onRetry: () => controller.getInvoices(reset: true))
              : (!isInitialLoading && state.allItems.isEmpty)
              ? EmptyState(title: AppStrings.invoicesTitle, message: AppStrings.invoicesEmptyMessage, icon: Icons.receipt_long_outlined)
              : CustomRefreshWrapper(
            onRefresh: controller.refresh,
            child: isInitialLoading
                ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
              itemBuilder: (context, index) => _placeholderCard(),
            ).skeletonizer(enabled: true)
                : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.allItems.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
              itemBuilder: (context, index) {
                if (index >= state.allItems.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final invoice = state.allItems[index];
                return InvoiceCardItem(invoice: invoice, onTap: () => _openDetail(context, invoice));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderCard() {
    return InvoiceCardItem(
      invoice: ResultDatum(
        sl: 0, salesDate: '', salesBillNo: 'INV-000000', totalQuantity: '0',
        totalAmount: '0', discountRate: '0', discountAmount: '0', taAfterDiscount: '0',
        vatRate: '0', vatAmount: '0', deliveryCharge: '0', totalPayableAmount: '0',
        paidAmount: '0', paymentSystems: const [], paymentAccounts: const [],
        productNames: const [], referenceNo: '', remarks: '',
        customerName: 'Customer name', customerMobile: '', salesBy: '',
      ),
    );
  }
}