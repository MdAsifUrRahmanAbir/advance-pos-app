import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../controllers/invoices_controller.dart';
import '../widgets/invoice_card_item.dart';
import '../widgets/invoice_detail_sheet.dart';
import '../widgets/invoice_filter_tabs.dart';

/// Same content as [InvoicesMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class InvoicesTabView extends ConsumerWidget {
  const InvoicesTabView({super.key});

  void _openDetail(BuildContext context, invoice) {
    CustomBottomSheet.show<void>(context, child: InvoiceDetailSheet(invoice: invoice));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoicesControllerProvider);
    final controller = ref.read(invoicesControllerProvider.notifier);
    final invoices = state.filteredInvoices;

    return Column(
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
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: InvoiceFilterTabs(selected: state.selectedStatus, onChanged: controller.selectStatus),
                  ),
                  if (invoices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${invoices.length} ${AppStrings.invoicesFoundSuffix}',
                            style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                          ),
                          Text(
                            '${AppStrings.invoiceTotalDueLabel}: ${CurrencyFormatter.format(state.totalDue, symbol: '৳')}',
                            style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: invoices.isEmpty
                        ? EmptyState(
                      title: AppStrings.invoicesTitle,
                      message: AppStrings.invoicesEmptyMessage,
                      icon: Icons.receipt_long_outlined,
                    )
                        : CustomRefreshWrapper(
                      onRefresh: controller.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: invoices.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
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