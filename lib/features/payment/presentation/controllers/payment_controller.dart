import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/payment_state.dart';

final paymentControllerProvider =
NotifierProvider.autoDispose<PaymentController, PaymentState>(PaymentController.new);

class PaymentController extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    // TODO: wire to paymentRepositoryProvider.getPendingSale(saleId) once
    // the payment/data/repositories layer is ready. Currently mock data
    // matching the in-progress New Sale cart.
    return const PaymentState().copyWith(
      payableAmount: 1341.88,
      saleId: '#SL00100001',
      saleDate: '09/06/2026',
      givenAmount: 1500.00,
      salesAgent: 'Admin',
      availableAgents: ['Admin', 'Rahul Sharma', 'Amit Patel'],
    );
  }

  void selectMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void updateGivenAmount(double amount) {
    state = state.copyWith(givenAmount: amount, errorMessage: null);
  }

  void selectAgent(String agent) {
    state = state.copyWith(salesAgent: agent);
  }

  /// Returns true on success. Navigation/snackbar stay in the view layer.
  Future<bool> completeSale() async {
    if (!state.canComplete) {
      state = state.copyWith(errorMessage: 'errorGivenAmountInsufficient');
      return false;
    }
    state = state.copyWith(isProcessing: true, errorMessage: null);

    // TODO: wire to paymentRepositoryProvider.completeSale(
    //   saleId: state.saleId,
    //   method: state.selectedMethod,
    //   givenAmount: state.givenAmount,
    //   salesAgent: state.salesAgent,
    // ) once the payment/data/repositories layer is ready.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(isProcessing: false);
    return true;
  }
}