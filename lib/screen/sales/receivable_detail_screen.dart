import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/receivable_api.dart';
import 'package:medhuro_mobile/model/receivable_detail_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class ReceivableDetailScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const ReceivableDetailScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  _ReceivableDetailScreenState createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends State<ReceivableDetailScreen> {
  ScrollController scrollController = ScrollController();

  late ReceivableDetailModel receivableDetailModel;
  late Future<ReceivableDetailModel?> future;

  bool loadNext = false;

  Future<ReceivableDetailModel?> getReceivableDetailData({
    String? page,
    String? limit,
  }) async {
    return ReceivableApi().getReceivableDetail(
      widget.customerId,
      page: page ?? "1",
      limit: limit ?? "20",
      sortBy: 'due_date',
      sort: 'asc',
    );
  }

  @override
  void initState() {
    super.initState();

    future = getReceivableDetailData();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          // bottom
          if (receivableDetailModel.pagination != null &&
              receivableDetailModel.pagination!.current_page <
                  receivableDetailModel.pagination!.total_page) {
            setState(() => loadNext = true);

            getReceivableDetailData(
              page: (receivableDetailModel.pagination!.current_page + 1)
                  .toString(),
            ).then((r) {
              setState(() {
                loadNext = false;
                receivableDetailModel.pagination = r!.pagination;
                receivableDetailModel.data.addAll(r.data);
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
      case 'pending':
        return PalletConfig.warningColor.value.toRadixString(16);
      case 'partial':
        return PalletConfig.warningColor.value.toRadixString(16);
      case 'completed':
        return PalletConfig.successColor.value.toRadixString(16);
      default:
        return PalletConfig.shadePrimaryColor.value.toRadixString(16);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PalletConfig.warningColor.withOpacity(0.1);
      case 'partial':
        return PalletConfig.warningColor.withOpacity(0.1);
      case 'completed':
        return PalletConfig.successColor.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PalletConfig.warningColor;
      case 'partial':
        return PalletConfig.warningColor;
      case 'completed':
        return PalletConfig.successColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Piutang - ${widget.customerName}",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: FutureBuilder<ReceivableDetailModel?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tidak ada data'));
          }

          receivableDetailModel = snapshot.data!;

          if (receivableDetailModel.data.isEmpty) {
            return const Center(
              child: Text('Tidak ada rincian piutang'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                future = getReceivableDetailData();
              });
            },
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(PalletConfig.padding / 2),
              itemCount: receivableDetailModel.data.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
              itemBuilder: (context, i) {
                final receivable = receivableDetailModel.data[i];

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(PalletConfig.padding / 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan Tanggal dan Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tgl. Penjualan: ${receivable.salesDate}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jatuh Tempo: ${receivable.dueDate}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(receivable.status),
                                  borderRadius: BorderRadius.circular(
                                    PalletConfig.borderRadius / 2,
                                  ),
                                ),
                                child: Text(
                                  receivable.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _getStatusTextColor(receivable.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Payment Term
                          Text(
                            receivable.paymentTerm,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PalletConfig.shadePrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Amount Info
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                PalletConfig.borderRadius,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      'Rp. ${FormatterUtil.formatPrice(receivable.totalAmount)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Terbayar:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      'Rp. ${FormatterUtil.formatPrice(receivable.paidAmount)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: PalletConfig.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sisa Hutang:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Rp. ${FormatterUtil.formatPrice(receivable.outstandingAmount)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: receivable.outstandingAmount > 0
                                            ? PalletConfig.errorColor
                                            : PalletConfig.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (loadNext && i == receivableDetailModel.data.length - 1)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
