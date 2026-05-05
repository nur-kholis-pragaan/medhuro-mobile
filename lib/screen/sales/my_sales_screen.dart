import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/model/sales_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/sales_detail_screen.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class MySalesScreen extends StatefulWidget {
  @override
  _MySalesScreenState createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  ScrollController scrollController = ScrollController();
  late SalesModel salesModel;
  late Future<SalesModel?> future;
  bool loadNext = false;

  Future<SalesModel?> getSalesData({
    String? page,
    String? limit,
  }) async {
    return SalesApi().getMySales(
      page: page ?? "1",
      limit: limit ?? "15",
    );
  }

  @override
  void initState() {
    future = getSalesData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
        } else {
          if (salesModel.pagination != null &&
              salesModel.pagination!.current_page <
                  salesModel.pagination!.total_page) {
            setState(() {
              loadNext = true;
            });
            getSalesData(
              page: (salesModel.pagination!.current_page + 1).toString(),
            ).then((r) {
              setState(() {
                loadNext = false;
                salesModel.pagination = r!.pagination;
                salesModel.data.addAll(r.data);
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
    super.dispose();
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PalletConfig.successColor.toString();
      case 'pending':
        return PalletConfig.warningColor.toString();
      case 'cancelled':
        return PalletConfig.errorColor.toString();
      default:
        return Colors.grey.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: Text("Penjualan Saya",
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
              child: Text('Tidak ada data'),
            );
          } else {
            salesModel = snapshot.data;
            if (salesModel.data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Belum ada penjualan'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  future = getSalesData();
                });
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                padding: EdgeInsets.all(PalletConfig.padding / 2),
                itemCount: salesModel.data.length,
                itemBuilder: (BuildContext context, int i) {
                  if (loadNext && i == salesModel.data.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    SalesDataModel sale = salesModel.data[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SalesDetailScreen(salesId: sale.id),
                        ));
                      },
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 6),
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
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sale.invoiceNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          sale.customer.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sale.status.toLowerCase() ==
                                              'completed'
                                          ? PalletConfig.successColor
                                              .withOpacity(0.1)
                                          : PalletConfig.warningColor
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      sale.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: sale.status.toLowerCase() ==
                                                'completed'
                                            ? PalletConfig.successColor
                                            : PalletConfig.warningColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                        'Tanggal:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        sale.salesDate.split('T')[0],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        FormatterUtil.formatPriceWithCurrency(
                                            sale.totalAmount),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: PalletConfig.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${sale.items.length} item',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
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
    );
  }
}
