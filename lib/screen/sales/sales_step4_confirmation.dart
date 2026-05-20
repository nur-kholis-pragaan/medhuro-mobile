import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medhuro_mobile/api/payment_term_api.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/model/payment_term_model.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:provider/provider.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';

class SalesStep4Confirmation extends StatefulWidget {
  final VoidCallback onBack;

  const SalesStep4Confirmation({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  _SalesStep4ConfirmationState createState() => _SalesStep4ConfirmationState();
}

class _SalesStep4ConfirmationState extends State<SalesStep4Confirmation> {
  late TextEditingController cashAmountController;
  late Future<PaymentTermModel?> paymentTermsFuture;
  PaymentTermModel? paymentTermModel;
  int? selectedPaymentTermId;
  String? selectedPaymentTermType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cashAmountController = TextEditingController();
    paymentTermsFuture = PaymentTermApi().getPaymentTerms();

    // Load payment term from provider if already set
    final provider = Provider.of<SalesProvider>(context, listen: false);
    selectedPaymentTermId = provider.selectedPaymentTermId;
  }

  @override
  void dispose() {
    cashAmountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    if (selectedPaymentTermId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih syarat pembayaran terlebih dahulu')),
      );
      return;
    }

    int cashAmount =
        FormatterUtil.formatPrice(cashAmountController.text).isEmpty
            ? 0
            : int.tryParse(cashAmountController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '')) ??
                0;

    // Update cash amount di provider
    salesProvider.setCashAmount(cashAmount);

    // Update payment term di provider
    salesProvider.setHeaderInfo(
      customerId: salesProvider.selectedCustomerId ?? '',
      paymentTermId: selectedPaymentTermId!,
      salesDate: salesProvider.selectedDate,
      transactionDiscount: salesProvider.transactionDiscount,
    );

    if (salesProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 item penjualan')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    print('Submitting sales with data:');
    print('Customer ID: ${salesProvider.selectedCustomerId}');
    try {
      // Prepare sales items
      final items = salesProvider.items
          .map((item) => {
                'product_id': item.productId,
                'unit': item.unit,
                'qty': item.qty,
                'price': item.price,
                'discount_amount': item.discountAmount,
              })
          .toList();

      // Prepare return items (jika ada)
      final returnItems = salesProvider.returnItems.isNotEmpty
          ? salesProvider.returnItems
              .map((item) => {
                    'product_id': item.productId,
                    'unit': item.unit,
                    'qty': item.qty,
                    'price': item.price,
                    'discount_amount': item.discountAmount,
                    'type': item.type,
                  })
              .toList()
          : null;

      final formattedDate =
          DateFormat('yyyy-MM-dd').format(salesProvider.selectedDate);

      final result = await SalesApi().createSales(
        customerId: salesProvider.selectedCustomerId!,
        paymentTermId: selectedPaymentTermId!,
        salesDate: formattedDate,
        discountAmount: salesProvider.transactionDiscount,
        cashAmount: cashAmount,
        items: items,
        returnItems: returnItems,
      );

      debugPrint('Sales creation result: $result');

      if (result != null && mounted) {
        // Clear provider
        salesProvider.clear();

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sukses'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: PalletConfig.successColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text('Penjualan berhasil dibuat'),
                  const SizedBox(height: 8),
                  Text(
                    'Invoice: ${result.invoiceNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PalletConfig.primaryColor,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close wizard
                  },
                  child: const Text('Selesai'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat penjualan.')),
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
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        int cashAmount = 0;
        if (cashAmountController.text.isNotEmpty) {
          final cleanedText = cashAmountController.text
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('Rp. ', '');
          cashAmount = int.tryParse(cleanedText) ?? 0;
        }
        // Calculate final total: total sales - total return - transaction discount
        int finalTotal = salesProvider.totalSales -
            salesProvider.totalReturn -
            salesProvider.transactionDiscount;
        int remainingAmount = finalTotal - cashAmount;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(PalletConfig.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PalletConfig.primaryColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(salesProvider.selectedDate)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Terms Section
                Text(
                  'Syarat Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: PalletConfig.fontLargeSize,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<PaymentTermModel?>(
                  future: paymentTermsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                          child: Text('Gagal memuat payment terms'));
                    }

                    paymentTermModel = snapshot.data;

                    // Validate that selectedPaymentTermId exists in the list
                    final validIds =
                        paymentTermModel!.data.map((t) => t.id).toList();
                    final effectiveValue = selectedPaymentTermId != null &&
                            validIds.contains(selectedPaymentTermId)
                        ? selectedPaymentTermId
                        : null;

                    return DropdownButtonFormField<int?>(
                      value: effectiveValue,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Pilih pembayaran'),
                      items: paymentTermModel!.data
                          .map((term) => DropdownMenuItem(
                                value: term.id,
                                child: Text(
                                  '${term.name}${' (${term.type})'}',
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentTermId = value;
                          // Find the selected payment term to get its type
                          if (value != null && paymentTermModel != null) {
                            final selectedTerm = paymentTermModel!.data
                                .firstWhere((term) => term.id == value,
                                    orElse: () => paymentTermModel!.data.first);
                            selectedPaymentTermType = selectedTerm.type;

                            // If cash type, auto-fill the cash amount and make it read-only
                            if (selectedTerm.type == 'cash') {
                              // Calculate final total
                              int finalTotal = Provider.of<SalesProvider>(
                                          context,
                                          listen: false)
                                      .totalSales -
                                  Provider.of<SalesProvider>(context,
                                          listen: false)
                                      .totalReturn -
                                  Provider.of<SalesProvider>(context,
                                          listen: false)
                                      .transactionDiscount;
                              // Format and set the value
                              String formatted =
                                  CurrencyFormatter.formatCurrency(finalTotal);
                              cashAmountController.text = formatted;
                            } else {
                              // Clear the field for credit terms
                              cashAmountController.clear();
                            }
                          }
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Sales Items Section
                Text(
                  'Item Penjualan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: PalletConfig.fontLargeSize,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: salesProvider.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = salesProvider.items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.qty} x ${item.unit.toUpperCase()} @ ${FormatterUtil.formatPriceWithCurrency(item.price)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  item.subtotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Return Items Section (jika ada)
                if (salesProvider.returnItems.isNotEmpty) ...[
                  Text(
                    'Item Retur',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: PalletConfig.fontLargeSize,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: salesProvider.returnItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = salesProvider.returnItems[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.qty} x ${item.unit.toUpperCase()} @ ${FormatterUtil.formatPriceWithCurrency(item.price)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  FormatterUtil.formatPriceWithCurrency(
                                      item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.type == 'gs'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: item.type == 'gs'
                                          ? Colors.green
                                          : Colors.red,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    item.type == 'gs'
                                        ? 'Good Stock (GS)'
                                        : 'Bad Stock (BS)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: item.type == 'gs'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Summary Section
                Text(
                  'Ringkasan Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: PalletConfig.fontLargeSize,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PalletConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Penjualan:'),
                          Text(
                            FormatterUtil.formatPriceWithCurrency(
                                salesProvider.totalSales),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (salesProvider.returnItems.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Retur:'),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  salesProvider.totalReturn),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (salesProvider.transactionDiscount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon Transaksi:'),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  salesProvider.transactionDiscount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            FormatterUtil.formatPriceWithCurrency(finalTotal),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: PalletConfig.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cash Amount Input
                Text(
                  'Pembayaran Tunai',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: PalletConfig.fontLargeSize,
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedPaymentTermType == 'cash')
                  TextField(
                    controller: cashAmountController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Uang',
                      filled: true,
                      fillColor: Colors.grey[300], // background abu-abu
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      hintText: 'Otomatis terisi sesuai total',
                    ),
                  )
                else
                  FormWidget().currencyInput(
                    controller: cashAmountController,
                    label: 'Jumlah Uang',
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                const SizedBox(height: 24),

                // Remaining Amount
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: remainingAmount > 0
                        ? const Color(0xFFFFEBEE)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: remainingAmount > 0 ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sisa Hutang:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FormatterUtil.formatPriceWithCurrency(
                                remainingAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: remainingAmount > 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        remainingAmount > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle,
                        color: remainingAmount > 0 ? Colors.red : Colors.green,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FormWidget().button(
                  icon: Icons.check_circle,
                  label: 'Simpan Penjualan',
                  callBack: isLoading ? () {} : _handleSubmit,
                  showLoader: isLoading,
                  backgroundColor: PalletConfig.primaryColor,
                ),
                const SizedBox(height: 12),

                // Back Button
                FormWidget().button(
                  icon: Icons.arrow_back,
                  label: 'Kembali',
                  callBack: isLoading ? () {} : widget.onBack,
                  backgroundColor: Colors.grey.shade600,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
