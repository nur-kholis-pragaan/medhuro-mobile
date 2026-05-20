import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/screen/sales/product_picker_screen.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:provider/provider.dart';

/// Soft amber color untuk return items
const Color _softAmberColor = Color(0xFFFFF3E0); // Soft amber background
const Color _amberAccentColor = Color(0xFFFF9800); // Amber accent

class SalesStep3ReturnItems extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SalesStep3ReturnItems({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _SalesStep3ReturnItemsState createState() => _SalesStep3ReturnItemsState();
}

class _SalesStep3ReturnItemsState extends State<SalesStep3ReturnItems> {
  late Map<int, TextEditingController> qtyControllers;
  late Map<int, TextEditingController> discountControllers;
  late Map<int, TextEditingController> priceControllers;
  late Map<int, String> unitSelectors;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    qtyControllers = {};
    discountControllers = {};
    priceControllers = {};
    unitSelectors = {};

    for (int i = 0; i < salesProvider.returnItems.length; i++) {
      final item = salesProvider.returnItems[i];
      qtyControllers[i] = TextEditingController(text: item.qty.toString());
      discountControllers[i] =
          TextEditingController(text: item.discountAmount.toString());
      priceControllers[i] = TextEditingController(
        text: FormatterUtil.formatPrice(item.price),
      );
      unitSelectors[i] = item.unit;
    }
  }

  @override
  void dispose() {
    qtyControllers.forEach((key, controller) => controller.dispose());
    discountControllers.forEach((key, controller) => controller.dispose());
    priceControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _handleAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductPickerScreen(
          title: 'Tambah Produk Retur',
          isReturnMode: true,
        ),
      ),
    );
    // Reinitialize controllers setelah kembali
    _initializeControllers();
    setState(() {});
  }

  /// Safely get or create a controller for the given index
  TextEditingController _getQtyController(int index, SalesProvider provider) {
    if (!qtyControllers.containsKey(index)) {
      qtyControllers[index] = TextEditingController(
        text: provider.returnItems[index].qty.toString(),
      );
    }
    return qtyControllers[index]!;
  }

  TextEditingController _getPriceController(int index, SalesProvider provider) {
    if (!priceControllers.containsKey(index)) {
      priceControllers[index] = TextEditingController(
        text: FormatterUtil.formatPrice(provider.returnItems[index].price),
      );
    }
    return priceControllers[index]!;
  }

  TextEditingController _getDiscountController(
      int index, SalesProvider provider) {
    if (!discountControllers.containsKey(index)) {
      discountControllers[index] = TextEditingController(
        text: provider.returnItems[index].discountAmount.toString(),
      );
    }
    return discountControllers[index]!;
  }

  void _handleNext() {
    // Update semua return items dari controller values
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    for (int i = 0; i < salesProvider.returnItems.length; i++) {
      // Safely get controller values, fallback to item values if controller doesn't exist
      int qty = 1;
      int discount = 0;
      int price = 0;

      if (qtyControllers.containsKey(i)) {
        qty = int.tryParse(qtyControllers[i]!.text) ?? 1;
      } else {
        qty = salesProvider.returnItems[i].qty;
      }

      if (discountControllers.containsKey(i)) {
        discount = int.tryParse(discountControllers[i]!.text) ?? 0;
      } else {
        discount = salesProvider.returnItems[i].discountAmount;
      }

      if (priceControllers.containsKey(i)) {
        final priceText = priceControllers[i]!.text;
        price = priceText.isEmpty
            ? 0
            : int.tryParse(priceText.replaceAll('.', '').replaceAll(',', '')) ??
                0;
      } else {
        price = salesProvider.returnItems[i].price;
      }

      salesProvider.updateReturnItem(i, qty, discount);
      if (price > 0) {
        salesProvider.updateReturnItemPrice(i, price);
      }
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        // Ensure controllers are initialized for all items
        for (int i = 0; i < salesProvider.returnItems.length; i++) {
          if (!qtyControllers.containsKey(i)) {
            _initializeControllers();
            break;
          }
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PalletConfig.padding / 2),
                child: Column(
                  children: <Widget>[
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _softAmberColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _amberAccentColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: _amberAccentColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Retur bersifat opsional. Jika tidak ada retur, lanjut ke step berikutnya.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _amberAccentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Return Items List (if any)
                    if (salesProvider.returnItems.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: salesProvider.returnItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = salesProvider.returnItems[index];

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                PalletConfig.borderRadius,
                              ),
                              side: BorderSide(
                                  color: _amberAccentColor.withOpacity(0.3)),
                            ),
                            color: _softAmberColor,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Kode: ${item.productCode}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          salesProvider.removeReturnItem(index);
                                          setState(() {
                                            qtyControllers.remove(index);
                                            discountControllers.remove(index);
                                            priceControllers.remove(index);
                                            unitSelectors.remove(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        tooltip: 'Hapus',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Unit & Qty Control (One Row)
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unit:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 36,
                                              child: FormWidget().unitSelector(
                                                value: unitSelectors[index] ??
                                                    'carton',
                                                onChanged: (newUnit) {
                                                  setState(() {
                                                    unitSelectors[index] =
                                                        newUnit;
                                                  });

                                                  // Update price based on selected unit
                                                  int newPrice = 0;
                                                  if (newUnit == 'carton') {
                                                    newPrice =
                                                        item.sellingPriceCarton;
                                                  } else if (newUnit ==
                                                      'pack') {
                                                    newPrice =
                                                        item.sellingPricePack;
                                                  } else if (newUnit == 'pcs') {
                                                    newPrice =
                                                        item.sellingPricePcs;
                                                  }

                                                  if (newPrice > 0) {
                                                    _getPriceController(index,
                                                                salesProvider)
                                                            .text =
                                                        FormatterUtil
                                                            .formatPrice(
                                                                newPrice);
                                                    salesProvider
                                                        .updateReturnItemPrice(
                                                            index, newPrice);
                                                  }

                                                  // Update unit in provider
                                                  salesProvider
                                                      .updateReturnItemUnit(
                                                          index,
                                                          newUnit,
                                                          newPrice);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Qty:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 36,
                                              child: FormWidget().qtyControl(
                                                value: int.tryParse(
                                                        _getQtyController(index,
                                                                salesProvider)
                                                            .text) ??
                                                    1,
                                                onChanged: (newQty) {
                                                  _getQtyController(
                                                          index, salesProvider)
                                                      .text = newQty.toString();
                                                  // Update provider immediately for subtotal recalculation
                                                  int discount = int.tryParse(
                                                          _getDiscountController(
                                                                  index,
                                                                  salesProvider)
                                                              .text) ??
                                                      0;
                                                  salesProvider
                                                      .updateReturnItem(index,
                                                          newQty, discount);
                                                  setState(() {});
                                                },
                                                color: _amberAccentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Price & Discount
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Harga:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            FormWidget().priceInput(
                                              controller: _getPriceController(
                                                  index, salesProvider),
                                              label: 'Harga',
                                              onChanged: (value) {
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Diskon:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            FormWidget().currencyInput(
                                              controller:
                                                  _getDiscountController(
                                                      index, salesProvider),
                                              label: '0',
                                              onChanged: (value) {
                                                // Update provider immediately for subtotal recalculation
                                                int qty = int.tryParse(
                                                        _getQtyController(index,
                                                                salesProvider)
                                                            .text) ??
                                                    1;
                                                salesProvider.updateReturnItem(
                                                    index, qty, value);
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Subtotal
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _amberAccentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Subtotal:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          FormatterUtil.formatPriceWithCurrency(
                                              item.subtotal),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _amberAccentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.add_box,
                                size: 80,
                                color: _amberAccentColor.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Tidak ada item retur',
                                style: TextStyle(
                                  color: _amberAccentColor.withOpacity(0.6),
                                )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Add Return Product Button
                    if (salesProvider.returnItems.isNotEmpty)
                      FormWidget().button(
                        icon: Icons.add,
                        label: 'Tambah Produk Retur Lain',
                        callBack: _handleAddProduct,
                        backgroundColor: _amberAccentColor,
                      ),
                    if (salesProvider.returnItems.isEmpty)
                      FormWidget().button(
                        icon: Icons.add,
                        label: 'Tambah Produk Retur',
                        callBack: _handleAddProduct,
                        backgroundColor: _amberAccentColor,
                      ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(PalletConfig.padding / 2),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (salesProvider.returnItems.isNotEmpty)
                            Text(
                              'Retur: ${FormatterUtil.formatPriceWithCurrency(salesProvider.totalReturn)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _amberAccentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: _handleNext,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Lanjut'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PalletConfig.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
