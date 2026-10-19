import '../../data/models/sales_replacement_detail_model.dart';

/// Placeholder content rendered under Skeletonizer on first load.
class SalesReplacementDetailSkeletonData {
  const SalesReplacementDetailSkeletonData._();

  static final ResultData data = ResultData(
    resultDataReturn: Return(
      returnBillNo: 'SR00000000000',
      originalSalesBillNo: 'SL00000000000',
      returnDate: '00/00/00',
      returnType: '2',
      totalReturnQuantity: '1',
      totalReturnAmount: '0.00',
      returnDisAmount: '0.00',
      salesDisRate: null,
      taAfterDiscount: '0.00',
      payableReturnAmount: '0.00',
      totalCostAmount: '0.00',
      isActive: 1,
      branchId: 0,
    ),
    returnBy: 'Staff name',
    employeeId: '0',
    returnDetails: [
      for (var i = 0; i < 2; i++)
        ReturnDetail(
          productId: 0,
          productName: 'Sample product name',
          productBarcode: '0000000000',
          costPrice: '0.00',
          salesPrice: '0.00',
          netRate: 0,
          quantity: '1',
          disRate: '0',
          disAmount: '0.00',
          totalAmount: '0.00',
        ),
    ],
    replacementSale: ReplacementSale(
      salesBillNo: 'SL00000000000',
      salesDate: '00/00/00',
      totalQuantity: '1',
      totalAmount: '0.00',
      discountRate: '0.00',
      discountAmount: '0.00',
      taAfterDiscount: '0.00',
      vatRate: '0.00',
      vatAmount: '0.00',
      deliveryCharge: '0.00',
      processingFee: '0.00',
      grandTotal: 0,
      payableAfterReturn: 0,
      grandTotalWords: 'Amount in words',
      givenAmount: '0.00',
      changedAmount: '0.00',
      vatChalanNo: null,
      paymentSystems: [Payment(id: '0', name: 'Payment system')],
      paymentAccounts: [Payment(id: '0', name: 'Payment account')],
      collection: [
        Collection(
          paymentSystemId: 0,
          paymentSystemName: 'Payment system',
          amount: 0,
        ),
      ],
    ),
    customerName: 'Customer name',
    customerMobile: '00000000000',
    customerNo: null,
    replacementDetails: [
      for (var i = 0; i < 2; i++)
        ReplacementDetail(
          productId: 0,
          productName: 'Sample product name',
          productBarcode: '0000000000',
          unitPrice: '0.00',
          quantity: '1',
          totalSalesPrice: '0.00',
          disRate: '0',
          disAmount: '0.00',
          taAfterDiscount: 0,
        ),
    ],
  );
}