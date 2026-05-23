import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/screen/sales/product_picker_screen.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:provider/provider.dart';

class SalesStep2Items extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SalesStep2Items({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _SalesStep2ItemsState createState() => _SalesStep2ItemsState();
}

class _SalesStep2ItemsState extends State<SalesStep2Items> {
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

    for (int i = 0; i < salesProvider.items.length; i++) {
      final item = salesProvider.items[i];
      qtyControllers[i] = TextEditingController(text: item.qty.toString());
      discountControllers[i] =
          TextEditingController(text: item.discountAmount.toString());
      priceControllers[i] = TextEditingController(
        text: FormatterUtil.formatPrice(item.price),
      );
      unitSelectors[i] = item.unit;
    }
  }

  /// Safely get or create a controller for the given index
  TextEditingController _getQtyController(int index, SalesProvider provider) {
    if (!qtyControllers.containsKey(index)) {
      qtyControllers[index] = TextEditingController(
        text: provider.items[index].qty.toString(),
      );
    }
    return qtyControllers[index]!;
  }

  TextEditingController _getPriceController(int index, SalesProvider provider) {
    if (!priceControllers.containsKey(index)) {
      priceControllers[index] = TextEditingController(
        text: FormatterUtil.formatPrice(provider.items[index].price),
      );
    }
    return priceControllers[index]!;
  }

  TextEditingController _getDiscountController(
      int index, SalesProvider provider) {
    if (!discountControllers.containsKey(index)) {
      discountControllers[index] = TextEditingController(
        text: provider.items[index].discountAmount.toString(),
      );
    }
    return discountControllers[index]!;
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
          title: 'Tambah Produk',
          isReturnMode: false,
        ),
      ),
    );
    // Reinitialize controllers setelah kembali
    _initializeControllers();
    setState(() {});
  }

  void _handleNext() {
    // Update semua items dari controller values
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    for (int i = 0; i < salesProvider.items.length; i++) {
      // Safely get controller values, fallback to item values if controller doesn't exist
      int qty = 1;
      int discount = 0;
      int price = 0;

      if (qtyControllers.containsKey(i)) {
        qty = int.tryParse(qtyControllers[i]!.text) ?? 1;
      } else {
        qty = salesProvider.items[i].qty;
      }

      if (discountControllers.containsKey(i)) {
        discount = int.tryParse(discountControllers[i]!.text) ?? 0;
      } else {
        discount = salesProvider.items[i].discountAmount;
      }

      if (priceControllers.containsKey(i)) {
        final priceText = priceControllers[i]!.text;
        price = priceText.isEmpty
            ? 0
            : int.tryParse(priceText.replaceAll('.', '').replaceAll(',', '')) ??
                0;
      } else {
        price = salesProvider.items[i].price;
      }

      salesProvider.updateItem(i, qty, discount);
      if (price > 0) {
        salesProvider.updateItemPrice(i, price);
      }
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        // Ensure controllers are initialized for all items
        for (int i = 0; i < salesProvider.items.length; i++) {
          if (!qtyControllers.containsKey(i)) {
            _initializeControllers();
            break;
          }
        }
        if (salesProvider.items.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Belum ada item',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PalletConfig.padding),
                child: FormWidget().button(
                  icon: Icons.add,
                  label: 'Tambah Produk',
                  callBack: _handleAddProduct,
                  backgroundColor: PalletConfig.primaryColor,
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PalletConfig.padding / 2),
                child: Column(
                  children: [
                    // Item List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: salesProvider.items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = salesProvider.items[index];

                        return Card(
                          elevation: 0,
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
                                // Product Header
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
                                        salesProvider.removeItem(index);
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
                                                } else if (newUnit == 'pack') {
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
                                                      FormatterUtil.formatPrice(
                                                          newPrice);
                                                  salesProvider.updateItemPrice(
                                                      index, newPrice);
                                                }

                                                // Update unit in provider
                                                salesProvider.updateItemUnit(
                                                    index, newUnit, newPrice);
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
                                                salesProvider.updateItem(
                                                    index, newQty, discount);
                                                setState(() {});
                                              },
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
                                    SizedBox(
                                      width: 180,
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
                                    const SizedBox(width: 8),
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
                                            controller: _getDiscountController(
                                                index, salesProvider),
                                            label: '0',
                                            onChanged: (value) {
                                              // Update provider immediately for subtotal recalculation
                                              int qty = int.tryParse(
                                                      _getQtyController(index,
                                                              salesProvider)
                                                          .text) ??
                                                  1;
                                              salesProvider.updateItem(
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
                                Builder(builder: (context) {
                                  final currentUnit =
                                      unitSelectors[index] ?? item.unit;
                                  int costPrice = 0;
                                  if (currentUnit == 'carton') {
                                    costPrice = item.costPriceCarton;
                                  } else if (currentUnit == 'pack') {
                                    costPrice = item.costPricePack;
                                  } else if (currentUnit == 'pcs') {
                                    costPrice = item.costPricePcs;
                                  }
                                  final bool isBelowCost = costPrice > 0 &&
                                      item.subtotal < costPrice * item.qty;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                              FormatterUtil
                                                  .formatPriceWithCurrency(
                                                      item.subtotal),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    PalletConfig.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isBelowCost) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.red.shade300),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Harga di bawah HPP (${FormatterUtil.formatPriceWithCurrency(costPrice)})',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Add More Products Button
                    FormWidget().button(
                      icon: Icons.add,
                      label: 'Tambah Produk Lain',
                      callBack: _handleAddProduct,
                      backgroundColor: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 100), // Space for bottom summary
                  ],
                ),
              ),
            ),
            // Sticky Summary at Bottom
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total: ${FormatterUtil.formatPriceWithCurrency(salesProvider.totalSales)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${salesProvider.totalItems} item',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _handleNext,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Lanjut'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PalletConfig.primaryColor,
                              foregroundColor: Colors.white,
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
