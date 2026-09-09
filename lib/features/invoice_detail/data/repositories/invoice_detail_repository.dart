import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/invoice_detail_model.dart';

final invoiceDetailRepositoryProvider = Provider<InvoiceDetailRepository>((ref) {
  return InvoiceDetailRepository(ref.watch(apiClientProvider));
});

class InvoiceDetailRepository {
  final ApiClient _apiClient;
  InvoiceDetailRepository(this._apiClient);

  // TODO: replace with a real GET call (e.g. ApiEndpoints.invoiceDetails(id))
  // once the backend exposes it — wire via add_api_feature.py so the
  // loading-flag + state-patching pattern stays consistent with the rest
  // of the app. Mock lookup below stands in until then.
  Future<InvoiceDetailModel> getInvoiceDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockInvoices.firstWhere(
          (invoice) => invoice.id == id,
      orElse: () => throw Exception('Invoice not found: $id'),
    );
  }

  static final _mockInvoices = [
    InvoiceDetailModel(
      id: 'inv1',
      invoiceNumber: 'INV-2026-0142',
      customerName: 'Sabirunessa',
      customerMobile: '01700-000000',
      salesBy: 'Jerin Akther Jui (01666)',
      branch: 'Tarabo-01 (001)',
      date: DateTime(2026, 6, 13),
      status: InvoiceDetailStatus.paid,
      discountPercent: 10,
      vatPercent: 2.01,
      amountPaid: 5628,
      lineItems: const [
        InvoiceDetailLineItem(name: 'Chair', serialNo: '0200100000002', quantity: 1, unitPrice: 430),
        InvoiceDetailLineItem(name: '17" WALTON Rechargeable Table Fan', serialNo: '0200504700001', quantity: 1, unitPrice: 5700),
      ],
      activityLog: [
        InvoiceActivityLogEntry(action: 'Create', performedBy: 'Abir', dateTime: DateTime(2026, 8, 8, 12, 53)),
        InvoiceActivityLogEntry(action: 'Update', performedBy: 'Abir', dateTime: DateTime(2026, 8, 8, 12, 53)),
      ],
    ),
    InvoiceDetailModel(
      id: 'inv2',
      invoiceNumber: 'INV-2026-0143',
      customerName: 'Karim Store',
      customerMobile: '01812-345678',
      salesBy: 'Abir (01700)',
      branch: 'Tarabo-01 (001)',
      date: DateTime(2026, 2, 21),
      dueDate: DateTime(2026, 3, 7),
      status: InvoiceDetailStatus.due,
      amountPaid: 0,
      lineItems: const [
        InvoiceDetailLineItem(name: 'Wool Winter Coat', serialNo: '0200300000091', quantity: 1, unitPrice: 3200),
      ],
      activityLog: [
        InvoiceActivityLogEntry(action: 'Create', performedBy: 'Abir', dateTime: DateTime(2026, 2, 21, 11, 10)),
      ],
    ),
    InvoiceDetailModel(
      id: 'inv3',
      invoiceNumber: 'INV-2026-0144',
      customerName: 'Fatema General Store',
      date: DateTime(2026, 2, 18),
      dueDate: DateTime(2026, 2, 25),
      status: InvoiceDetailStatus.overdue,
      amountPaid: 200,
      lineItems: const [
        InvoiceDetailLineItem(name: 'Fresh Milk 1L', quantity: 10, unitPrice: 60),
        InvoiceDetailLineItem(name: 'Wheat Bread', quantity: 5, unitPrice: 40),
      ],
      activityLog: [
        InvoiceActivityLogEntry(action: 'Create', performedBy: 'Jui', dateTime: DateTime(2026, 2, 18, 9, 30)),
      ],
    ),
    InvoiceDetailModel(
      id: 'inv4',
      invoiceNumber: 'INV-2026-0145',
      customerName: 'Anik Enterprise',
      date: DateTime(2026, 2, 22),
      dueDate: DateTime(2026, 3, 8),
      status: InvoiceDetailStatus.partial,
      amountPaid: 500,
      lineItems: const [
        InvoiceDetailLineItem(name: 'Apple Soda', quantity: 20, unitPrice: 30),
        InvoiceDetailLineItem(name: 'Organic Eggs', quantity: 5, unitPrice: 120),
      ],
      activityLog: [
        InvoiceActivityLogEntry(action: 'Create', performedBy: 'Abir', dateTime: DateTime(2026, 2, 22, 14, 5)),
      ],
    ),
  ];
}