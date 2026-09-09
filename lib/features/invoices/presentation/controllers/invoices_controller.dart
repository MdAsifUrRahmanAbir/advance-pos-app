import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/invoice_model.dart';
import '../states/invoices_state.dart';

final invoicesControllerProvider =
NotifierProvider.autoDispose<InvoicesController, InvoicesState>(InvoicesController.new);

class InvoicesController extends Notifier<InvoicesState> {
  late final TextEditingController searchController;

  @override
  InvoicesState build() {
    searchController = TextEditingController();
    ref.onDispose(() => searchController.dispose());

    // TODO: wire to invoicesRepositoryProvider.getInvoices() once the
    // invoices/data/repositories layer is ready. Currently mock data.
    return InvoicesState.initial().copyWith(allInvoices: _mockInvoices);
  }

  void selectStatus(String statusKey) {
    state = state.copyWith(selectedStatus: statusKey);
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    // TODO: replace with a real repository re-fetch.
    state = state.copyWith(allInvoices: _mockInvoices);
  }

  static final _mockInvoices = [
    InvoiceItem(
      id: 'inv1',
      invoiceNumber: 'INV-2026-0142',
      customerName: 'Rahim Traders',
      date: DateTime(2026, 2, 20),
      status: InvoiceStatus.paid,
      amountPaid: 3300,
      lineItems: const [
        InvoiceLineItem(name: 'Winner Men Shirt', quantity: 3, unitPrice: 860),
        InvoiceLineItem(name: 'Classic Denim Jeans', quantity: 0, unitPrice: 1450),
      ],
    ),
    InvoiceItem(
      id: 'inv2',
      invoiceNumber: 'INV-2026-0143',
      customerName: 'Karim Store',
      date: DateTime(2026, 2, 21),
      dueDate: DateTime(2026, 3, 7),
      status: InvoiceStatus.due,
      amountPaid: 0,
      lineItems: const [
        InvoiceLineItem(name: 'Wool Winter Coat', quantity: 1, unitPrice: 3200),
      ],
    ),
    InvoiceItem(
      id: 'inv3',
      invoiceNumber: 'INV-2026-0144',
      customerName: 'Fatema General Store',
      date: DateTime(2026, 2, 18),
      dueDate: DateTime(2026, 2, 25),
      status: InvoiceStatus.overdue,
      amountPaid: 200,
      lineItems: const [
        InvoiceLineItem(name: 'Fresh Milk 1L', quantity: 10, unitPrice: 60),
        InvoiceLineItem(name: 'Wheat Bread', quantity: 5, unitPrice: 40),
      ],
    ),
    InvoiceItem(
      id: 'inv4',
      invoiceNumber: 'INV-2026-0145',
      customerName: 'Anik Enterprise',
      date: DateTime(2026, 2, 22),
      dueDate: DateTime(2026, 3, 8),
      status: InvoiceStatus.partial,
      amountPaid: 500,
      lineItems: const [
        InvoiceLineItem(name: 'Apple Soda', quantity: 20, unitPrice: 30),
        InvoiceLineItem(name: 'Organic Eggs', quantity: 5, unitPrice: 120),
      ],
    ),
  ];
}