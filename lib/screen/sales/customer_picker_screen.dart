import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/model/customer_model.dart';

class CustomerPickerScreen extends StatefulWidget {
  final String? initialCustomerId;

  const CustomerPickerScreen({
    Key? key,
    this.initialCustomerId,
  }) : super(key: key);

  @override
  _CustomerPickerScreenState createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends State<CustomerPickerScreen> {
  late CustomerModel customerModel;
  late Future<CustomerModel?> future;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool loadNext = false;

  Future<CustomerModel?> getCustomerData({
    String? search,
    String? page,
    String? limit,
  }) async {
    return CustomerApi().getCustomers(
      search: search,
      page: page ?? "1",
      limit: limit ?? "20",
    );
  }

  @override
  void initState() {
    future = getCustomerData();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
        } else {
          if (customerModel.pagination != null &&
              customerModel.pagination!.current_page <
                  customerModel.pagination!.total_page) {
            setState(() {
              loadNext = true;
            });
            getCustomerData(
              search:
                  searchController.text.isEmpty ? null : searchController.text,
              page: (customerModel.pagination!.current_page + 1).toString(),
            ).then((r) {
              setState(() {
                loadNext = false;
                customerModel.pagination = r!.pagination;
                customerModel.data.addAll(r.data);
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

  void _selectCustomer(CustomerDataModel customer) {
    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Pilih Customer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                hintText: 'Cari customer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  future = getCustomerData(search: value);
                });
              },
            ),
          ),
          // Customer List
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
                  customerModel = snapshot.data;
                  if (customerModel.data.isEmpty) {
                    return const Center(
                        child: Text('Customer tidak ditemukan'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        future = getCustomerData(
                          search: searchController.text.isEmpty
                              ? null
                              : searchController.text,
                        );
                      });
                    },
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PalletConfig.padding / 2,
                        vertical: PalletConfig.padding / 2,
                      ),
                      itemCount: customerModel.data.length + (loadNext ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (loadNext && index == customerModel.data.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        CustomerDataModel customer = customerModel.data[index];
                        bool isSelected = widget.initialCustomerId != null &&
                            widget.initialCustomerId == customer.id;

                        return InkWell(
                          onTap: () => _selectCustomer(customer),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: isSelected
                                ? PalletConfig.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
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
                                            customer.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Kode: ${customer.code}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            customer.phoneNumber,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: PalletConfig.primaryColor,
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
    );
  }
}
