import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../routes/route_names.dart';
import '../../data/model/invoices_model.dart';
import '../controllers/invoices_controller.dart';
import '../states/invoices_state.dart';
import '../widgets/invoice_card_item.dart';
import '../widgets/invoice_quick_filter_tabs.dart';

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
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(invoicesControllerProvider.notifier).loadMore();
    }
  }

  void _openDetail(BuildContext context, ResultDatum invoice) {
    context.push(RouteNames.invoiceDetail, extra: invoice.salesBillNo);
  }

  void _viewTechnicalDetails(InvoicesState state, InvoicesController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(context).pop();
            controller.getInvoices(reset: true);
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
    final state = ref.watch(invoicesControllerProvider);
    final controller = ref.read(invoicesControllerProvider.notifier);
    final isInitialLoading = state.isInvoicesLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;
    final invoices = state.filteredItems;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.invoicesTitle,
          trailingIcon: Icons.filter_alt_sharp,
          onTrailingTap: () => Scaffold.of(context).openEndDrawer(),
        ),
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
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: InvoiceQuickFilterTabs(
                      selectedStatus: state.selectedStatus,
                      selectedDatePreset: state.selectedDatePreset,
                      onStatusSelected: controller.selectStatus,
                      onDatePresetSelected: controller.selectDatePreset,
                    ),
                  ),
                  Expanded(
                    child: hasError
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ErrorState(
                            message: state.errorMessage ?? AppStrings.errorOccurred,
                            onRetry: () => controller.getInvoices(reset: true),
                          ),
                        ),
                        if (state.technicalDetails != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.lg),
                            child: TextButton(
                              onPressed: () => _viewTechnicalDetails(state, controller),
                              child: const Text('View technical details'),
                            ),
                          ),
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
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: invoices.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= invoices.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          final invoice = invoices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.sm + AppSizes.xs),
                            child: InvoiceCardItem(
                              invoice: invoice,
                              onTap: () => _openDetail(context, invoice),
                            ),
                          );
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