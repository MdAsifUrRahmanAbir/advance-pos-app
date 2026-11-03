import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/nav_extension.dart';
import '../../../../routes/route_names.dart';
import '../../../invoices/presentation/screens/sale_complete_launcher.dart';
import '../controllers/edit_sale_payment_controller.dart';

/// View-layer wiring shared by [EditSalePaymentMobileView] and
/// [EditSalePaymentTabView]: confirm dialog, the sale-complete sheet
/// (invoice summary, share / print / bill preview) and its exits.
mixin EditSalePaymentViewActions<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get billNo;

  EditSalePaymentController get paymentController =>
      ref.read(editSalePaymentControllerProvider(billNo).notifier);

  void goBack() => context.pop();

  Future<void> submitUpdate() async {
    final state = ref.read(editSalePaymentControllerProvider(billNo));
    final confirmed = await CustomAlertDialog.confirm(
      context,
      title: AppStrings.editSaleConfirmTitle,
      message: AppStrings.editSaleConfirmMessage(
        billNo,
        CurrencyFormatter.format(state.payableAmount),
      ),
      confirmText: AppStrings.editSaleUpdateAction,
    );
    if (confirmed != true || !mounted) return;

    final success = await paymentController.updateSale();
    if (!mounted) return;
    if (success) {
      _showSuccessSheet();
    } else {
      CustomSnackbar.show(
        context,
        ref.read(editSalePaymentControllerProvider(billNo)).errorMessage ??
            AppStrings.editSaleUpdateFailed,
        error: true,
      );
    }
  }

  void _showSuccessSheet() {
    final state = ref.read(editSalePaymentControllerProvider(billNo));
    final savedBillNo = state.updatedBillNo ?? state.billNo;
    showSaleCompleteSheet(
      context,
      billNo: savedBillNo,
      title: AppStrings.editSaleUpdatedTitle,
      subtitle: AppStrings.editSaleUpdatedSubtitle(savedBillNo),
      onDone: (sheetContext) {
        Navigator.of(sheetContext).pop();
        // Back to Edit Sale with `true`; it pops itself to Invoices.
        if (mounted) context.pop(true);
      },
      onNewSale: (sheetContext) {
        Navigator.of(sheetContext).pop();
        if (mounted) context.restartFlowFrom(RouteNames.newSale);
      },
      onGoToDashboard: (sheetContext) {
        Navigator.of(sheetContext).pop();
        if (mounted) context.go(RouteNames.mainShell);
      },
    );
  }
}
