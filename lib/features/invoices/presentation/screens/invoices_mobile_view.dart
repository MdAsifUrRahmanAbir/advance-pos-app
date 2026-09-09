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

class InvoicesMobileView extends ConsumerWidget {
  const InvoicesMobileView({super.key});

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
        AppHeaderBar(title: AppStrings.invoicesTitle),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
          child: SearchField(
            hintText: AppStrings.invoiceSearchHint,
            controller: controller.searchController,
            onChanged: controller.updateSearchQuery,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
          child: InvoiceFilterTabs(selected: state.selectedStatus, onChanged: controller.selectStatus),
        ),
        if (invoices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${invoices.length} ${AppStrings.invoicesFoundSuffix}',
                  style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
                ),
                Text(
                  '${AppStrings.invoiceTotalDueLabel}: ${CurrencyFormatter.format(state.totalDue, symbol: '৳')}',
                  style: const TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w700, color: Colors.red),
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
              padding: const EdgeInsets.all(AppSizes.md),
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
    );
  }
}
