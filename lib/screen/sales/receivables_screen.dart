import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';

class ReceivablesScreen extends StatefulWidget {
  @override
  _ReceivablesScreenState createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Piutang",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Fitur Piutang akan segera hadir'),
            SizedBox(height: 8),
            Text(
              'Silakan kembali menggunakan halaman My Sales',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
