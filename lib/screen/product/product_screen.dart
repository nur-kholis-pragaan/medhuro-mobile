import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/product_api.dart';
import 'package:medhuro_mobile/model/product_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/product/product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  GlobalKey<ScaffoldState> scafold_key = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  late ProductModel productModel;
  late Future<ProductModel?> future;

  bool loadNext = false;
  bool loadData = false;
  TextEditingController cari = TextEditingController();
  FocusNode focusNode = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafold_key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: Text("Produk",
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  productId: productModel.data[i].id,
                                ),
                              ));
                            },
                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(
                                horizontal: PalletConfig.padding / 2,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  PalletConfig.borderRadius,
                                ),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productModel.data[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Kode: ${productModel.data[i].code}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 16, color: Colors.grey),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Divider(height: 1),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Stok",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "C: ${productModel.data[i].inventory.qtyCarton}, P: ${productModel.data[i].inventory.qtyPack}, Pcs: ${productModel.data[i].inventory.qtyPcs}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    PalletConfig.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
    );
  }
}
