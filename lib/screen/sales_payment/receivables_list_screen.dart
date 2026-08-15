import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/sales_payment_api.dart';
import 'package:medhuro_mobile/model/sales_payment_term_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales_payment/payment_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';

class ReceivablesListScreen extends StatefulWidget {
  @override
  _ReceivablesListScreenState createState() => _ReceivablesListScreenState();
}

class _ReceivablesListScreenState extends State<ReceivablesListScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  late SalesPaymentTermModel receivablesModel;
  late Future<SalesPaymentTermModel?> future;

  bool loadNext = false;

  TextEditingController search = TextEditingController();
  String? selectedStatus;
  DateTime? dueDateFrom;
  DateTime? dueDateTo;
  FocusNode focusNode = FocusNode();

  Timer? _debounce;

  // Status options
  final List<String> statusOptions = ['unpaid', 'partial', 'completed'];
  final Map<String, String> statusLabels = {
    'unpaid': 'Belum Bayar',
    'partial': 'Sebagian',
    'completed': 'Lunas',
  };

  Future<SalesPaymentTermModel?> getReceivablesData({
    String? customerId,
    String? status,
    String? dueFrom,
    String? dueTo,
    String? page,
    String? limit,
  }) async {
    return SalesPaymentApi().getReceivables(
      customerId: customerId,
      status: status,
      dueFrom: dueFrom,
      dueTo: dueTo,
      page: page ?? "1",
      limit: limit ?? "15",
    );
  }

  @override
  void initState() {
    super.initState();

    future = getReceivablesData();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          // bottom
          if (receivablesModel.pagination != null &&
              receivablesModel.pagination!.current_page <
                  receivablesModel.pagination!.total_page) {
            setState(() => loadNext = true);

            getReceivablesData(
              status: selectedStatus,
              dueFrom: dueDateFrom != null
                  ? DateFormat('yyyy-MM-dd').format(dueDateFrom!)
                  : null,
              dueTo: dueDateTo != null
                  ? DateFormat('yyyy-MM-dd').format(dueDateTo!)
                  : null,
              page: (receivablesModel.pagination!.current_page + 1).toString(),
            ).then((r) {
              if (r != null) {
                setState(() {
                  loadNext = false;
                  receivablesModel.pagination = r.pagination;
                  receivablesModel.data.addAll(r.data);
                });
              }
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    search.dispose();
    focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      future = getReceivablesData(
        status: selectedStatus,
        dueFrom: dueDateFrom != null
            ? DateFormat('yyyy-MM-dd').format(dueDateFrom!)
            : null,
        dueTo: dueDateTo != null
            ? DateFormat('yyyy-MM-dd').format(dueDateTo!)
            : null,
      );
    });
  }

  void _resetFilters() {
    setState(() {
      selectedStatus = null;
      dueDateFrom = null;
      dueDateTo = null;
      future = getReceivablesData();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: dueDateFrom != null && dueDateTo != null
          ? DateTimeRange(start: dueDateFrom!, end: dueDateTo!)
          : null,
    );

    if (picked != null) {
      setState(() {
        dueDateFrom = picked.start;
        dueDateTo = picked.end;
      });
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'unpaid':
        return PalletConfig.errorColor;
      case 'partial':
        return PalletConfig.warningColor;
      case 'completed':
        return PalletConfig.successColor;
      default:
        return PalletConfig.shadePrimaryColor;
    }
  }

  void _markAsPaid(SalesPaymentTermDataModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Pelunasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin melunasi piutang ini?'),
            SizedBox(height: 12),
            Text('Invoice: ${item.invoice}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sisa Piutang: ${_formatCurrency(item.remaining)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: PalletConfig.errorColor)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PalletConfig.successColor,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              _executeMarkAsPaid(int.parse(item.id));
            },
            child: Text('Ya, Lunasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeMarkAsPaid(int termId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final result = await SalesPaymentApi().markAsPaid(termId);

    Navigator.pop(context); // dismiss loading

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Piutang berhasil dilunasi'),
          backgroundColor: PalletConfig.successColor,
        ),
      );
      setState(() {
        future = getReceivablesData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Gagal melunasi piutang'),
          backgroundColor: PalletConfig.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          "Daftar Piutang",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentFormScreen(),
                ),
              ).then((_) {
                setState(() {
                  future = getReceivablesData();
                });
              });
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: PalletConfig.primaryColor,
                  child: const Text(
                    'Filter Piutang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Filter
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                PalletConfig.borderRadius),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('-- Semua Status --'),
                          ),
                          ...statusOptions.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(statusLabels[status] ?? status),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => selectedStatus = value);
                        },
                      ),
                      SizedBox(height: 12),

                      // Date Range Filter
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      PalletConfig.borderRadius),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dueDateFrom != null && dueDateTo != null
                                          ? '${DateFormat('dd MMM', 'id_ID').format(dueDateFrom!)} - ${DateFormat('dd MMM', 'id_ID').format(dueDateTo!)}'
                                          : 'Pilih Rentang',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Action Buttons
                      FormWidget().button(
                        icon: Icons.search,
                        label: 'Filter',
                        callBack: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        backgroundColor: PalletConfig.primaryColor,
                        height: 44,
                      ),
                      SizedBox(height: 8),
                      FormWidget().button(
                        icon: Icons.refresh,
                        label: 'Reset',
                        callBack: () {
                          _resetFilters();
                          Navigator.pop(context);
                        },
                        backgroundColor: PalletConfig.nutralColor,
                        height: 44,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          //  LIST
          Expanded(
            child: FutureBuilder<SalesPaymentTermModel?>(
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

                receivablesModel = snapshot.data!;

                if (receivablesModel.data.isEmpty) {
                  return const Center(
                    child: Text('Piutang tidak ditemukan'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      future = getReceivablesData();
                    });
                  },
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: PalletConfig.padding,
                      bottom: PalletConfig.padding,
                    ),
                    itemCount: receivablesModel.data.length +
                        (loadNext ? 1 : 0), // +1 untuk loader
                    separatorBuilder: (_, __) =>
                        SizedBox(height: PalletConfig.padding / 2),
                    itemBuilder: (context, index) {
                      // Show loader at bottom
                      if (index == receivablesModel.data.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(PalletConfig.padding),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final item = receivablesModel.data[index];

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.symmetric(
                          horizontal: PalletConfig.padding / 2,
                          vertical: PalletConfig.padding / 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            PalletConfig.borderRadius,
                          ),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            PalletConfig.borderRadius,
                          ),
                          onTap: () {
                            // Optional: show detail or navigate
                          },
                          child: Padding(
                            padding: EdgeInsets.all(PalletConfig.padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Invoice + Store + Status
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Invoice',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            item.invoice,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.salesDate != null &&
                                              item.salesDate!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                _formatDate(item.salesDate),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ),
                                          Text(
                                            item.customerName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item.status)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.getStatusLabel(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(item.status),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Amount Summary
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total',
                                              style: TextStyle(fontSize: 12)),
                                          Text(_formatCurrency(item.amount),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Sudah Bayar',
                                              style: TextStyle(fontSize: 12)),
                                          Text(_formatCurrency(item.paidAmount),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ],
                                      ),
                                      Divider(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Sisa',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text(_formatCurrency(item.remaining),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(
                                                    item.status),
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _markAsPaid(item),
                                          icon: Icon(Icons.check_circle,
                                              size: 16, color: Colors.white),
                                          label: Text('Lunas',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                PalletConfig.successColor,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
