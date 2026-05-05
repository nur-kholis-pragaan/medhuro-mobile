import './pagination_model.dart';

class CustomerModel {
  List<CustomerDataModel> data;
  PaginationModel? pagination;

  CustomerModel({
    required this.data,
    required this.pagination,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      data: List<CustomerDataModel>.from(json['data'].map((x) {
        return CustomerDataModel.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class CustomerDataModel {
  int id;
  String code;
  String name;
  String phoneNumber;
  String address;
  String cityName;
  String latitude;
  String longitude;
  int isActive;
  String created_at;
  String updated_at;

  CustomerDataModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.created_at,
    required this.updated_at,
  });

  factory CustomerDataModel.fromJson(Map<String, dynamic> json) {
    return CustomerDataModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      cityName: json['city_name'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      isActive: json['is_active'] ?? 0,
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}
