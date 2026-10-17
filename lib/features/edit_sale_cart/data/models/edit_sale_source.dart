
import '../../../invoice_detail/data/models/invoice_detail_model.dart';

class EditSaleSource {
  final InvoiceDetailModel detail;
  final String? customerNo;

  const EditSaleSource({required this.detail, this.customerNo});

  ResultData get invoice => detail.resultData;
}