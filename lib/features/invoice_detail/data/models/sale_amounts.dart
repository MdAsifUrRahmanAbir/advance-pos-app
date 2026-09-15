import '../../../../core/utils/currency_formatter.dart';
import 'invoice_detail_model.dart';

/// Convenience numeric getters over [Sale]'s string-typed amount fields
/// (and [SaleDetail]'s), so presentation code never has to sprinkle
/// parsing logic inline. Kept as an extension rather than mutating the
/// generated model, so [InvoiceDetailModel] stays a pure mirror of the
/// API contract. Uses [parseAmount]/[parseQuantity] since some fields
/// arrive comma-formatted (e.g. "5,628.00") and plain `double.tryParse`
/// silently returns 0 on those.
extension SaleAmounts on Sale {
  double get totalAmountValue => parseAmount(totalAmount);
  double get discountAmountValue => parseAmount(discountAmount);
  double get taAfterDiscountValue => parseAmount(taAfterDiscount);
  double get vatAmountValue => parseAmount(vatAmount);
  double get deliveryChargeValue => parseAmount(deliveryCharge);
  double get totalPayableAmountValue => parseAmount(totalPayableAmount);
  double get paidAmountValue => parseAmount(paidAmount);
  double get discountRateValue => parseAmount(discountRate);
  double get vatRateValue => parseAmount(vatRate);
  int get totalQuantityValue => parseQuantity(totalQuantity);

  double get amountDue => (totalPayableAmountValue - paidAmountValue).clamp(0, double.infinity);
}

extension SaleDetailAmounts on SaleDetail {
  double get unitPriceValue => parseAmount(unitPrice);
  int get quantityValue => parseQuantity(quantity);
  double get disAmountValue => parseAmount(disAmount);
  double get disRateValue => parseAmount(disRate);
}