import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/confirmation_screen.dart';
import 'package:provider/provider.dart';
import 'package:medhuro_mobile/provider/sales_provider.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<int, TextEditingController> qtyControllers;
  late Map<int, TextEditingController> discountControllers;

  @override
  void initState() {
    super.initState();
    final items = Provider.of<SalesProvider>(context, listen: false).items;
    qtyControllers = {};
    discountControllers = {};
    for (int i = 0; i < items.length; i++) {
      qtyControllers[i] = TextEditingController(text: items[i].qty.toString());
      discountControllers[i] = TextEditingController(
        text: items[i].discountAmount.toString(),
      );
    }
  }

  @override
  void dispose() {
    qtyControllers.forEach((key, controller) {
      controller.dispose();
    });
    discountControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Cart",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: Consumer<SalesProvider>(
        builder: (context, salesProvider, child) {
          if (salesProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Cart masih kosong'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(PalletConfig.padding / 2),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: salesProvider.items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = salesProvider.items[index];
                      int itemPrice = item.price * item.qty;
                      int itemDiscount = item.discountAmount;
                      int itemSubtotal = itemPrice - itemDiscount;

                      return Card(
                        elevation: 0,
                        color: Colors.white,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Kode: ${item.productCode}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Unit: ${item.unit.toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      salesProvider.removeItem(index);
                                      qtyControllers.remove(index);
                                      discountControllers.remove(index);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: PalletConfig.shadeSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Harga:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          FormatterUtil.formatPriceWithCurrency(
                                              item.price),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Qty:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: FormWidget().numericInput(
                                            controller: qtyControllers[index]!,
                                            label: 'Qty',
                                            minValue: 1,
                                            onChanged: (newQty) {
                                              int discount = int.tryParse(
                                                    discountControllers[index]!
                                                        .text
                                                        .replaceAll('.', ''),
                                                  ) ??
                                                  0;
                                              salesProvider.updateItem(
                                                index,
                                                newQty,
                                                discount,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Diskon:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: FormWidget().currencyInput(
                                            controller:
                                                discountControllers[index]!,
                                            label: 'Diskon',
                                            onChanged: (discount) {
                                              int qty = int.tryParse(
                                                    qtyControllers[index]!.text,
                                                  ) ??
                                                  1;
                                              salesProvider.updateItem(
                                                index,
                                                qty,
                                                discount,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    FormatterUtil.formatPriceWithCurrency(
                                        itemSubtotal),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: PalletConfig.primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(PalletConfig.padding / 2),
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
                            Text('Subtotal:'),
                            Text(FormatterUtil.formatPriceWithCurrency(
                                salesProvider.subtotal)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Diskon:'),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  salesProvider.totalDiscount),
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
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              FormatterUtil.formatPriceWithCurrency(
                                  salesProvider.totalAmount),
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
                  SizedBox(height: 20),
                  FormWidget().button(
                    icon: Icons.check,
                    label: 'Lanjutkan',
                    callBack: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(),
                      ));
                    },
                    backgroundColor: PalletConfig.primaryColor,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
