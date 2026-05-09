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

class InventoryModel {
  int id;
  int productId;
  int qtyCarton;
  int qtyPack;
  int qtyPcs;
  String createdAt;
  String updatedAt;

  InventoryModel({
    required this.id,
    required this.productId,
    required this.qtyCarton,
    required this.qtyPack,
    required this.qtyPcs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InventoryModel(
        id: 0,
        productId: 0,
        qtyCarton: 0,
        qtyPack: 0,
        qtyPcs: 0,
        createdAt: '',
        updatedAt: '',
      );
    }
    return InventoryModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      qtyCarton: json['qty_carton'] ?? 0,
      qtyPack: json['qty_pack'] ?? 0,
      qtyPcs: json['qty_pcs'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ProductDataModel {
  int id;
  String name;
  String code;
  int brandId;
  int principleId;
  int packPerCarton;
  int pcsPerPack;
  int costPriceCarton;
  int costPricePack;
  int costPricePcs;
  int sellingPriceCarton;
  int sellingPricePack;
  int sellingPricePcs;
  int avgCostPcs;
  int isActive;
  InventoryModel inventory;
  String createdAt;
  String updatedAt;

  ProductDataModel({
    required this.id,
    required this.name,
    required this.code,
    required this.brandId,
    required this.principleId,
    required this.packPerCarton,
    required this.pcsPerPack,
    required this.costPriceCarton,
    required this.costPricePack,
    required this.costPricePcs,
    required this.sellingPriceCarton,
    required this.sellingPricePack,
    required this.sellingPricePcs,
    required this.avgCostPcs,
    required this.isActive,
    required this.inventory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      brandId: json['brand_id'] ?? 0,
      principleId: json['principle_id'] ?? 0,
      packPerCarton: json['pack_per_carton'] ?? 0,
      pcsPerPack: json['pcs_per_pack'] ?? 0,
      costPriceCarton: _parsePrice(json['cost_price_carton']),
      costPricePack: _parsePrice(json['cost_price_pack']),
      costPricePcs: _parsePrice(json['cost_price_pcs']),
      sellingPriceCarton: _parsePrice(json['selling_price_carton']),
      sellingPricePack: _parsePrice(json['selling_price_pack']),
      sellingPricePcs: _parsePrice(json['selling_price_pcs']),
      avgCostPcs: _parsePrice(json['avg_cost_pcs']),
      isActive: json['is_active'] ?? 0,
      inventory: InventoryModel.fromJson(json['inventory'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

int _parsePrice(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
