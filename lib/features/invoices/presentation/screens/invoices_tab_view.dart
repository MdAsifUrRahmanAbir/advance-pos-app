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
import '../../../../routes/route_names.dart';
import '../../data/model/invoices_model.dart';
import '../controllers/invoices_controller.dart';
import '../widgets/invoice_card_item.dart';

/// Same content as [InvoicesMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class InvoicesTabView extends ConsumerStatefulWidget {
  const InvoicesTabView({super.key});

  @override
  ConsumerState<InvoicesTabView> createState() => _InvoicesTabViewState();
}

class _InvoicesTabViewState extends ConsumerState<InvoicesTabView> {
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
        AppHeaderBar(title: AppStrings.invoicesTitle, backStyle: HeaderBackStyle.chevron),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
                    child: SearchField(
                      hintText: AppStrings.invoiceSearchHint,
                      controller: controller.searchController,
                      onChanged: controller.updateSearchQuery,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Expanded(
                    child: hasError
                        ? ErrorState(message: state.errorMessage ?? AppStrings.errorOccurred, onRetry: () => controller.getInvoices(reset: true))
                        : (!isInitialLoading && state.allItems.isEmpty)
                        ? EmptyState(title: AppStrings.invoicesTitle, message: AppStrings.invoicesEmptyMessage, icon: Icons.receipt_long_outlined)
                        : CustomRefreshWrapper(
                      onRefresh: controller.refresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}