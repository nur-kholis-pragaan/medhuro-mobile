import './pagination_model.dart';

class PaymentMethodModel {
  List<PaymentMethodDataModel> data;
  PaginationModel? pagination;

  PaymentMethodModel({
    required this.data,
    required this.pagination,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      data: List<PaymentMethodDataModel>.from(json['data'].map((x) {
        return PaymentMethodDataModel.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class PaymentMethodDataModel {
  String id;
  String code;
  String name;
  int isActive;
  String createdAt;
  String updatedAt;

  PaymentMethodDataModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodDataModel.fromJson(Map<String, dynamic> json) {
    // Handle id as int or String
    String methodId = '';
    if (json['id'] != null) {
      methodId = json['id'].toString();
    }

    // Handle is_active as bool or int
    int isActive = 1;
    if (json['is_active'] != null) {
      if (json['is_active'] is bool) {
        isActive = json['is_active'] ? 1 : 0;
      } else if (json['is_active'] is int) {
        isActive = json['is_active'];
      }
    }

    return PaymentMethodDataModel(
      id: methodId,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      isActive: isActive,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
