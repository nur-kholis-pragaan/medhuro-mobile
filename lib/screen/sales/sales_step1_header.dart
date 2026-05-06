import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/model/customer_model.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:provider/provider.dart';

typedef OnHeaderComplete = void Function({
  required String customerId,
  required DateTime salesDate,
  required int transactionDiscount,
});

class SalesStep1Header extends StatefulWidget {
  final VoidCallback onNext;

  const SalesStep1Header({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  _SalesStep1HeaderState createState() => _SalesStep1HeaderState();
}

class _SalesStep1HeaderState extends State<SalesStep1Header> {
  late Future<CustomerModel?> customersFuture;

  CustomerModel? customerModel;

  String? selectedCustomerId;
  late DateTime selectedDate;
  int transactionDiscount = 0;
  late TextEditingController transactionDiscountController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SalesProvider>(context, listen: false);

    // Load dari provider jika sudah ada
    selectedCustomerId = provider.selectedCustomerId;
    selectedDate = provider.selectedDate;
    transactionDiscount = provider.transactionDiscount;

    transactionDiscountController = TextEditingController(
      text: transactionDiscount > 0 ? transactionDiscount.toString() : '',
    );
    customersFuture = CustomerApi().getCustomers();
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

  void _handleNext() {
    if (selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih customer terlebih dahulu')),
      );
      return;
    }

    // Persist to provider
    final provider = Provider.of<SalesProvider>(context, listen: false);
    provider.setHeaderInfo(
      customerId: selectedCustomerId!,
      paymentTermId:
          provider.selectedPaymentTermId ?? 0, // Will be set in step 4
      salesDate: selectedDate,
      transactionDiscount: transactionDiscount,
    );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                      DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today,
                        color: PalletConfig.primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Section
            Text(
              'Pilih Customer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<CustomerModel?>(
              future: customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Gagal memuat customers'));
                }

                customerModel = snapshot.data;
                return DropdownButtonFormField<String>(
                  value: selectedCustomerId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('Pilih customer'),
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
            const SizedBox(height: 24),

            // Transaction Discount Section
            Text(
              'Diskon Transaksi (Opsional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            const SizedBox(height: 8),
            FormWidget().currencyInput(
              controller: transactionDiscountController,
              label: 'Diskon Transaksi',
              onChanged: (value) {
                setState(() {
                  transactionDiscount = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Next Button
            FormWidget().button(
              icon: Icons.arrow_forward,
              label: 'Lanjut ke Item Penjualan',
              callBack: _handleNext,
              backgroundColor: PalletConfig.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
