import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../../../cart/data/models/customers_model.dart';
import '../../../new_sale/presentation/states/new_sale_state.dart'
    show ProductItem, ScanOutcome;
import '../controllers/edit_sale_cart_controller.dart';
import '../states/edit_sale_cart_state.dart';
import '../widgets/edit_sale_add_customer_sheet.dart';
import '../widgets/edit_sale_customer_search_sheet.dart';

/// View-layer wiring shared by [EditSaleCartMobileView] and
/// [EditSaleCartTabView]: navigation, sheets, dialogs and snackbars.
/// Kept in one place so the two layouts can't drift apart. The views
/// themselves only do layout.
mixin EditSaleCartViewActions<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get billNo;

  /// Set right before a deliberate pop (discard confirmed / sale updated)
  /// so [PopScope] lets it through.
  bool _leaving = false;

  EditSaleCartController get cartController =>
      ref.read(editSaleCartControllerProvider(billNo).notifier);

  bool canLeave(EditSaleCartState state) => _leaving || !state.hasChanges;

  /// Wire to the top bar's back button: goes through [PopScope], so
  /// unsaved edits trigger the discard dialog.
  void goBack() => Navigator.of(context).maybePop();

  Future<void> handlePopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final discard = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.editSaleDiscardTitle,
      message: AppStrings.editSaleDiscardMessage,
      confirmText: AppStrings.editSaleDiscardConfirm,
      cancelText: AppStrings.editSaleKeepEditing,
      destructive: true,
    );
    if (discard == true && mounted) _leaveWith(null);
  }

  void _leaveWith(bool? result) {
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop(result);
    });
  }

  // ── Products ────────────────────────────────────
  Future<void> scanBarcode() async {
    final code = await BarcodeScannerScreen.scan(context);
    if (code == null || !mounted) return;

    final result = await cartController.handleScannedCode(code);
    if (!mounted) return;
    if (result == null) {
      CustomSnackbar.show(context, AppStrings.editSaleSearchFailed, error: true);
      return;
    }
    switch (result.outcome) {
      case ScanOutcome.added:
        CustomSnackbar.show(context, AppStrings.productAddedMessage(result.product!.name));
      case ScanOutcome.outOfStock:
        CustomSnackbar.show(
          context,
          AppStrings.editSaleNoMoreStock(result.product!.name),
          error: true,
        );
      case ScanOutcome.notFound:
        CustomSnackbar.show(context, AppStrings.productNotFoundMessage(code), error: true);
    }
  }

  void addProduct(ProductItem product) {
    final outcome = cartController.addProduct(product);
    CustomSnackbar.show(
      context,
      outcome == EditCartAddOutcome.added
          ? AppStrings.productAddedMessage(product.name)
          : AppStrings.editSaleNoMoreStock(product.name),
      error: outcome != EditCartAddOutcome.added,
    );
  }

  void incrementLine(String productId) {
    if (cartController.incrementQuantity(productId)) return;
    final line = ref
        .read(editSaleCartControllerProvider(billNo))
        .cart
        .items
        .where((i) => i.id == productId)
        .firstOrNull;
    if (line != null) {
      CustomSnackbar.show(context, AppStrings.editSaleNoMoreStock(line.name), error: true);
    }
  }

  // ── Customer ────────────────────────────────────
  Future<void> pickCustomer() async {
    final customer = await showModalBottomSheet<ResultDatum>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSaleCustomerSearchSheet(billNo: billNo),
    );
    if (customer != null && mounted) cartController.selectCustomer(customer);
  }

  Future<void> addCustomer() async {
    final created = await showModalBottomSheet<ResultDatum>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSaleAddCustomerSheet(billNo: billNo),
    );
    if (created != null && mounted) {
      CustomSnackbar.show(context, AppStrings.customerAddedSuccessMessage(created.customerName));
    }
  }

  // ── Checkout ────────────────────────────────────
  Future<void> proceedToPayment() async {
    final state = ref.read(editSaleCartControllerProvider(billNo));
    if (state.cart.items.isEmpty) {
      CustomSnackbar.show(context, AppStrings.editSaleCartEmptyError, error: true);
      return;
    }
    if (!state.canProceed) {
      CustomSnackbar.show(context, AppStrings.editSaleDiscountPendingError);
      return;
    }
    final updated = await context.push<bool>(RouteNames.editSalePaymentPath(billNo));
    // Sale saved → hand `true` back to the Invoices list so it refreshes.
    if (updated == true && mounted) _leaveWith(true);
  }

  // ── Errors ──────────────────────────────────────
  void viewTechnicalDetails(EditSaleCartState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(routeContext).pop();
            cartController.loadInvoice();
          },
          onReportIssue: () {
            Clipboard.setData(ClipboardData(text: state.technicalDetails ?? ''));
            CustomSnackbar.show(routeContext, AppStrings.technicalDetailsCopied);
          },
        ),
      ),
    );
  }
}