import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/api/payment_term_api.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/model/customer_model.dart';
import 'package:medhuro_mobile/model/payment_term_model.dart';
import 'package:provider/provider.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late Future<CustomerModel?> customersFuture;
  late Future<PaymentTermModel?> paymentTermsFuture;

  CustomerModel? customerModel;
  PaymentTermModel? paymentTermModel;

  int? selectedCustomerId;
  int? selectedPaymentTermId;
  late DateTime selectedDate;
  int transactionDiscount = 0;
  late TextEditingController transactionDiscountController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    transactionDiscountController = TextEditingController();
    customersFuture = CustomerApi().getCustomers();
    paymentTermsFuture = PaymentTermApi().getPaymentTerms();
  }

  @override
  void dispose() {
    transactionDiscountController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitSales() async {
    if (selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih customer terlebih dahulu')),
      );
      return;
    }

    if (selectedPaymentTermId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih payment terms terlebih dahulu')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      final items = salesProvider.items
          .map((item) => {
                'product_id': item.productId,
                'unit': item.unit,
                'qty': item.qty,
                'price': item.price,
                'discount_amount': item.discountAmount,
              })
          .toList();

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final result = await SalesApi().createSales(
        customerId: selectedCustomerId!,
        paymentTermId: selectedPaymentTermId!,
        salesDate: formattedDate,
        discountAmount: transactionDiscount,
        cashAmount: 0,
        items: items,
        returnItems: [],
      );

      debugPrint('Sales creation result: $result');

      if (result != null) {
        salesProvider.clear();

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Sukses'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: PalletConfig.successColor,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text('Penjualan berhasil dibuat'),
                    SizedBox(height: 8),
                    Text(
                      'Invoice: ${result.invoiceNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PalletConfig.primaryColor,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // close confirmation screen
                      Navigator.pop(context); // close cart screen
                    },
                    child: Text('Selesai'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat penjualan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Konfirmasi Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(PalletConfig.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Section
              Text(
                'Tanggal Penjualan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PalletConfig.fontLargeSize,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(
                      PalletConfig.borderRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(selectedDate),
                      ),
                      Icon(Icons.calendar_today,
                          color: PalletConfig.primaryColor),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Customer Section
              Text(
                'Pilih Customer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PalletConfig.fontLargeSize,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<CustomerModel?>(
                future: customersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('Gagal memuat customers'));
                  }

                  customerModel = snapshot.data;
                  return DropdownButtonFormField<int>(
                    value: selectedCustomerId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          PalletConfig.borderRadius,
                        ),
                      ),
                    ),
                    hint: Text('Pilih customer'),
                    items: customerModel!.data
                        .map((customer) => DropdownMenuItem(
                              value: customer.id,
                              child: Text(customer.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCustomerId = value;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 24),

              // Payment Terms Section
              Text(
                'Syarat Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PalletConfig.fontLargeSize,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<PaymentTermModel?>(
                future: paymentTermsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('Gagal memuat payment terms'));
                  }

                  paymentTermModel = snapshot.data;
                  return DropdownButtonFormField<int>(
                    value: selectedPaymentTermId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          PalletConfig.borderRadius,
                        ),
                      ),
                    ),
                    hint: Text('Pilih pembayaran'),
                    items: paymentTermModel!.data
                        .map((term) => DropdownMenuItem(
                              value: term.id,
                              child: Text(
                                '${term.name}${term.dueDays > 0 ? ' (${term.dueDays} hari)' : ''}',
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentTermId = value;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 24),

              // Items Summary
              Text(
                'Ringkasan Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PalletConfig.fontLargeSize,
                ),
              ),
              SizedBox(height: 12),
              Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: salesProvider.items.length,
                    separatorBuilder: (context, index) => Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = salesProvider.items[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.qty} ${item.unit.toUpperCase()} x ${FormatterUtil.formatPriceWithCurrency(item.price)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            FormatterUtil.formatPriceWithCurrency(
                                item.subtotal),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: PalletConfig.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // Transaction Discount
              Text(
                'Diskon Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PalletConfig.fontLargeSize,
                ),
              ),
              SizedBox(height: 8),
              FormWidget().currencyInput(
                controller: transactionDiscountController,
                label: 'Diskon Transaksi',
                onChanged: (value) {
                  setState(() {
                    transactionDiscount = value;
                  });
                },
              ),
              SizedBox(height: 24),

              // Total Section
              Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  int finalTotal =
                      salesProvider.totalAmount - transactionDiscount;
                  return Container(
                    padding: EdgeInsets.all(PalletConfig.padding),
                    decoration: BoxDecoration(
                      color: PalletConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        PalletConfig.borderRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal Item:'),
                            Text(FormatterUtil.formatPriceWithCurrency(
                                salesProvider.subtotal)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Diskon Item:'),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  salesProvider.totalDiscount),
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Diskon Transaksi:'),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  transactionDiscount),
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(finalTotal),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: PalletConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              FormWidget().button(
                icon: Icons.check_circle,
                label: 'Submit Penjualan',
                callBack: isLoading ? () {} : _submitSales,
                showLoader: isLoading,
                backgroundColor: PalletConfig.primaryColor,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
