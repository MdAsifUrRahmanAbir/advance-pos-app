import 'package:flutter/foundation.dart';

enum InvoiceDetailStatus { paid, due, partial, overdue }

@immutable
class InvoiceDetailLineItem {
  final String name;
  final String? serialNo;
  final int quantity;
  final double unitPrice;

  const InvoiceDetailLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.serialNo,
  });

  double get lineTotal => unitPrice * quantity;
}

/// One row in an invoice's audit trail — who created/updated it, and
/// when. Shown as-is in [InvoiceActivityLogCard].
@immutable
class InvoiceActivityLogEntry {
  final String action; // 'Create' | 'Update' | ...
  final String performedBy;
  final DateTime dateTime;

  const InvoiceActivityLogEntry({
    required this.action,
    required this.performedBy,
    required this.dateTime,
  });
}

/// Full single-invoice shape shown on [InvoiceDetailScreen]. Presentation-
/// layer only until the real invoices API is wired via add_api_feature.py.
@immutable
class InvoiceDetailModel {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final DateTime date;
  final DateTime? dueDate;
  final InvoiceDetailStatus status;
  final List<InvoiceDetailLineItem> lineItems;
  final double amountPaid;

  final String? customerMobile;
  final String? customerNationalId;
  final String? salesBy;
  final String? branch;
  final String? vatInvoiceNo;
  final String paymentSystem;
  final String paymentAccount;
  final double discountPercent;
  final double vatPercent;
  final String? remarks;
  final List<InvoiceActivityLogEntry> activityLog;

  const InvoiceDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.status,
    this.dueDate,
    this.lineItems = const [],
    this.amountPaid = 0,
    this.customerMobile,
    this.customerNationalId,
    this.salesBy,
    this.branch,
    this.vatInvoiceNo,
    this.paymentSystem = 'Cash',
    this.paymentAccount = 'Cash (Cash)',
    this.discountPercent = 0,
    this.vatPercent = 0,
    this.remarks,
    this.activityLog = const [],
  });

  int get itemCount => lineItems.fold(0, (sum, line) => sum + line.quantity);

  double get subtotal => lineItems.fold(0.0, (sum, line) => sum + line.lineTotal);

  double get discountAmount => subtotal * (discountPercent / 100);

  double get amountAfterDiscount => subtotal - discountAmount;

  double get vatAmount => amountAfterDiscount * (vatPercent / 100);

  double get total => amountAfterDiscount + vatAmount;

  double get amountDue => (total - amountPaid).clamp(0, double.infinity);
}