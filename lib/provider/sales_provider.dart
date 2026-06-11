import 'package:flutter/foundation.dart';

/// Model untuk item penjualan (sales)
class SalesItem {
  int productId;
  String productName;
  String productCode;
  String unit; // carton, pack, pcs
  int qty;
  int price; // harga per unit
  int discountAmount;
  int sellingPriceCarton;
  int sellingPricePack;
  int sellingPricePcs;
  int costPriceCarton;
  int costPricePack;
  int costPricePcs;

  SalesItem({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.unit,
    required this.qty,
    required this.price,
    required this.discountAmount,
    this.sellingPriceCarton = 0,
    this.sellingPricePack = 0,
    this.sellingPricePcs = 0,
    this.costPriceCarton = 0,
    this.costPricePack = 0,
    this.costPricePcs = 0,
  });

  int get subtotal {
    return (price * qty) - (discountAmount * qty);
  }

  int get totalPrice {
    return price * qty;
  }

  int get totalDiscount {
    return discountAmount * qty;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'unit': unit,
      'qty': qty,
      'price': price,
      'discount_amount': discountAmount,
    };
  }
}

/// Model untuk item retur (return)
class ReturnItem {
  int productId;
  String productName;
  String productCode;
  String unit; // carton, pack, pcs
  int qty;
  int price; // harga per unit
  int discountAmount;
  String type; // gs (good stock) atau bs (bad stock)
  int sellingPriceCarton;
  int sellingPricePack;
  int sellingPricePcs;

  ReturnItem({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.unit,
    required this.qty,
    required this.price,
    required this.discountAmount,
    this.type = 'gs',
    this.sellingPriceCarton = 0,
    this.sellingPricePack = 0,
    this.sellingPricePcs = 0,
  });

  int get subtotal {
    return (price * qty) - (discountAmount * qty);
  }

  int get totalPrice {
    return price * qty;
  }

  int get totalDiscount {
    return discountAmount * qty;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'unit': unit,
      'qty': qty,
      'price': price,
      'discount_amount': discountAmount,
      'type': type,
    };
  }
}

/// Backward compatibility
typedef CartItem = SalesItem;

class SalesProvider with ChangeNotifier {
  List<SalesItem> _items = [];
  List<ReturnItem> _returnItems = [];
  int _cashAmount = 0;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  int? _selectedPaymentTermId;
  DateTime _selectedDate = DateTime.now();
  int _transactionDiscount = 0;

  // Getters
  List<SalesItem> get items => _items;
  List<ReturnItem> get returnItems => _returnItems;
  int get cashAmount => _cashAmount;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  int? get selectedPaymentTermId => _selectedPaymentTermId;
  DateTime get selectedDate => _selectedDate;
  int get transactionDiscount => _transactionDiscount;

  int get totalItems => _items.length;
  int get totalReturnItems => _returnItems.length;

  /// Total dari semua sales items
  int get totalSales {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Total dari semua return items
  int get totalReturn {
    return _returnItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Net payment = Total Sales - Cash Amount
  /// Ini adalah sisa hutang
  int get remainingAmount {
    return totalSales - _cashAmount;
  }

  /// Total discount dari sales items
  int get totalDiscount {
    return _items.fold(0, (sum, item) => sum + item.discountAmount);
  }

  /// Total discount dari return items
  int get totalReturnDiscount {
    return _returnItems.fold(0, (sum, item) => sum + item.discountAmount);
  }

  /// Subtotal sales sebelum diskon
  int get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  /// Subtotal return sebelum diskon
  int get subtotalReturn {
    return _returnItems.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  /// Total amount (backward compatibility with old code)
  int get totalAmount => totalSales;

  /// Tambah sales item
  void addItem({
    required int productId,
    required String productName,
    required String productCode,
    required String unit,
    required int qty,
    required int price,
    int discountAmount = 0,
    int sellingPriceCarton = 0,
    int sellingPricePack = 0,
    int sellingPricePcs = 0,
    int costPriceCarton = 0,
    int costPricePack = 0,
    int costPricePcs = 0,
  }) {
    // Check if same product with same unit already exists
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId && item.unit == unit,
    );

    if (existingIndex >= 0) {
      // Update qty if exists
      _items[existingIndex].qty += qty;
    } else {
      // Add new item
      _items.add(
        SalesItem(
          productId: productId,
          productName: productName,
          productCode: productCode,
          unit: unit,
          qty: qty,
          price: price,
          discountAmount: discountAmount,
          sellingPriceCarton: sellingPriceCarton,
          sellingPricePack: sellingPricePack,
          sellingPricePcs: sellingPricePcs,
          costPriceCarton: costPriceCarton,
          costPricePack: costPricePack,
          costPricePcs: costPricePcs,
        ),
      );
    }
    notifyListeners();
  }

  /// Update sales item
  void updateItem(int index, int qty, int discountAmount) {
    if (index >= 0 && index < _items.length) {
      _items[index].qty = qty;
      _items[index].discountAmount = discountAmount;
      notifyListeners();
    }
  }

  /// Update harga sales item
  void updateItemPrice(int index, int price) {
    if (index >= 0 && index < _items.length) {
      _items[index].price = price;
      notifyListeners();
    }
  }

  /// Update unit sales item dan reset harga ke default
  void updateItemUnit(int index, String newUnit, int defaultPrice) {
    if (index >= 0 && index < _items.length) {
      _items[index].unit = newUnit;
      _items[index].price = defaultPrice;
      notifyListeners();
    }
  }

  /// Remove sales item
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Tambah return item
  void addReturnItem({
    required int productId,
    required String productName,
    required String productCode,
    required String unit,
    required int qty,
    required int price,
    int discountAmount = 0,
    String type = 'gs',
    int sellingPriceCarton = 0,
    int sellingPricePack = 0,
    int sellingPricePcs = 0,
  }) {
    // Check if same product with same unit already exists
    final existingIndex = _returnItems.indexWhere(
      (item) => item.productId == productId && item.unit == unit,
    );

    if (existingIndex >= 0) {
      // Update qty if exists
      _returnItems[existingIndex].qty += qty;
    } else {
      // Add new item
      _returnItems.add(
        ReturnItem(
          productId: productId,
          productName: productName,
          productCode: productCode,
          unit: unit,
          qty: qty,
          price: price,
          discountAmount: discountAmount,
          type: type,
          sellingPriceCarton: sellingPriceCarton,
          sellingPricePack: sellingPricePack,
          sellingPricePcs: sellingPricePcs,
        ),
      );
    }
    notifyListeners();
  }

  /// Update return item
  void updateReturnItem(int index, int qty, int discountAmount) {
    if (index >= 0 && index < _returnItems.length) {
      _returnItems[index].qty = qty;
      _returnItems[index].discountAmount = discountAmount;
      notifyListeners();
    }
  }

  /// Update harga return item
  void updateReturnItemPrice(int index, int price) {
    if (index >= 0 && index < _returnItems.length) {
      _returnItems[index].price = price;
      notifyListeners();
    }
  }

  /// Update unit return item dan reset harga ke default
  void updateReturnItemUnit(int index, String newUnit, int defaultPrice) {
    if (index >= 0 && index < _returnItems.length) {
      _returnItems[index].unit = newUnit;
      _returnItems[index].price = defaultPrice;
      notifyListeners();
    }
  }

  /// Update type return item (gs atau bs)
  void updateReturnItemType(int index, String type) {
    if (index >= 0 && index < _returnItems.length) {
      _returnItems[index].type = type;
      notifyListeners();
    }
  }

  /// Remove return item
  void removeReturnItem(int index) {
    if (index >= 0 && index < _returnItems.length) {
      _returnItems.removeAt(index);
      notifyListeners();
    }
  }

  /// Set cash amount (pembayaran tunai)
  void setCashAmount(int amount) {
    _cashAmount = amount;
    notifyListeners();
  }

  /// Persist header info (customer, payment term, date, discount)
  void setHeaderInfo({
    required String customerId,
    String? customerName,
    required int paymentTermId,
    required DateTime salesDate,
    required int transactionDiscount,
  }) {
    _selectedCustomerId = customerId;
    _selectedCustomerName = customerName;
    _selectedPaymentTermId = paymentTermId;
    _selectedDate = salesDate;
    _transactionDiscount = transactionDiscount;
    notifyListeners();
  }

  /// Clear semua data
  void clear() {
    _items.clear();
    _returnItems.clear();
    _cashAmount = 0;
    notifyListeners();
  }

  /// Get sales item by index
  SalesItem? getItem(int index) {
    if (index >= 0 && index < _items.length) {
      return _items[index];
    }
    return null;
  }

  /// Get return item by index
  ReturnItem? getReturnItem(int index) {
    if (index >= 0 && index < _returnItems.length) {
      return _returnItems[index];
    }
    return null;
  }
}
