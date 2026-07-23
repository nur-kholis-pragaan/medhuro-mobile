import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/product_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/model/product_model.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:provider/provider.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';

class ProductPickerScreen extends StatefulWidget {
  final String title;
  final bool isReturnMode;

  const ProductPickerScreen({
    Key? key,
    this.title = 'Pilih Produk',
    this.isReturnMode = false,
  }) : super(key: key);

  @override
  _ProductPickerScreenState createState() => _ProductPickerScreenState();
}

class _ProductPickerScreenState extends State<ProductPickerScreen> {
  late ProductModel productModel;
  late Future<ProductModel?> future;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool loadNext = false;

  /// Qty counter untuk setiap product saat selection
  Map<int, int> productQtyCounter = {};

  /// Discount counter untuk setiap product saat selection
  Map<int, int> productDiscountCounter = {};

  /// TextEditingControllers untuk qty input per product
  Map<int, TextEditingController> qtyControllers = {};

  /// TextEditingControllers untuk discount input per product
  Map<int, TextEditingController> discountControllers = {};

  /// Selected unit per product (default: carton)
  Map<int, String> selectedUnit = {};

  Future<ProductModel?> getProductData({
    String? search,
    String? page,
    String? limit,
  }) async {
    return ProductApi().getProducts(
      search: search,
      page: page ?? "1",
      limit: limit ?? "20",
    );
  }

  @override
  void initState() {
    future = getProductData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
        } else {
          if (productModel.pagination != null &&
              productModel.pagination!.current_page <
                  productModel.pagination!.total_page) {
            setState(() {
              loadNext = true;
            });
            getProductData(
              search:
                  searchController.text.isEmpty ? null : searchController.text,
              page: (productModel.pagination!.current_page + 1).toString(),
            ).then((r) {
              setState(() {
                loadNext = false;
                productModel.pagination = r!.pagination;
                productModel.data.addAll(r.data);
              });
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    focusNode.dispose();
    qtyControllers.forEach((key, controller) => controller.dispose());
    discountControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  /// Get selected unit for product
  String _getSelectedUnit(int productId) => selectedUnit[productId] ?? 'carton';

  /// Get price based on unit
  int _getPriceForUnit(ProductDataModel product, String unit) {
    switch (unit) {
      case 'pack':
        return product.sellingPricePack;
      case 'pcs':
        return product.sellingPricePcs;
      default:
        return product.sellingPriceCarton;
    }
  }

  /// Get unit display label
  String _getUnitLabel(String unit) {
    switch (unit) {
      case 'carton':
        return 'Ctn';
      case 'pack':
        return 'Pkg';
      case 'pcs':
        return 'Pcs';
      default:
        return 'Ctn';
    }
  }

  /// Build tappable unit selector widget
  Widget _buildUnitSelector({
    required ProductDataModel product,
    required String unit,
    required String label,
    required int qty,
  }) {
    final isSelected = _getSelectedUnit(product.id) == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUnit[product.id] = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? PalletConfig.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              '$qty',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Safely get or create a controller for the given product
  TextEditingController _getQtyController(int productId, int currentQty) {
    if (!qtyControllers.containsKey(productId)) {
      qtyControllers[productId] = TextEditingController(
        text: currentQty.toString(),
      );
    }
    return qtyControllers[productId]!;
  }

  /// Safely get or create a discount controller for the given product
  TextEditingController _getDiscountController(int productId) {
    if (!discountControllers.containsKey(productId)) {
      discountControllers[productId] = TextEditingController(text: '0');
    }
    return discountControllers[productId]!;
  }

  void _addProduct(ProductDataModel product) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    int qty = productQtyCounter[product.id] ?? 0;
    int discount = productDiscountCounter[product.id] ?? 0;

    if (qty > 0) {
      if (widget.isReturnMode) {
        salesProvider.addReturnItem(
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          unit: _getSelectedUnit(product.id),
          qty: qty,
          price: _getPriceForUnit(product, _getSelectedUnit(product.id)),
          discountAmount: discount,
          sellingPriceCarton: product.sellingPriceCarton,
          sellingPricePack: product.sellingPricePack,
          sellingPricePcs: product.sellingPricePcs,
        );
      } else {
        salesProvider.addItem(
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          unit: _getSelectedUnit(product.id),
          qty: qty,
          price: _getPriceForUnit(product, _getSelectedUnit(product.id)),
          discountAmount: discount,
          sellingPriceCarton: product.sellingPriceCarton,
          sellingPricePack: product.sellingPricePack,
          sellingPricePcs: product.sellingPricePcs,
          costPriceCarton: product.costPriceCarton,
          costPricePack: product.costPricePack,
          costPricePcs: product.costPricePcs,
        );
      }

      // Reset counter
      setState(() {
        productQtyCounter[product.id] = 0;
        qtyControllers[product.id]?.text = '0';
        productDiscountCounter[product.id] = 0;
        discountControllers[product.id]?.text = '0';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan (${qty}x)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          widget.title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(PalletConfig.padding / 2),
            child: TextField(
              controller: searchController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            future = getProductData();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  future = getProductData(search: value);
                });
              },
            ),
          ),
          // Product List
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Tidak ada data'));
                } else {
                  productModel = snapshot.data;
                  if (productModel.data.isEmpty) {
                    return const Center(child: Text('Produk tidak ditemukan'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        future = getProductData(
                          search: searchController.text.isEmpty
                              ? null
                              : searchController.text,
                        );
                      });
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PalletConfig.padding / 2,
                        vertical: PalletConfig.padding / 2,
                      ),
                      itemCount: productModel.data.length + (loadNext ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (loadNext && index == productModel.data.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        ProductDataModel product = productModel.data[index];
                        int qty = productQtyCounter[product.id] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                PalletConfig.borderRadius),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Name & Code
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kode: ${product.code}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Price and Inventory Display
                                Row(
                                  children: [
                                    // Price Display
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsetsDirectional
                                            .symmetric(
                                            vertical: 16, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: PalletConfig.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: PalletConfig.primaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          'Harga (${_getUnitLabel(_getSelectedUnit(product.id))}): ${FormatterUtil.formatPriceWithCurrency(_getPriceForUnit(product, _getSelectedUnit(product.id)))}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Unit Selector (Inventory)
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: PalletConfig.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: PalletConfig.primaryColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildUnitSelector(
                                              product: product,
                                              unit: 'carton',
                                              label: 'Ctn',
                                              qty: product.inventory.qtyCarton,
                                            ),
                                            _buildUnitSelector(
                                              product: product,
                                              unit: 'pack',
                                              label: 'Pkg',
                                              qty: product.inventory.qtyPack,
                                            ),
                                            _buildUnitSelector(
                                              product: product,
                                              unit: 'pcs',
                                              label: 'Pcs',
                                              qty: product.inventory.qtyPcs,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Qty, Discount & Add Button (Single Row)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Qty Controls with label
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Qty:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        FormWidget().qtyControl(
                                          controller: _getQtyController(
                                              product.id, qty),
                                          value: qty,
                                          onChanged: (newQty) {
                                            setState(() {
                                              productQtyCounter[product.id] =
                                                  newQty;
                                            });
                                          },
                                          minValue: 0,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    // Discount Input with label
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Disc:',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          FormWidget().currencyInput(
                                            controller: _getDiscountController(
                                                product.id),
                                            label: '0',
                                            onChanged: (value) {
                                              setState(() {
                                                productDiscountCounter[
                                                    product.id] = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Add Button (with top padding to align)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: qty > 0
                                              ? PalletConfig.primaryColor
                                              : Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          onPressed: qty > 0
                                              ? () => _addProduct(product)
                                              : null,
                                          icon: const Icon(Icons.add,
                                              color: Colors.white, size: 22),
                                          tooltip: 'Tambah',
                                          constraints: const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<SalesProvider>(
        builder: (context, salesProvider, child) {
          int itemCount = widget.isReturnMode
              ? salesProvider.totalReturnItems
              : salesProvider.totalItems;

          return Container(
            padding: const EdgeInsets.all(PalletConfig.padding / 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount item dipilih',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PalletConfig.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
