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
  String id;
  String code;
  String name;
  String phoneNumber;
  String address;
  String? cityName;
  double? latitude;
  double? longitude;
  int isActive;
  String createdAt;
  String updatedAt;

  CustomerDataModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.cityName,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerDataModel.fromJson(Map<String, dynamic> json) {
    // Handle id as int or String from API
    String customerId = '';
    if (json['id'] != null) {
      customerId = json['id'].toString();
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

    return CustomerDataModel(
      id: customerId,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      cityName: json['city_name'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isActive: isActive,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'city_name': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
}
