import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/api/sales_payment_api.dart';
import 'package:medhuro_mobile/model/customer_model.dart';
import 'package:medhuro_mobile/model/sales_payment_term_model.dart';
import 'package:medhuro_mobile/model/payment_method_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/customer_picker_screen.dart';
import 'package:intl/intl.dart';

class PaymentFormScreen extends StatefulWidget {
  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  // Form Controllers
  TextEditingController selectedCustomerController = TextEditingController();
  TextEditingController paymentDateController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  // State variables
  CustomerDataModel? selectedCustomer;
  PaymentMethodDataModel? selectedPaymentMethod;
  List<SalesPaymentTermDataModel> receivables = [];
  Map<String, double> allocationAmounts = {}; // Map<termId, amount>
  Map<String, bool> selectedTerms = {}; // Map<termId, isSelected>
  List<PaymentMethodDataModel> paymentMethods = [];

  bool loadingReceivables = false;
  bool loadingPaymentMethods = false;
  bool isSubmitting = false;

  double totalAllocation = 0.0;

  @override
  void initState() {
    super.initState();
    // Set payment date to today
    paymentDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    selectedCustomerController.dispose();
    paymentDateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => loadingPaymentMethods = true);
    final result = await SalesPaymentApi().getPaymentMethods();
    if (result != null) {
      setState(() {
        paymentMethods = result.data;
        loadingPaymentMethods = false;
      });
    } else {
      setState(() => loadingPaymentMethods = false);
      _showError('Gagal memuat metode pembayaran');
    }
  }

  Future<void> _loadReceivables() async {
    if (selectedCustomer == null) {
      _showError('Pilih customer terlebih dahulu');
      return;
    }

    setState(() => loadingReceivables = true);
    final result =
        await SalesPaymentApi().getReceivablesByCustomer(selectedCustomer!.id);

    if (result != null) {
      setState(() {
        receivables = result;
        allocationAmounts.clear();
        selectedTerms.clear();
        loadingReceivables = false;
      });
    } else {
      setState(() => loadingReceivables = false);
      _showError('Gagal memuat piutang');
    }
  }

  void _showCustomerPicker() async {
    final result = await Navigator.push<CustomerDataModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCustomer = result;
        selectedCustomerController.text = result.name;
      });
      _loadReceivables();
    }
  }

  void _updateAllocation(String termId, double amount) {
    setState(() {
      if (amount > 0) {
        allocationAmounts[termId] = amount;
      } else {
        allocationAmounts.remove(termId);
      }
      _calculateTotalAllocation();
    });
  }

  void _toggleTermSelection(String termId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedTerms[termId] = true;
      } else {
        selectedTerms.remove(termId);
        allocationAmounts.remove(termId);
      }
      _calculateTotalAllocation();
    });
  }

  void _calculateTotalAllocation() {
    double total = 0.0;
    allocationAmounts.forEach((termId, amount) {
      if (selectedTerms[termId] == true) {
        total += amount;
      }
    });
    setState(() => totalAllocation = total);
  }

  void _selectAllReceivables(bool selectAll) {
    setState(() {
      if (selectAll) {
        for (var term in receivables) {
          selectedTerms[term.id] = true;
          allocationAmounts[term.id] = term.remaining;
        }
      } else {
        selectedTerms.clear();
        allocationAmounts.clear();
      }
      _calculateTotalAllocation();
    });
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PalletConfig.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PalletConfig.successColor,
      ),
    );
  }

  Future<void> _submitPayment() async {
    // Validation
    if (selectedCustomer == null) {
      _showError('Customer harus dipilih');
      return;
    }

    if (selectedPaymentMethod == null) {
      _showError('Metode pembayaran harus dipilih');
      return;
    }

    if (selectedTerms.isEmpty) {
      _showError('Minimal 1 piutang harus dipilih');
      return;
    }

    if (totalAllocation <= 0) {
      _showError('Nominal pembayaran harus lebih dari 0');
      return;
    }

    // Build items array
    List<Map<String, dynamic>> items = [];
    selectedTerms.forEach((termId, isSelected) {
      if (isSelected && allocationAmounts.containsKey(termId)) {
        items.add({
          'sales_payment_term_id': termId,
          'amount': allocationAmounts[termId],
        });
      }
    });

    setState(() => isSubmitting = true);

    final result = await SalesPaymentApi().createPayment(
      customerId: selectedCustomer!.id,
      paymentMethodId: selectedPaymentMethod!.id,
      paymentDate: paymentDateController.text,
      totalAmount: totalAllocation,
      items: items,
      note: noteController.text,
    );

    setState(() => isSubmitting = false);

    if (result != null && result['success'] == true) {
      _showSuccess(result['message'] ?? 'Pembayaran berhasil dibuat');
      // Clear form
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      _showError(result?['message'] ?? 'Gagal membuat pembayaran');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pembayaran Piutang',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: BASIC INFO
            _buildSectionTitle('Informasi Pembayaran'),
            SizedBox(height: 12),

            // Customer Picker
            GestureDetector(
              onTap: _showCustomerPicker,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer *',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          selectedCustomer?.name ?? 'Pilih Customer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Payment Date
            TextFormField(
              controller: paymentDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Tanggal Pembayaran *',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    paymentDateController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Payment Method
            _buildSectionTitle('Metode Pembayaran'),
            SizedBox(height: 12),
            loadingPaymentMethods
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<PaymentMethodDataModel>(
                    value: selectedPaymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Pilih Metode Pembayaran *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          PalletConfig.borderRadius,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: paymentMethods
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value);
                    },
                  ),
            SizedBox(height: 24),

            // SECTION 2: RECEIVABLES LIST
            _buildSectionTitle('Daftar Piutang'),
            SizedBox(height: 12),

            selectedCustomer == null
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius:
                          BorderRadius.circular(PalletConfig.borderRadius),
                    ),
                    child: Text(
                      'Pilih customer terlebih dahulu untuk menampilkan daftar piutang',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : loadingReceivables
                    ? Center(child: CircularProgressIndicator())
                    : receivables.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child:
                                  Text('Tidak ada piutang untuk customer ini'),
                            ),
                          )
                        : Column(
                            children: [
                              // Select All Checkbox
                              CheckboxListTile(
                                title: Text('Pilih Semua'),
                                value:
                                    selectedTerms.length == receivables.length,
                                onChanged: (value) {
                                  _selectAllReceivables(value ?? false);
                                },
                              ),
                              Divider(),

                              // Receivables Items
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: receivables.length,
                                separatorBuilder: (_, __) => Divider(),
                                itemBuilder: (context, index) {
                                  final term = receivables[index];
                                  final isSelected =
                                      selectedTerms[term.id] ?? false;
                                  final allocation =
                                      allocationAmounts[term.id] ?? 0.0;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Checkbox + Invoice
                                        CheckboxListTile(
                                          value: isSelected,
                                          onChanged: (value) {
                                            _toggleTermSelection(
                                                term.id, value ?? false);
                                          },
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                term.invoice,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Sisa: ${_formatCurrency(term.remaining)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      PalletConfig.errorColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),

                                        if (isSelected) ...[
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Amount Info
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Total',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            )),
                                                        Text(
                                                          _formatCurrency(
                                                              term.amount),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Sudah Bayar',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            )),
                                                        Text(
                                                          _formatCurrency(
                                                              term.paidAmount),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Sisa',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            )),
                                                        Text(
                                                          _formatCurrency(
                                                              term.remaining),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: PalletConfig
                                                                .errorColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),

                                                // Allocation Input
                                                TextFormField(
                                                  initialValue: allocation > 0
                                                      ? allocation.toString()
                                                      : '',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Nominal Pembayaran',
                                                    hintText:
                                                        '0 - ${_formatCurrency(term.remaining)}',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        PalletConfig
                                                            .borderRadius,
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    final amount =
                                                        double.tryParse(
                                                                value) ??
                                                            0.0;

                                                    // Validate overpayment
                                                    if (amount >
                                                        term.remaining) {
                                                      _showError(
                                                        'Nominal tidak boleh melebihi sisa piutang (${_formatCurrency(term.remaining)})',
                                                      );
                                                      _updateAllocation(term.id,
                                                          term.remaining);
                                                    } else {
                                                      _updateAllocation(
                                                          term.id, amount);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
            SizedBox(height: 24),

            // SECTION 3: TOTAL & NOTE
            _buildSectionTitle('Ringkasan'),
            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatCurrency(totalAllocation),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PalletConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Note
            TextFormField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tulis catatan pembayaran',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(PalletConfig.borderRadius),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 24),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PalletConfig.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      PalletConfig.borderRadius,
                    ),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Simpan Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: PalletConfig.primaryColor,
      ),
    );
  }
}
