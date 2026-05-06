import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/product_api.dart';
import 'package:medhuro_mobile/model/product_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDataModel?> future;

  @override
  void initState() {
    future = ProductApi().getProductDetail(widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Detail Produk",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: FutureBuilder(
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
              child: Text('Produk tidak ditemukan'),
            );
          } else {
            ProductDataModel product = snapshot.data;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PalletConfig.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: PalletConfig.shadeSecondary,
                        borderRadius:
                            BorderRadius.circular(PalletConfig.borderRadius),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: PalletConfig.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: PalletConfig.padding),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: PalletConfig.fontLargeSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: PalletConfig.primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(PalletConfig.borderRadius),
                      ),
                      child: Text(
                        product.code,
                        style: TextStyle(
                          color: PalletConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: PalletConfig.padding),
                    Card(
                      elevation: 0,
                      color: PalletConfig.shadeSecondary,
                      child: Padding(
                        padding: const EdgeInsets.all(PalletConfig.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Nama", product.name),
                            Divider(height: 16),
                            _buildInfoRow("Kode", product.code),
                            Divider(height: 16),
                            _buildInfoRow("Brand", product.name),
                            Divider(height: 16),
                            _buildInfoRow(
                              "Prinsip",
                              product.name,
                            ),
                            Divider(height: 16),
                            _buildInfoRow("Harga", "Rp. ${product.price}"),
                            Divider(height: 16),
                            _buildInfoRow(
                              "Stok",
                              "${product.stock}",
                              valueColor: PalletConfig.successColor,
                            ),
                            Divider(height: 16),
                            _buildInfoRow(
                              "Dibuat",
                              product.created_at,
                              fontSize: 12,
                            ),
                            Divider(height: 16),
                            _buildInfoRow(
                              "Diperbarui",
                              product.updated_at,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: PalletConfig.padding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PalletConfig.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PalletConfig.borderRadius,
                            ),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement order action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pesan ${product.name}'),
                            ),
                          );
                        },
                        child: Text(
                          'Pesan Produk',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    double fontSize = 14,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: PalletConfig.shadePrimaryColor,
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? PalletConfig.shadePrimaryColor,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
