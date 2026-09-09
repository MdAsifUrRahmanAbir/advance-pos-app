import 'package:flutter/foundation.dart';

/// Payment status of an invoice — drives the badge color and the
/// filter tabs on the Invoices screen.
enum InvoiceStatus { paid, due, partial, overdue }

/// Presentation-layer shape until the real invoices API is wired via
/// add_api_feature.py — at that point this maps from the real model.
@immutable
class InvoiceLineItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const InvoiceLineItem({required this.name, required this.quantity, required this.unitPrice});

  double get lineTotal => unitPrice * quantity;
}

@immutable
class InvoiceItem {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final DateTime date;
  final DateTime? dueDate;
  final InvoiceStatus status;
  final List<InvoiceLineItem> lineItems;
  final double amountPaid;

  const InvoiceItem({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.status,
    this.dueDate,
    this.lineItems = const [],
    this.amountPaid = 0,
  });

  int get itemCount => lineItems.fold(0, (sum, line) => sum + line.quantity);

  double get total => lineItems.fold(0.0, (sum, line) => sum + line.lineTotal);

  double get amountDue => (total - amountPaid).clamp(0, double.infinity);
}