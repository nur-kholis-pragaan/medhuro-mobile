import './pagination_model.dart';

class ReceivableDetailModel {
  List<ReceivableDetailData> data;
  PaginationModel? pagination;
  CustomerInfo? customer;

  ReceivableDetailModel({
    required this.data,
    required this.pagination,
    this.customer,
  });

  factory ReceivableDetailModel.fromJson(Map<String, dynamic> json) {
    return ReceivableDetailModel(
      data: List<ReceivableDetailData>.from(json['data'].map((x) {
        return ReceivableDetailData.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
      customer: json.containsKey("customer")
          ? CustomerInfo.fromJson(json['customer'])
          : null,
    );
  }
}

class ReceivableDetailData {
  String id;
  CustomerInfo customer;
  String salesId;
  String salesDate;
  String paymentTerm;
  String paymentType;
  int totalAmount;
  int paidAmount;
  int outstandingAmount;
  String dueDate;
  String status;
  String createdAt;
  String updatedAt;

  ReceivableDetailData({
    required this.id,
    required this.customer,
    required this.salesId,
    required this.salesDate,
    required this.paymentTerm,
    required this.paymentType,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReceivableDetailData.fromJson(Map<String, dynamic> json) {
    return ReceivableDetailData(
      id: json['id'].toString(),
      customer: CustomerInfo.fromJson(json['customer']),
      salesId: json['sales_id'].toString(),
      salesDate: json['sales_date'] ?? '',
      paymentTerm: json['payment_term'] ?? '',
      paymentType: json['payment_type'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      paidAmount: json['paid_amount'] ?? 0,
      outstandingAmount: json['outstanding_amount'] ?? 0,
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CustomerInfo {
  String id;
  String code;
  String name;
  String phoneNumber;
  String address;

  CustomerInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.phoneNumber,
    required this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
