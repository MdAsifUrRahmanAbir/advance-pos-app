import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../cart/presentation/widgets/cart_item_list.dart';
import '../../../cart/presentation/widgets/discount_vat_section.dart';
import '../controllers/edit_sale_cart_controller.dart';
import '../widgets/edit_sale_cart_top_bar.dart';
import '../widgets/edit_sale_customer_row.dart';
import '../widgets/edit_sale_invoice_banner.dart';
import '../widgets/edit_sale_product_results.dart';
import '../widgets/edit_sale_summary_section.dart';
import 'edit_sale_cart_view_actions.dart';

/// Same content as [EditSaleCartMobileView], centered in a constrained
/// column for tablet / web widths.
class EditSaleCartTabView extends ConsumerStatefulWidget {
  final String billNo;

  const EditSaleCartTabView({super.key, required this.billNo});

  @override
  ConsumerState<EditSaleCartTabView> createState() => _EditSaleCartTabViewState();
}

class _EditSaleCartTabViewState extends ConsumerState<EditSaleCartTabView>
    with EditSaleCartViewActions<EditSaleCartTabView> {
  @override
  String get billNo => widget.billNo;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editSaleCartControllerProvider(billNo));
    final controller = cartController;
    final invoice = state.invoice;
    final cart = state.cart;

    final Widget body;
    if (invoice == null) {
      body = state.isInvoiceLoading
          ? const CustomLoader()
          : Column(
        children: [
          Expanded(
            child: ErrorState(
              message: state.invoiceErrorMessage ?? AppStrings.editSaleLoadFailed,
              onRetry: controller.loadInvoice,
            ),
          ),
          if (state.technicalDetails != null)
            TextButton(
              onPressed: () => viewTechnicalDetails(state),
              child: const Text(AppStrings.viewTechnicalDetails),
            ),
          const SizedBox(height: AppSizes.lg),
        ],
      );
    } else {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.mobileBreakpoint),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.sm,
                ),
                child: SearchField(
                  controller: controller.productSearchController,
                  hintText: AppStrings.searchProductHint,
                  onChanged: controller.updateProductQuery,
                  onClear: controller.clearProductSearch,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    0,
                    AppSizes.lg,
                    AppSizes.lg,
                  ),
                  children: [
                    if (state.showProductResults) ...[
                      EditSaleProductResults(
                        products: state.productResults,
                        isLoading: state.isProductSearching,
                        errorMessage: state.productSearchError,
                        remainingFor: state.remainingFor,
                        onAdd: addProduct,
                        onClose: controller.clearProductSearch,
                        onRetry: controller.retryProductSearch,
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                    EditSaleInvoiceBanner(invoice: invoice),
                    const SizedBox(height: AppSizes.md),
                    if (cart.items.isEmpty)
                      const EmptyState(
                        title: AppStrings.editSaleNoItemsTitle,
                        message: AppStrings.editSaleNoItemsMessage,
                        icon: Icons.inventory_2_outlined,
                      )
                    else
                      CartItemList(
                        items: cart.items,
                        lineDiscounts: cart.lineDiscounts,
                        onIncrement: incrementLine,
                        onDecrement: controller.decrementQuantity,
                        onDelete: controller.removeItem,
                      ),
                    const SizedBox(height: AppSizes.md),
                    EditSaleCustomerRow(
                      selectedCustomer: cart.selectedCustomer,
                      isResolving: state.isResolvingCustomer,
                      unmatched: state.customerUnmatched,
                      onPick: pickCustomer,
                      onAdd: addCustomer,
                    ),
                    const SizedBox(height: AppSizes.md),
                    DiscountVatSection(
                      state: cart,
                      onDiscountTypeChanged: controller.setDiscountType,
                      onDiscountChanged: controller.updateDiscountInput,
                      onTaxChanged: controller.updateTaxPercent,
                      onBasisChanged: controller.setDiscountBasis,
                    ),
                    const SizedBox(height: AppSizes.md),
                    EditSaleSummarySection(
                      cart: cart,
                      canProceed: state.canProceed,
                      onProceed: proceedToPayment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: canLeave(state),
      onPopInvokedWithResult: handlePopInvoked,
      child: Column(
        children: [
          EditSaleCartTopBar(
            billNo: billNo,
            onBack: goBack,
            onScanBarcode: state.isReady && !state.isScanning ? scanBarcode : null,
          ),
          if (state.isScanning) const LinearProgressIndicator(),
          Expanded(child: body),
        ],
      ),
    );
  }
}