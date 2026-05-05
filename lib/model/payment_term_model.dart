class PaymentTermModel {
  List<PaymentTermDataModel> data;

  PaymentTermModel({
    required this.data,
  });

  factory PaymentTermModel.fromJson(Map<String, dynamic> json) {
    return PaymentTermModel(
      data: List<PaymentTermDataModel>.from(json['data'].map((x) {
        return PaymentTermDataModel.fromJson(x);
      })),
    );
  }
}

class PaymentTermDataModel {
  int id;
  String name;
  String type;
  int dueDays;
  int? installmentCount;
  int isActive;
  String created_at;
  String updated_at;

  PaymentTermDataModel({
    required this.id,
    required this.name,
    required this.type,
    required this.dueDays,
    this.installmentCount,
    required this.isActive,
    required this.created_at,
    required this.updated_at,
  });

  factory PaymentTermDataModel.fromJson(Map<String, dynamic> json) {
    return PaymentTermDataModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      dueDays: json['due_days'] ?? 0,
      installmentCount: json['installment_count'],
      isActive: json['is_active'] ?? 0,
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}
