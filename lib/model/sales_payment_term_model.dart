import './pagination_model.dart';

class SalesPaymentTermModel {
  List<SalesPaymentTermDataModel> data;
  PaginationModel? pagination;

  SalesPaymentTermModel({
    required this.data,
    required this.pagination,
  });

  factory SalesPaymentTermModel.fromJson(Map<String, dynamic> json) {
    return SalesPaymentTermModel(
      data: List<SalesPaymentTermDataModel>.from(json['data'].map((x) {
        return SalesPaymentTermDataModel.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class SalesPaymentTermDataModel {
  String id;
  String salesId;
  String customerId;
  String salesmanId;
  String invoice;
  String customerName;
  String salesmanName;
  String type; // tempo, credit, cash
  String? dueDate;
  double amount;
  double paidAmount;
  double remaining;
  String status; // unpaid, partial, completed
  String createdAt;
  String updatedAt;

  SalesPaymentTermDataModel({
    required this.id,
    required this.salesId,
    required this.customerId,
    required this.salesmanId,
    required this.invoice,
    required this.customerName,
    required this.salesmanName,
    required this.type,
    this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesPaymentTermDataModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    // Helper function to safely convert to string
    String _parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Handle id as int or String
    String termId = _parseString(json['id']);

    // Handle sales_id
    String saleId = _parseString(json['sales_id']);

    // Handle customer_id - could be at top level or in sales object
    String custId = _parseString(
        json['customer_id'] ?? (json['sales']?['customer_id'] ?? ''));

    // Handle salesman_id - could be at top level or in sales object
    String smId = _parseString(
        json['salesman_id'] ?? (json['sales']?['salesman_id'] ?? ''));

    // Extract invoice from sales.invoice_number
    String invoice = _parseString(
        json['invoice'] ?? (json['sales']?['invoice_number'] ?? '-'));

    // Extract customer name from sales.customer.name
    String customerName = _parseString(json['customer'] ??
        (json['sales']?['customer']?['name'] ??
            (json['sales']?['customer_name'] ?? '-')));

    // Extract salesman name from sales.salesman.name
    String salesmanName = _parseString(json['salesman'] ??
        (json['sales']?['salesman']?['name'] ??
            (json['sales']?['salesman_name'] ?? '-')));

    // Parse amount and paid_amount (handle string values from API)
    final amount = _parseDouble(json['amount']);
    final paidAmount = _parseDouble(json['paid_amount']);

    // Calculate remaining: amount - paid_amount
    final remaining = amount - paidAmount;

    return SalesPaymentTermDataModel(
      id: termId,
      salesId: saleId,
      customerId: custId,
      salesmanId: smId,
      invoice: invoice,
      customerName: customerName,
      salesmanName: salesmanName,
      type: json['type'] ?? 'tempo',
      dueDate: json['due_date'],
      amount: amount,
      paidAmount: paidAmount,
      remaining: remaining,
      status: json['status'] ?? 'unpaid',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Get status badge color
  String getStatusColor() {
    switch (status) {
      case 'unpaid':
        return '#EF4444'; // red
      case 'partial':
        return '#FACC15'; // yellow
      case 'completed':
        return '#10B981'; // green
      default:
        return '#6B7280'; // gray
    }
  }

  // Get status label
  String getStatusLabel() {
    switch (status) {
      case 'unpaid':
        return 'Belum Bayar';
      case 'partial':
        return 'Sebagian';
      case 'completed':
        return 'Lunas';
      default:
        return status;
    }
  }

  // Get type label
  String getTypeLabel() {
    switch (type) {
      case 'tempo':
        return 'Tempo';
      case 'credit':
        return 'Kredit';
      case 'cash':
        return 'Tunai';
      default:
        return type;
    }
  }
}
