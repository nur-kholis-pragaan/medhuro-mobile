import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/model/customer_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/customer/form_customer_screen.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  late CustomerModel customerModel;
  late Future<CustomerModel?> future;

  bool loadNext = false;

  TextEditingController search = TextEditingController();
  FocusNode focusNode = FocusNode();

  Timer? _debounce;

  Future<CustomerModel?> getCustomerData({
    String? searchText,
    String? page,
    String? limit,
  }) async {
    return CustomerApi().getCustomers(
      search: searchText,
      page: page ?? "1",
      limit: limit ?? "20",
    );
  }

  @override
  void initState() {
    super.initState();

    future = getCustomerData();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          // bottom
          if (customerModel.pagination != null &&
              customerModel.pagination!.current_page <
                  customerModel.pagination!.total_page) {
            setState(() => loadNext = true);

            getCustomerData(
              searchText: search.text.isEmpty ? null : search.text,
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
    search.dispose();
    focusNode.dispose();
    _debounce?.cancel(); // 🔥 penting
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        future = getCustomerData(
          searchText: value.isEmpty ? null : value,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          "Customer",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormCustomerScreen(),
                ),
              ).then((_) {
                setState(() {
                  future = getCustomerData();
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(PalletConfig.padding / 2),
            child: TextField(
              controller: search,
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
              onChanged: _onSearchChanged, // 🔥 pake debounce
            ),
          ),

          // 📋 LIST
          Expanded(
            child: FutureBuilder<CustomerModel?>(
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

                customerModel = snapshot.data!;

                if (customerModel.data.isEmpty) {
                  return const Center(
                    child: Text('Customer tidak ditemukan'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      future = getCustomerData(
                        searchText: search.text.isEmpty ? null : search.text,
                      );
                    });
                  },
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: PalletConfig.padding / 2),
                    itemCount: customerModel.data.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                    itemBuilder: (context, i) {
                      final customer = customerModel.data[i];

                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) =>
                                    FormCustomerScreen(customerId: customer.id),
                              ))
                                  .then((_) {
                                setState(() {
                                  future = getCustomerData(
                                    searchText: search.text.isEmpty
                                        ? null
                                        : search.text,
                                  );
                                });
                              });
                            },
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: PalletConfig.padding / 2,
                              vertical: 8,
                            ),
                            title: Text(
                              customer.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Kode: ${customer.code}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text("Telepon: ${customer.phoneNumber}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text(
                                    customer.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                          if (loadNext && i == customerModel.data.length - 1)
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
          ),
        ],
      ),
    );
  }
}
