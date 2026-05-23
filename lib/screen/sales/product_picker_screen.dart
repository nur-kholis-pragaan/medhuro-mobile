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
    super.dispose();
  }

  void _addProduct(ProductDataModel product) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    int qty = productQtyCounter[product.id] ?? 0;

    if (qty > 0) {
      if (widget.isReturnMode) {
        salesProvider.addReturnItem(
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          unit: 'carton',
          qty: qty,
          price: product.sellingPriceCarton,
          sellingPriceCarton: product.sellingPriceCarton,
          sellingPricePack: product.sellingPricePack,
          sellingPricePcs: product.sellingPricePcs,
        );
      } else {
        salesProvider.addItem(
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          unit: 'carton',
          qty: qty,
          price: product.sellingPriceCarton,
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
                                        padding: const EdgeInsets.all(12),
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
                                          'Harga: ${FormatterUtil.formatPriceWithCurrency(product.sellingPriceCarton)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Inventory Display
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
                                            Column(
                                              children: [
                                                Text(
                                                  'Ctn',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  '${product.inventory.qtyCarton}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Pkg',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  '${product.inventory.qtyPack}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Pcs',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  '${product.inventory.qtyPcs}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Qty Control
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Qty Controls
                                    FormWidget().qtyControl(
                                      value: qty,
                                      onChanged: (newQty) {
                                        setState(() {
                                          productQtyCounter[product.id] =
                                              newQty;
                                        });
                                      },
                                      minValue: 0,
                                    ),
                                    // Add Button
                                    ElevatedButton.icon(
                                      onPressed: qty > 0
                                          ? () => _addProduct(product)
                                          : null,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Tambah'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            PalletConfig.primaryColor,
                                        disabledBackgroundColor:
                                            Colors.grey.shade300,
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
