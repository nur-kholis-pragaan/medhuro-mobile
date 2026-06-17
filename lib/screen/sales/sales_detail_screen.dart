import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/model/sales_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class SalesDetailScreen extends StatefulWidget {
  final int salesId;

  const SalesDetailScreen({
    Key? key,
    required this.salesId,
  }) : super(key: key);

  @override
  _SalesDetailScreenState createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  late Future<SalesDataModel?> future;

  @override
  void initState() {
    future = SalesApi().getSalesDetail(widget.salesId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Detail Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: FutureBuilder<SalesDataModel?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          SalesDataModel sale = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(PalletConfig.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(sale),
                  SizedBox(height: PalletConfig.padding),
                  _buildCustomerInfoCard(sale),
                  SizedBox(height: PalletConfig.padding),
                  _buildItemsCard(sale),
                  SizedBox(height: PalletConfig.padding),
                  if (sale.salesReturn != null &&
                      sale.salesReturn!.items.isNotEmpty)
                    _buildReturnItemsCard(sale.salesReturn!),
                  if (sale.salesReturn != null &&
                      sale.salesReturn!.items.isNotEmpty)
                    SizedBox(height: PalletConfig.padding),
                  _buildTotalSummaryCard(sale),
                  SizedBox(height: PalletConfig.padding),
                  if (sale.paymentTerms.isNotEmpty)
                    _buildPaymentTermsCard(sale),
                  SizedBox(height: PalletConfig.padding),
                  if (sale.paymentTerms.isNotEmpty &&
                      sale.paymentTerms
                          .any((term) => term.paymentItems.isNotEmpty))
                    _buildPaymentHistoryCard(sale),
                  SizedBox(height: PalletConfig.padding),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Header Card
  Widget _buildHeaderCard(SalesDataModel sale) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Penjualan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      sale.invoiceNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sale.status.toLowerCase() == 'completed'
                        ? PalletConfig.successColor.withOpacity(0.1)
                        : PalletConfig.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sale.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sale.status.toLowerCase() == 'completed'
                          ? PalletConfig.successColor
                          : PalletConfig.warningColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal',
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Salesman',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      sale.salesman.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Customer Info Card
  Widget _buildCustomerInfoCard(SalesDataModel sale) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Customer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nama:'),
                Text(
                  sale.customer.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kode:'),
                Text(
                  sale.customer.code,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Items Card
  Widget _buildItemsCard(SalesDataModel sale) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Penjualan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sale.items.length,
              separatorBuilder: (context, index) => Divider(height: 12),
              itemBuilder: (context, index) {
                SalesItemModel item = sale.items[index];
                return _buildItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Single Item Row
  Widget _buildItemRow(SalesItemModel item) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.product.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kode: ${item.product.code}',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                'Qty: ${item.qtyCarton}',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Harga:'),
              Text(
                FormatterUtil.formatPriceWithCurrency(item.price),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (double.parse(item.discountAmount) > 0) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diskon:'),
                Text(
                  FormatterUtil.formatPriceWithCurrency(item.discountAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                FormatterUtil.formatPriceWithCurrency(item.subtotal),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PalletConfig.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Return Items Card
  Widget _buildReturnItemsCard(SalesReturnInfo salesReturn) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Retur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: PalletConfig.fontLargeSize,
                  ),
                ),
                Text(
                  '#${salesReturn.returnNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PalletConfig.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Tgl: ${salesReturn.returnDate}',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: salesReturn.items.length,
              separatorBuilder: (context, index) => Divider(height: 12),
              itemBuilder: (context, index) {
                SalesReturnItemInfo item = salesReturn.items[index];
                return _buildReturnItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Single Return Item Row
  Widget _buildReturnItemRow(SalesReturnItemInfo item) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.product.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${item.qtyCarton > 0 ? item.qtyCarton : item.qtyPack > 0 ? item.qtyPack : item.qtyPcs} ${item.unit}',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Harga: ${FormatterUtil.formatPriceWithCurrency(double.parse(item.price))}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.type != null)
                Text(
                  'Tipe: ${item.type == 'bs' ? 'Busuk' : 'Gosong'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              Text(
                'Total: ${FormatterUtil.formatPriceWithCurrency(double.parse(item.subtotal))}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PalletConfig.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Total Summary Card
  Widget _buildTotalSummaryCard(SalesDataModel sale) {
    final hasReturn = double.parse(sale.returnAmount) > 0;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:'),
                Text(
                    FormatterUtil.formatPriceWithCurrency(sale.subtotalAmount)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diskon:'),
                Text(
                  FormatterUtil.formatPriceWithCurrency(sale.discountAmount),
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Penjualan:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  FormatterUtil.formatPriceWithCurrency(sale.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PalletConfig.primaryColor,
                  ),
                ),
              ],
            ),
            if (hasReturn) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Retur:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '- ${FormatterUtil.formatPriceWithCurrency(sale.returnAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Divider(height: 16),
            ],
            if (hasReturn)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Efektif:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    FormatterUtil.formatPriceWithCurrency(
                        sale.totalAmountEffective),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: PalletConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            if (!hasReturn)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Efektif:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    FormatterUtil.formatPriceWithCurrency(
                        sale.totalAmountEffective),
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
    );
  }

  // Payment Terms Card
  Widget _buildPaymentTermsCard(SalesDataModel sale) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syarat Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sale.paymentTerms.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                PaymentTermInfo term = sale.paymentTerms[index];
                return _buildPaymentTermRow(term);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Single Payment Term Row
  Widget _buildPaymentTermRow(PaymentTermInfo term) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                term.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: term.status.toLowerCase() == 'completed'
                      ? PalletConfig.successColor.withOpacity(0.1)
                      : Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  term.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: term.status.toLowerCase() == 'completed'
                        ? PalletConfig.successColor
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah:'),
              Text(
                FormatterUtil.formatPriceWithCurrency(term.amount),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terbayar:'),
              Text(
                FormatterUtil.formatPriceWithCurrency(term.paidAmount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa:'),
              Text(
                FormatterUtil.formatPriceWithCurrency(term.remainingAmount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: term.remainingAmount > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          if (term.dueDate != null) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jatuh Tempo:'),
                Text(
                  term.dueDate?.split('T')[0] ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Payment History Card
  Widget _buildPaymentHistoryCard(SalesDataModel sale) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PalletConfig.fontLargeSize,
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                dataRowHeight: 45,
                headingRowHeight: 48,
                columns: [
                  DataColumn(
                    label: Text(
                      'Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Syarat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Metode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nominal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Catatan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                rows: _buildPaymentHistoryRows(sale.paymentTerms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build payment history rows
  List<DataRow> _buildPaymentHistoryRows(List<PaymentTermInfo> paymentTerms) {
    List<DataRow> rows = [];

    for (var term in paymentTerms) {
      for (var item in term.paymentItems) {
        final paymentDate =
            item.paymentDate != null ? item.paymentDate!.split(' ')[0] : '-';

        rows.add(
          DataRow(
            cells: [
              DataCell(Text(paymentDate, style: TextStyle(fontSize: 11))),
              DataCell(Text(term.name, style: TextStyle(fontSize: 11))),
              DataCell(Text(item.paymentMethod ?? 'Cash',
                  style: TextStyle(fontSize: 11))),
              DataCell(
                Text(
                  FormatterUtil.formatPriceWithCurrency(item.amount),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              DataCell(
                Text(
                  item.note ?? '-',
                  style: TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }
}
