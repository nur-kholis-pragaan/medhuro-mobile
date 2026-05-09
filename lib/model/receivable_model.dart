import './pagination_model.dart';

class ReceivableModel {
  List<ReceivableSummaryData> data;
  PaginationModel? pagination;

  ReceivableModel({
    required this.data,
    required this.pagination,
  });

  factory ReceivableModel.fromJson(Map<String, dynamic> json) {
    return ReceivableModel(
      data: List<ReceivableSummaryData>.from(json['data'].map((x) {
        return ReceivableSummaryData.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class ReceivableSummaryData {
  String id;
  String code;
  String name;
  String phoneNumber;
  String address;
  String? cityName;
  int totalDebt;
  String createdAt;

  ReceivableSummaryData({
    required this.id,
    required this.code,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.cityName,
    required this.totalDebt,
    required this.createdAt,
  });

  factory ReceivableSummaryData.fromJson(Map<String, dynamic> json) {
    return ReceivableSummaryData(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      cityName: json['city_name'],
      totalDebt: json['total_debt'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
