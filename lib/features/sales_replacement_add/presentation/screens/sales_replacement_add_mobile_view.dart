import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/custom_step_indicator.dart';
import '../../../../core/widgets/common/paginated_picker_sheet.dart';
import '../../../../core/widgets/common/picker_trigger_field.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../cart/presentation/widgets/cart_item_list.dart';
import '../../../edit_sale_cart/presentation/widgets/edit_sale_product_results.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../../new_sale/presentation/states/new_sale_state.dart'
    show ProductItem;
import '../../../payment/presentation/states/payment_systems_from_accounts.dart';
import '../../../sales_replacement/presentation/controllers/sales_replacement_controller.dart';
import '../controllers/sales_replacement_add_controller.dart';
import '../controllers/sales_replacement_replace_controller.dart';
import '../states/sales_replacement_add_state.dart';
import '../states/sales_replacement_replace_state.dart';
import '../widgets/sales_replacement_add_success_sheet.dart';
import '../widgets/sales_replacement_payment_section.dart';
import '../widgets/sales_replacement_return_line_tile.dart';
import '../widgets/sales_replacement_return_summary_card.dart';
import '../widgets/sales_replacement_sale_banner.dart';
import '../widgets/sales_replacement_select_footer.dart';
import '../widgets/sales_replacement_totals_card.dart';

/// "New Replacement": step 1 picks the sale and the returned products,
/// step 2 adds the replacement items, shows the totals and takes payment.
class SalesReplacementAddMobileView extends ConsumerWidget {
  const SalesReplacementAddMobileView({super.key});

  static const double _errorHeight = 240;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final add = ref.watch(salesReplacementAddControllerProvider);
    final addCtrl = ref.read(salesReplacementAddControllerProvider.notifier);
    // Watched in both steps so the replacement items survive a trip back
    // to step 1.
    final replace = ref.watch(salesReplacementReplaceControllerProvider);
    final replaceCtrl = ref.read(salesReplacementReplaceControllerProvider.notifier);

    void goBack() {
      if (add.step == 0) {
        context.pop();
      } else {
        addCtrl.backToSelect();
      }
    }

    return PopScope(
      canPop: add.step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) addCtrl.backToSelect();
      },
      child: Column(
        children: [
          AppHeaderBar(
            title: AppStrings.repaTitle,
            backStyle: HeaderBackStyle.chevron,
            onBackTap: goBack,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: CustomStepIndicator(stepCount: 2, currentStep: add.step),
          ),
          Expanded(
            child: add.step == 0
                ? _selectStep(context, ref, add, addCtrl)
                : _replaceStep(context, ref, add, replace, replaceCtrl),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Step 1 — select the sale and the returned products
  // ───────────────────────────────────────────────
  Widget _selectStep(
      BuildContext context,
      WidgetRef ref,
      SalesReplacementAddState add,
      SalesReplacementAddController ctrl,
      ) {
    final colors = context.appColors;
    final customer = add.selectedCustomer;

    final Widget sale;
    if (add.selectedBillNo == null) {
      sale = Padding(
        padding: const EdgeInsets.only(top: AppSizes.lg),
        child: Text(
          AppStrings.repaPickBillHint,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontSm, color: colors.textHint),
        ),
      );
    } else if (add.isInvoiceLoading) {
      sale = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: CustomLoader(),
      );
    } else if (add.invoice == null) {
      sale = SizedBox(
        height: _errorHeight,
        child: ErrorState(
          message: add.invoiceError ?? AppStrings.repaLoadInvoiceFailed,
          onRetry: ctrl.loadInvoice,
        ),
      );
    } else {
      sale = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repaSaleLinesTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.repaSelectReturnHint,
            style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
          ),
          const SizedBox(height: AppSizes.sm),
          for (final line in add.soldLines) ...[
            SalesReplacementReturnLineTile(
              line: line,
              returnQty: add.returnQty[line.productId] ?? 0,
              onToggle: () => ctrl.toggleReturn(line.productId),
              onIncrement: () => ctrl.incrementReturn(line.productId),
              onDecrement: () => ctrl.decrementReturn(line.productId),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              PickerTriggerField(
                label: AppStrings.repaCustomerLabel,
                hintText: AppStrings.selectCustomerHint,
                valueText: customer == null
                    ? null
                    : '${customer.customerName} (${customer.customerMobile})',
                onTap: () => _openCustomerPicker(context, ref),
                onClear: customer == null ? null : ctrl.clearCustomer,
              ),
              const SizedBox(height: AppSizes.md),
              PickerTriggerField(
                label: AppStrings.srdSalesBillNoLabel,
                hintText: AppStrings.repaBillHint,
                valueText: add.selectedBillNo,
                isLoading: add.isInvoiceLoading,
                onTap: () => _openBillPicker(context, ref),
              ),
              const SizedBox(height: AppSizes.md),
              sale,
            ],
          ),
        ),
        SalesReplacementSelectFooter(
          itemCount: add.returnItemCount,
          returnTotal: add.returnTotal,
          canProceed: add.canProceed,
          onNext: ctrl.goToReplace,
        ),
      ],
    );
  }

  void _openCustomerPicker(BuildContext context, WidgetRef ref) {
    ref.read(salesReplacementAddControllerProvider.notifier).ensureCustomersLoaded();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Consumer(
        builder: (_, sheetRef, _) {
          final s = sheetRef.watch(salesReplacementAddControllerProvider);
          final c = sheetRef.read(salesReplacementAddControllerProvider.notifier);
          return PaginatedPickerSheet(
            title: AppStrings.selectCustomerTitle,
            searchHint: AppStrings.searchCustomerHint,
            emptyTitle: AppStrings.noCustomersFoundTitle,
            items: [
              for (final cu in s.customers)
                PickerItem(
                  id: cu.customerNo,
                  label: cu.customerName,
                  subtitle: cu.customerMobile,
                ),
            ],
            isLoading: s.isCustomersLoading,
            isLoadingMore: s.isCustomersLoadingMore,
            hasMore: s.customersHasMore,
            errorMessage: s.customersError,
            onSearch: c.onCustomerSearch,
            onLoadMore: c.loadCustomers,
            onRetry: () => c.loadCustomers(reset: true),
            onSelected: (item) {
              final picked =
                  s.customers.where((e) => e.customerNo == item.id).firstOrNull;
              if (picked != null) c.selectCustomer(picked);
              Navigator.of(sheetContext).pop();
            },
          );
        },
      ),
    );
  }

  void _openBillPicker(BuildContext context, WidgetRef ref) {
    ref.read(salesReplacementAddControllerProvider.notifier).ensureBillsLoaded();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Consumer(
        builder: (_, sheetRef, _) {
          final s = sheetRef.watch(salesReplacementAddControllerProvider);
          final c = sheetRef.read(salesReplacementAddControllerProvider.notifier);
          return PaginatedPickerSheet(
            title: AppStrings.repaSelectBillTitle,
            searchHint: AppStrings.repaSearchBillHint,
            emptyTitle: AppStrings.repaNoBillsTitle,
            items: [
              for (final b in s.bills) PickerItem(id: b.id, label: b.text),
            ],
            isLoading: s.isBillsLoading,
            isLoadingMore: s.isBillsLoadingMore,
            hasMore: s.billsHasMore,
            errorMessage: s.billsError,
            // The bills endpoint has no search: the sheet filters locally.
            onLoadMore: c.loadBills,
            onRetry: () => c.loadBills(reset: true),
            onSelected: (item) {
              c.selectBill(item.id);
              Navigator.of(sheetContext).pop();
            },
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Step 2 — replacement items, totals, payment
  // ───────────────────────────────────────────────
  Widget _replaceStep(
      BuildContext context,
      WidgetRef ref,
      SalesReplacementAddState add,
      SalesReplacementReplaceState replace,
      SalesReplacementReplaceController ctrl,
      ) {
    final colors = context.appColors;
    final invoice = add.invoice?.resultData;
    if (invoice == null) return const SizedBox.shrink();

    final masterData = ref.watch(masterDataControllerProvider);
    final systems = paymentSystemsFrom(masterData.paymentAccounts);

    void noMoreStock(String name) => CustomSnackbar.show(
      context,
      AppStrings.editSaleNoMoreStock(name),
      error: true,
    );

    void addProduct(ProductItem product) {
      if (ctrl.addProduct(product) == ReplaceAddOutcome.noStock) {
        noMoreStock(product.name);
      }
    }

    void incrementLine(String id) {
      if (ctrl.incrementLine(id)) return;
      final name = replace.newLines.where((l) => l.id == id).firstOrNull?.name;
      if (name != null) noMoreStock(name);
    }

    Future<void> submit() async {
      final ok = await ctrl.submit();
      if (!context.mounted) return;
      if (!ok) {
        final error = ref.read(salesReplacementReplaceControllerProvider).errorMessage;
        if (error != null) CustomSnackbar.show(context, error, error: true);
        return;
      }
      final billNo =
          ref.read(salesReplacementReplaceControllerProvider).createdBillNo ?? '';
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (sheetContext) => SalesReplacementAddSuccessSheet(
          billNo: billNo,
          onDone: () {
            Navigator.of(sheetContext).pop();
            ref.invalidate(salesReplacementControllerProvider); // refresh the list
            context.pop();
          },
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              SalesReplacementSaleBanner(
                billNo: add.selectedBillNo ?? '',
                customerName: invoice.customerName,
                customerNo: invoice.customerNo,
              ),
              const SizedBox(height: AppSizes.md),
              SalesReplacementReturnSummaryCard(
                lines: add.returnLines,
                total: add.returnTotal,
              ),
              const SizedBox(height: AppSizes.md),
              SearchField(
                controller: ctrl.productSearchController,
                hintText: AppStrings.searchProductHint,
                onChanged: ctrl.updateProductQuery,
                onClear: ctrl.clearProductSearch,
              ),
              const SizedBox(height: AppSizes.sm),
              if (replace.showProductResults) ...[
                EditSaleProductResults(
                  products: replace.productResults,
                  isLoading: replace.isProductSearching,
                  errorMessage: replace.productSearchError,
                  remainingFor: replace.remainingFor,
                  onAdd: addProduct,
                  onClose: ctrl.clearProductSearch,
                  onRetry: ctrl.retryProductSearch,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              Text(
                AppStrings.repaNewProductsTitle,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              if (replace.newLines.isEmpty)
                const EmptyState(
                  title: AppStrings.repaNoNewProductsTitle,
                  message: AppStrings.editSaleNoItemsMessage,
                  icon: Icons.inventory_2_outlined,
                )
              else
                CartItemList(
                  items: replace.newLines,
                  onIncrement: incrementLine,
                  onDecrement: ctrl.decrementLine,
                  onDelete: ctrl.removeLine,
                ),
              const SizedBox(height: AppSizes.md),
              SalesReplacementTotalsCard(
                returnTotal: add.returnTotal,
                newTotal: replace.newTotal,
                netPayable: replace.netPayable,
                isShortOfReturn: replace.isShortOfReturn,
              ),
              const SizedBox(height: AppSizes.md),
              if (replace.needsPayment)
                SalesReplacementPaymentSection(
                  systems: systems,
                  isLoading: masterData.isLoading && systems.isEmpty,
                  hasError: masterData.errorMessage != null && systems.isEmpty,
                  onRetry: ref.read(masterDataControllerProvider.notifier).refresh,
                  selectedEntries: replace.selectedEntries,
                  amountLocked: replace.lockSingleNonCashAmount,
                  changeDue: replace.changeDue,
                  accountsFor: ctrl.accountsForSystem,
                  onToggle: ctrl.toggleSystem,
                  onAccountChanged: ctrl.selectAccountForSystem,
                  onAmountChanged: ctrl.updateAmountForSystem,
                )
              else if (replace.newLines.isNotEmpty && !replace.isShortOfReturn)
                Text(
                  AppStrings.repaNoPaymentNeeded,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: colors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSizes.md),
              PrimaryInputField(
                label: AppStrings.repaReturnReasonLabel,
                hint: AppStrings.repaReturnReasonHint,
                controller: ctrl.reasonController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
        BottomActionBar(
          child: PrimaryButton(
            label: AppStrings.repaSubmitAction,
            loading: replace.isSubmitting,
            onPressed: replace.canSubmit ? submit : null,
          ),
        ),
      ],
    );
  }
}