import './pagination_model.dart';

class SalesModel {
  List<SalesDataModel> data;
  PaginationModel? pagination;

  SalesModel({
    required this.data,
    required this.pagination,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      data: List<SalesDataModel>.from(json['data'].map((x) {
        return SalesDataModel.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class SalesDataModel {
  int id;
  String invoiceNumber;
  int customerId;
  int salesmanId;
  CustomerInfo customer;
  SalesmanInfo salesman;
  String salesDate;
  String subtotalAmount;
  String discountAmount;
  String totalAmount;
  String? paidAmount;
  String status;
  List<SalesItemModel> items;
  List<PaymentTermInfo> paymentTerms;
  String created_at;
  String updated_at;

  SalesDataModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.salesmanId,
    required this.customer,
    required this.salesman,
    required this.salesDate,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.paidAmount,
    required this.status,
    required this.items,
    required this.paymentTerms,
    required this.created_at,
    required this.updated_at,
  });

  factory SalesDataModel.fromJson(Map<String, dynamic> json) {
    return SalesDataModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      customerId: json['customer_id'] ?? 0,
      salesmanId: json['salesman_id'] ?? 0,
      customer: CustomerInfo.fromJson(json['customer']),
      salesman: SalesmanInfo.fromJson(json['salesman']),
      salesDate: json['sales_date'] ?? '',
      subtotalAmount: json['subtotal_amount']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString(),
      status: json['status'] ?? '',
      items: List<SalesItemModel>.from(
        json['items'].map((x) => SalesItemModel.fromJson(x)),
      ),
      paymentTerms: List<PaymentTermInfo>.from(
        json['payment_terms'].map((x) => PaymentTermInfo.fromJson(x)),
      ),
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

class SalesItemModel {
  int id;
  int productId;
  ProductInfo product;
  int qtyCarton;
  String price;
  String discountAmount;
  String subtotal;

  SalesItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.qtyCarton,
    required this.price,
    required this.discountAmount,
    required this.subtotal,
  });

  factory SalesItemModel.fromJson(Map<String, dynamic> json) {
    return SalesItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: ProductInfo.fromJson(json['product']),
      qtyCarton: json['qty_carton'] ?? 0,
      price: json['price']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
    );
  }
}

class CustomerInfo {
  int id;
  String name;
  String code;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class SalesmanInfo {
  int id;
  String name;

  SalesmanInfo({
    required this.id,
    required this.name,
  });

  factory SalesmanInfo.fromJson(Map<String, dynamic> json) {
    return SalesmanInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ProductInfo {
  int id;
  String code;
  String name;

  ProductInfo({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PaymentTermInfo {
  int id;
  int salesId;
  int paymentTermsId;
  String name;
  String type;
  String amount;
  String paidAmount;
  int remainingAmount;
  String? dueDate;
  String status;
  String created_at;
  String updated_at;

  PaymentTermInfo({
    required this.id,
    required this.salesId,
    required this.paymentTermsId,
    required this.name,
    required this.type,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    this.dueDate,
    required this.status,
    required this.created_at,
    required this.updated_at,
  });

  factory PaymentTermInfo.fromJson(Map<String, dynamic> json) {
    return PaymentTermInfo(
      id: json['id'] ?? 0,
      salesId: json['sales_id'] ?? 0,
      paymentTermsId: json['payment_terms_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      remainingAmount: json['remaining_amount'] ?? 0,
      dueDate: json['due_date'],
      status: json['status'] ?? '',
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}
