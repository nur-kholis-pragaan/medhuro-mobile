import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/model/sales_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/sales_detail_screen.dart';
import 'package:medhuro_mobile/screen/sales/customer_picker_screen.dart';
import 'package:medhuro_mobile/screen/sales/sales_wizard_screen.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MySalesScreen extends StatefulWidget {
  @override
  _MySalesScreenState createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  late SalesModel salesModel;
  late Future<SalesModel?> future;
  bool loadNext = false;

  TextEditingController searchController = TextEditingController();
  String? selectedCustomerId;
  String? selectedCustomerName;
  DateTime? salesDateFrom;
  DateTime? salesDateTo;
  FocusNode focusNode = FocusNode();

  Timer? _debounce;

  Future<SalesModel?> getSalesData({
    String? search,
    String? customerId,
    String? dateFrom,
    String? dateTo,
    String? page,
    String? limit,
  }) async {
    return SalesApi().getMySales(
      search: search,
      customerId: customerId,
      dateFrom: dateFrom,
      dateTo: dateTo,
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
              search:
                  searchController.text.isEmpty ? null : searchController.text,
              customerId: selectedCustomerId,
              dateFrom: salesDateFrom != null
                  ? DateFormat('yyyy-MM-dd').format(salesDateFrom!)
                  : null,
              dateTo: salesDateTo != null
                  ? DateFormat('yyyy-MM-dd').format(salesDateTo!)
                  : null,
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
    searchController.dispose();
    focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        future = getSalesData(
          search: value.isEmpty ? null : value,
          customerId: selectedCustomerId,
          dateFrom: salesDateFrom != null
              ? DateFormat('yyyy-MM-dd').format(salesDateFrom!)
              : null,
          dateTo: salesDateTo != null
              ? DateFormat('yyyy-MM-dd').format(salesDateTo!)
              : null,
        );
      });
    });
  }

  void _applyFilters() {
    setState(() {
      future = getSalesData(
        search: searchController.text.isEmpty ? null : searchController.text,
        customerId: selectedCustomerId,
        dateFrom: salesDateFrom != null
            ? DateFormat('yyyy-MM-dd').format(salesDateFrom!)
            : null,
        dateTo: salesDateTo != null
            ? DateFormat('yyyy-MM-dd').format(salesDateTo!)
            : null,
      );
    });
  }

  void _resetFilters() {
    setState(() {
      searchController.clear();
      selectedCustomerId = null;
      selectedCustomerName = null;
      salesDateFrom = null;
      salesDateTo = null;
      future = getSalesData();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: salesDateFrom != null && salesDateTo != null
          ? DateTimeRange(start: salesDateFrom!, end: salesDateTo!)
          : null,
    );

    if (picked != null) {
      setState(() {
        salesDateFrom = picked.start;
        salesDateTo = picked.end;
      });
    }
  }

  Future<void> _selectCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerPickerScreen(
          initialCustomerId: selectedCustomerId,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCustomerId = result.id;
        selectedCustomerName = result.name;
      });
    }
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
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 1,
        title: Text("Penjualan Saya",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => SalesWizardScreen(),
              ))
                  .then((_) {
                setState(() {
                  future = getSalesData(
                    search: searchController.text.isEmpty
                        ? null
                        : searchController.text,
                    customerId: selectedCustomerId,
                    dateFrom: salesDateFrom != null
                        ? DateFormat('yyyy-MM-dd').format(salesDateFrom!)
                        : null,
                    dateTo: salesDateTo != null
                        ? DateFormat('yyyy-MM-dd').format(salesDateTo!)
                        : null,
                  );
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
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
                    'Filter Penjualan',
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
                      // Search
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Cari...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                PalletConfig.borderRadius),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                      SizedBox(height: 12),

                      // Customer Picker
                      GestureDetector(
                        onTap: _selectCustomer,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCustomerName ?? 'Pilih Customer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Date Range Filter
                      GestureDetector(
                        onTap: _selectDateRange,
                        child: Container(
                          width: double.infinity,
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
                                salesDateFrom != null && salesDateTo != null
                                    ? '${DateFormat('dd MMM', 'id_ID').format(salesDateFrom!)} - ${DateFormat('dd MMM', 'id_ID').format(salesDateTo!)}'
                                    : 'Pilih Rentang Tanggal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  salesModel = snapshot.data;
                  if (salesModel.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada penjualan'),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        future = getSalesData(
                          search: searchController.text.isEmpty
                              ? null
                              : searchController.text,
                          customerId: selectedCustomerId,
                          dateFrom: salesDateFrom != null
                              ? DateFormat('yyyy-MM-dd').format(salesDateFrom!)
                              : null,
                          dateTo: salesDateTo != null
                              ? DateFormat('yyyy-MM-dd').format(salesDateTo!)
                              : null,
                        );
                      });
                    },
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      padding: EdgeInsets.all(PalletConfig.padding / 2),
                      itemCount: salesModel.data.length + (loadNext ? 1 : 0),
                      itemBuilder: (BuildContext context, int i) {
                        if (loadNext && i == salesModel.data.length) {
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
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) =>
                                    SalesDetailScreen(salesId: sale.id),
                              ))
                                  .then((_) {
                                setState(() {
                                  future = getSalesData(
                                    search: searchController.text.isEmpty
                                        ? null
                                        : searchController.text,
                                    customerId: selectedCustomerId,
                                    dateFrom: salesDateFrom != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(salesDateFrom!)
                                        : null,
                                    dateTo: salesDateTo != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(salesDateTo!)
                                        : null,
                                  );
                                });
                              });
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
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 2,
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
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            sale.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: sale.status
                                                          .toLowerCase() ==
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Total:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              FormatterUtil
                                                  .formatPriceWithCurrency(
                                                sale.totalAmountEffective,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    PalletConfig.primaryColor,
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
          ),
        ],
      ),
    );
  }
}
