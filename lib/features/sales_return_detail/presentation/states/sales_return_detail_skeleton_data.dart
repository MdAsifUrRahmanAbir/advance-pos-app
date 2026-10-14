import '../../data/models/sales_return_detail_model.dart';

/// Placeholder content rendered under Skeletonizer on first load.
class SalesReturnDetailSkeletonData {
  const SalesReturnDetailSkeletonData._();

  static final SalesReturnDetailData data = SalesReturnDetailData(
    returnInfo: SalesReturnInfo(
      returnBillNo: 'SR00000000000',
      salesBillNo: 'SL00000000000',
      returnDate: '00/00/00',
      totalReturnQuantity: '1',
      totalReturnAmount: '0.00',
      returnDisAmount: '0.00',
      salesDisRate: null,
      taAfterDiscount: '0.00',
      totalCostAmount: '0.00',
      payableReturnAmount: '0.00',
      remarks: 'Remarks placeholder',
    ),
    payment: SalesReturnPayment(
      paymentSystems: [SalesReturnNamedItem(id: '0', name: 'Payment system')],
      paymentAccounts: [SalesReturnNamedItem(id: '0', name: 'Payment account')],
    ),
    customerName: 'Customer name',
    returnBy: 'Staff name',
    returnDetails: [
      for (var i = 0; i < 2; i++)
        SalesReturnLine(
          productId: 0,
          productName: 'Sample product name',
          productBarcode: '0000000000',
          costPrice: '0.00',
          salesPrice: '0.00',
          quantity: '1',
          disRate: '0',
          disAmount: '0.00',
          totalAmount: '0.00',
          netRate: 0,
        ),
    ],
  );
}