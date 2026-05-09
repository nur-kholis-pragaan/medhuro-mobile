import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/receivable_api.dart';
import 'package:medhuro_mobile/model/receivable_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/screen/sales/receivable_detail_screen.dart';

class ReceivableScreen extends StatefulWidget {
  @override
  _ReceivableScreenState createState() => _ReceivableScreenState();
}

class _ReceivableScreenState extends State<ReceivableScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  late ReceivableModel receivableModel;
  late Future<ReceivableModel?> future;

  bool loadNext = false;

  TextEditingController search = TextEditingController();
  FocusNode focusNode = FocusNode();

  Timer? _debounce;

  Future<ReceivableModel?> getReceivableData({
    String? searchText,
    String? page,
    String? limit,
  }) async {
    return ReceivableApi().getReceivableSummary(
      search: searchText,
      page: page ?? "1",
      limit: limit ?? "15",
      sortBy: 'total_debt',
      sort: 'desc',
    );
  }

  @override
  void initState() {
    super.initState();

    future = getReceivableData();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          // bottom
          if (receivableModel.pagination != null &&
              receivableModel.pagination!.current_page <
                  receivableModel.pagination!.total_page) {
            setState(() => loadNext = true);

            getReceivableData(
              searchText: search.text.isEmpty ? null : search.text,
              page: (receivableModel.pagination!.current_page + 1).toString(),
            ).then((r) {
              setState(() {
                loadNext = false;
                receivableModel.pagination = r!.pagination;
                receivableModel.data.addAll(r.data);
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
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        future = getReceivableData(
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
          "Piutang",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
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
                hintText: 'Cari customer piutang...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // 📋 LIST
          Expanded(
            child: FutureBuilder<ReceivableModel?>(
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

                receivableModel = snapshot.data!;

                if (receivableModel.data.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada piutang'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      future = getReceivableData(
                        searchText: search.text.isEmpty ? null : search.text,
                      );
                    });
                  },
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: PalletConfig.padding / 2),
                    itemCount: receivableModel.data.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                    itemBuilder: (context, i) {
                      final receivable = receivableModel.data[i];

                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => ReceivableDetailScreen(
                                  customerId: receivable.id,
                                  customerName: receivable.name,
                                ),
                              ))
                                  .then((_) {
                                setState(() {
                                  future = getReceivableData(
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
                              receivable.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Kode: ${receivable.code}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text("Telepon: ${receivable.phoneNumber}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text(
                                    receivable.address,
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
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp. ${FormatterUtil.formatPrice(receivable.totalDebt)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: PalletConfig.errorColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                          if (loadNext && i == receivableModel.data.length - 1)
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
