import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/sales/sales_step1_header.dart';
import 'package:medhuro_mobile/screen/sales/sales_step2_items.dart';
import 'package:medhuro_mobile/screen/sales/sales_step3_return.dart';
import 'package:medhuro_mobile/screen/sales/sales_step4_confirmation.dart';

enum SalesWizardStep { header, items, returnItems, confirmation }

class SalesWizardScreen extends StatefulWidget {
  @override
  _SalesWizardScreenState createState() => _SalesWizardScreenState();
}

class _SalesWizardScreenState extends State<SalesWizardScreen> {
  late PageController _pageController;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    setState(() {
      _currentStepIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStepIndex < 3) {
      _goToStep(_currentStepIndex + 1);
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _goToStep(_currentStepIndex - 1);
    }
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Informasi Penjualan';
      case 1:
        return 'Item Penjualan';
      case 2:
        return 'Item Retur';
      case 3:
        return 'Konfirmasi & Pembayaran';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStepIndex > 0) {
          _previousStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(
            _getStepTitle(_currentStepIndex),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: PalletConfig.primaryColor,
          leading: _currentStepIndex > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              : null,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  bool isActive = index <= _currentStepIndex;
                  bool isCurrent = index == _currentStepIndex;

                  return GestureDetector(
                    onTap: isActive ? () => _goToStep(index) : null,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isActive
                              ? PalletConfig.primaryColor
                              : Colors.grey.shade300,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ['Info', 'Item', 'Retur', 'Bayar'][index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? PalletConfig.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            // Divider
            Divider(height: 1),
            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStepIndex = index;
                  });
                },
                children: [
                  // Step 1: Header
                  SalesStep1Header(
                    onNext: _nextStep,
                  ),
                  // Step 2: Sales Items
                  SalesStep2Items(
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  // Step 3: Return Items
                  SalesStep3ReturnItems(
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  // Step 4: Confirmation
                  SalesStep4Confirmation(
                    onBack: _previousStep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
