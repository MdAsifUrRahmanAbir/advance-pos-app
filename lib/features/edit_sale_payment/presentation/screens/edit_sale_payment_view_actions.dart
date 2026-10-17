import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../payment/presentation/widgets/printer_selection_sheet.dart';
import '../controllers/edit_sale_payment_controller.dart';
import '../widgets/edit_sale_success_sheet.dart';

/// View-layer wiring shared by [EditSalePaymentMobileView] and
/// [EditSalePaymentTabView]: confirm dialog, success sheet, share/print
/// feedback, and returning `true` to Edit Sale once the update is saved.
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
    final receiptKey = GlobalKey();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Consumer(
        builder: (consumerContext, sheetRef, _) {
          final state = sheetRef.watch(editSalePaymentControllerProvider(billNo));
          return EditSaleSuccessSheet(
            state: state,
            receiptBoundaryKey: receiptKey,
            onShare: () async {
              final ok = await paymentController.shareReceipt(receiptKey);
              if (!ok && consumerContext.mounted) {
                CustomSnackbar.show(consumerContext, AppStrings.shareFailedMessage, error: true);
              }
            },
            onPrint: () async {
              final device = await showModalBottomSheet<BluetoothInfo>(
                context: consumerContext,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const PrinterSelectionSheet(),
              );
              if (device == null) return;
              final ok = await paymentController.printReceipt(device.macAdress);
              if (consumerContext.mounted) {
                CustomSnackbar.show(
                  consumerContext,
                  ok ? AppStrings.printSuccessMessage : AppStrings.printFailedMessage,
                  error: !ok,
                );
              }
            },
            onDone: () {
              Navigator.of(sheetContext).pop();
              // Back to Edit Sale with `true`; it pops itself to Invoices.
              if (mounted) context.pop(true);
            },
          );
        },
      ),
    );
  }
}