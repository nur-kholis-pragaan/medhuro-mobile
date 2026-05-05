import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/product_api.dart';
import 'package:medhuro_mobile/model/product_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class CreateSalesScreen extends StatefulWidget {
  @override
  _CreateSalesScreenState createState() => _CreateSalesScreenState();
}

class _CreateSalesScreenState extends State<CreateSalesScreen> {
  GlobalKey<ScaffoldState> scafold_key = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  late ProductModel productModel;
  late Future<ProductModel?> future;

  bool loadNext = false;
  TextEditingController cari = TextEditingController();
  FocusNode focusNode = FocusNode();

  // For add to cart
  int? selectedProductIndex;
  String selectedUnit = 'carton';
  int qtyInput = 1;

  Future<ProductModel?> getProductData({
    String? search,
    String? page,
    String? limit,
  }) async {
    return ProductApi().getProducts(
      search: search,
      page: page == null ? "1" : page,
      limit: limit == null ? "20" : limit,
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
              search: cari.text.isEmpty ? null : cari.text,
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
    cari.dispose();
    focusNode.dispose();
    super.dispose();
  }

  int _getPriceForUnit(ProductDataModel product, String unit) {
    switch (unit) {
      case 'carton':
        return product.sellingPriceCarton;
      case 'pack':
        return product.sellingPricePack;
      case 'pcs':
        return product.sellingPricePcs;
      default:
        return product.sellingPriceCarton;
    }
  }

  void _showAddToCartDialog(ProductDataModel product) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int price = _getPriceForUnit(product, selectedUnit);
            int subtotal = price * qtyInput;

            return AlertDialog(
              title: Text(product.name),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode: ${product.code}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pilih Unit:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    FormWidget().dropdown<String>(
                      value: selectedUnit,
                      label: 'Unit',
                      items: [
                        DropdownMenuItem(
                          value: 'carton',
                          child: Text(
                              'Carton (Rp. ${FormatterUtil.formatPrice(product.sellingPriceCarton)})'),
                        ),
                        DropdownMenuItem(
                          value: 'pack',
                          child: Text(
                              'Pack (Rp. ${FormatterUtil.formatPrice(product.sellingPricePack)})'),
                        ),
                        DropdownMenuItem(
                          value: 'pcs',
                          child: Text(
                              'Pcs (Rp. ${FormatterUtil.formatPrice(product.sellingPricePcs)})'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Qty:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FormWidget().iconButton(
                          icon: Icons.remove,
                          onPressed: () {
                            setState(() {
                              if (qtyInput > 1) qtyInput--;
                            });
                          },
                          color: PalletConfig.primaryColor,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FormWidget().numericInput(
                              controller: TextEditingController(
                                text: qtyInput.toString(),
                              ),
                              label: 'Qty',
                              minValue: 1,
                              onChanged: (value) {
                                setState(() {
                                  qtyInput = value;
                                });
                              },
                            ),
                          ),
                        ),
                        FormWidget().iconButton(
                          icon: Icons.add,
                          onPressed: () {
                            setState(() {
                              qtyInput++;
                            });
                          },
                          color: PalletConfig.primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PalletConfig.primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(PalletConfig.borderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            FormatterUtil.formatPriceWithCurrency(subtotal),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: PalletConfig.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PalletConfig.primaryColor,
                  ),
                  onPressed: () {
                    final salesProvider =
                        Provider.of<SalesProvider>(context, listen: false);
                    salesProvider.addItem(
                      productId: product.id,
                      productName: product.name,
                      productCode: product.code,
                      unit: selectedUnit,
                      qty: qtyInput,
                      price: price,
                    );

                    Navigator.pop(context);
                    qtyInput = 1;
                    selectedUnit = 'carton';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} ditambahkan ke cart'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'Tambah ke Cart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafold_key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: Text("Buat Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(PalletConfig.padding / 2),
            child: TextField(
              controller: cari,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  future = getProductData(search: value);
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Tidak ada data'),
                  );
                } else {
                  productModel = snapshot.data;
                  if (productModel.data.isEmpty) {
                    return Center(
                      child: Text('Produk tidak ditemukan'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        future = getProductData(
                          search: cari.text.isEmpty ? null : cari.text,
                        );
                      });
                    },
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      padding: EdgeInsets.only(top: PalletConfig.padding / 2),
                      itemCount: productModel.data.length,
                      itemBuilder: (BuildContext context, int i) {
                        if (loadNext && i == productModel.data.length - 1) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          ProductDataModel product = productModel.data[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PalletConfig.padding / 2,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  PalletConfig.borderRadius,
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Kode: ${product.code}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    FormWidget().iconButton(
                                      icon: Icons.add,
                                      onPressed: () {
                                        _showAddToCartDialog(product);
                                      },
                                      color: PalletConfig.primaryColor,
                                      tooltip: 'Tambah ke cart',
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
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
          if (salesProvider.totalItems == 0) {
            return SizedBox.shrink();
          }
          return Container(
            padding: EdgeInsets.all(PalletConfig.padding / 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cart (${salesProvider.totalItems} item)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Total: ${FormatterUtil.formatPriceWithCurrency(salesProvider.totalAmount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PalletConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                FormWidget().button(
                  icon: Icons.arrow_forward,
                  label: 'Lihat Cart',
                  callBack: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ));
                  },
                  width: 140,
                  height: 44,
                  backgroundColor: PalletConfig.primaryColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
