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
  String totalAmountEffective;
  String returnAmount;
  String? paidAmount;
  String status;
  List<SalesItemModel> items;
  List<PaymentTermInfo> paymentTerms;
  SalesReturnInfo? salesReturn;
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
    required this.totalAmountEffective,
    required this.returnAmount,
    this.paidAmount,
    required this.status,
    required this.items,
    required this.paymentTerms,
    this.salesReturn,
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
      totalAmountEffective: json['total_amount_effective']?.toString() ?? '0',
      returnAmount: json['return_amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString(),
      status: json['status'] ?? '',
      items: List<SalesItemModel>.from(
        json['items'].map((x) => SalesItemModel.fromJson(x)),
      ),
      paymentTerms: List<PaymentTermInfo>.from(
        json['payment_terms'].map((x) => PaymentTermInfo.fromJson(x)),
      ),
      salesReturn: json['sales_return'] != null
          ? SalesReturnInfo.fromJson(json['sales_return'])
          : null,
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
  List<PaymentHistoryInfo> paymentItems;
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
    required this.paymentItems,
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
      paymentItems: json.containsKey('payment_items') &&
              json['payment_items'] != null
          ? List<PaymentHistoryInfo>.from(
              json['payment_items'].map((x) => PaymentHistoryInfo.fromJson(x)),
            )
          : [],
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

class PaymentHistoryInfo {
  int id;
  int paymentId;
  int paymentTermId;
  String amount;
  String? paymentDate;
  String? paymentMethod;
  String? referenceNumber;
  String? note;
  String? sourceType;
  String created_at;
  String updated_at;

  PaymentHistoryInfo({
    required this.id,
    required this.paymentId,
    required this.paymentTermId,
    required this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
    this.note,
    this.sourceType,
    required this.created_at,
    required this.updated_at,
  });

  factory PaymentHistoryInfo.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryInfo(
      id: json['id'] ?? 0,
      paymentId: json['sales_payment_id'] ?? 0,
      paymentTermId: json['sales_payment_term_id'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      paymentDate: json['payment']?['payment_date'],
      paymentMethod: json['payment']?['payment_method'] ?? 'Cash',
      referenceNumber: json['payment']?['reference_number'],
      note: json['payment']?['note'],
      sourceType: json['source_type'],
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

class SalesReturnInfo {
  int id;
  int salesId;
  String returnNumber;
  String returnDate;
  String totalAmount;
  List<SalesReturnItemInfo> items;
  String created_at;
  String updated_at;

  SalesReturnInfo({
    required this.id,
    required this.salesId,
    required this.returnNumber,
    required this.returnDate,
    required this.totalAmount,
    required this.items,
    required this.created_at,
    required this.updated_at,
  });

  factory SalesReturnInfo.fromJson(Map<String, dynamic> json) {
    return SalesReturnInfo(
      id: json['id'] ?? 0,
      salesId: json['sales_id'] ?? 0,
      returnNumber: json['return_number'] ?? '',
      returnDate: json['return_date'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      items: json.containsKey('items') && json['items'] != null
          ? List<SalesReturnItemInfo>.from(
              json['items'].map((x) => SalesReturnItemInfo.fromJson(x)),
            )
          : [],
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

class SalesReturnItemInfo {
  int id;
  int returnId;
  int productId;
  ProductInfo product;
  int qtyCarton;
  int qtyPack;
  int qtyPcs;
  String unit;
  String price;
  String subtotal;
  String? type;
  String created_at;
  String updated_at;

  SalesReturnItemInfo({
    required this.id,
    required this.returnId,
    required this.productId,
    required this.product,
    required this.qtyCarton,
    required this.qtyPack,
    required this.qtyPcs,
    required this.unit,
    required this.price,
    required this.subtotal,
    this.type,
    required this.created_at,
    required this.updated_at,
  });

  factory SalesReturnItemInfo.fromJson(Map<String, dynamic> json) {
    return SalesReturnItemInfo(
      id: json['id'] ?? 0,
      returnId: json['sales_return_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: ProductInfo.fromJson(json['product']),
      qtyCarton: json['qty_carton'] ?? 0,
      qtyPack: json['qty_pack'] ?? 0,
      qtyPcs: json['qty_pcs'] ?? 0,
      unit: json['unit'] ?? '',
      price: json['price']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
      type: json['type'],
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}
