class PaginationModel {
  int per_page;
  int total_data;
  int total_page;
  int current_page;

  PaginationModel({
    required this.per_page,
    required this.total_data,
    required this.total_page,
    required this.current_page,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      per_page: json['per_page'] ?? 20,
      total_data: json['total_data'] ?? 0,
      total_page: json['total_page'] ?? 0,
      current_page: json['current_page'] ?? 1,
    );
  }
}
