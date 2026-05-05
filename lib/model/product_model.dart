import './pagination_model.dart';

class ProductModel {
  List<ProductDataModel> data;
  PaginationModel? pagination;

  ProductModel({
    required this.data,
    required this.pagination,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      data: List<ProductDataModel>.from(json['data'].map((x) {
        return ProductDataModel.fromJson(x);
      })),
      pagination: json.containsKey("pagination")
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class ProductDataModel {
  int id;
  String name;
  String code;
  BrandModel? brand;
  PrincipleModel? principle;
  int price;
  int stock;
  int sellingPriceCarton;
  int sellingPricePack;
  int sellingPricePcs;
  String created_at;
  String updated_at;

  ProductDataModel({
    required this.id,
    required this.name,
    required this.code,
    this.brand,
    this.principle,
    required this.price,
    required this.stock,
    required this.sellingPriceCarton,
    required this.sellingPricePack,
    required this.sellingPricePcs,
    required this.created_at,
    required this.updated_at,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      brand: json['brand'] != null ? BrandModel.fromJson(json['brand']) : null,
      principle: json['principle'] != null
          ? PrincipleModel.fromJson(json['principle'])
          : null,
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      sellingPriceCarton: _parsePrice(json['selling_price_carton']),
      sellingPricePack: _parsePrice(json['selling_price_pack']),
      sellingPricePcs: _parsePrice(json['selling_price_pcs']),
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

int _parsePrice(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class BrandModel {
  int id;
  String name;

  BrandModel({
    required this.id,
    required this.name,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class PrincipleModel {
  int? id;
  String? name;

  PrincipleModel({
    required this.id,
    required this.name,
  });

  factory PrincipleModel.fromJson(Map<String, dynamic> json) {
    return PrincipleModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
