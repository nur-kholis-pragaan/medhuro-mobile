import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/customer/customer_screen.dart';
import 'package:medhuro_mobile/screen/product/product_screen.dart';
import 'package:medhuro_mobile/screen/sales/my_sales_screen.dart';
import 'package:medhuro_mobile/screen/sales/receivables_screen.dart';
import 'package:medhuro_mobile/screen/sales/sales_wizard_screen.dart';
import 'package:medhuro_mobile/screen/sales_payment/receivables_list_screen.dart';
import 'package:medhuro_mobile/screen/sales_payment/payment_form_screen.dart';
import 'package:medhuro_mobile/screen/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    print('HomeScreen initState called');
    debugPrint('HomeScreen initState called');
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      userEmail = prefs.getString('userEmail') ?? 'user@email.com';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD HOME');
    debugPrint('BUILD HOME');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medhuro',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        backgroundColor: PalletConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Container(
              padding: const EdgeInsets.all(PalletConfig.padding),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PalletConfig.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Selamat Datang 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Section
            Padding(
              padding: const EdgeInsets.all(PalletConfig.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: PalletConfig.fontLargeSize,
                      fontWeight: FontWeight.bold,
                      color: PalletConfig.shadePrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildMenuCard(
                        icon: Icons.shopping_bag,
                        title: 'Produk',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(ProductScreen()),
                      ),
                      _buildMenuCard(
                        icon: Icons.add_circle_outline,
                        title: 'Buat Penjualan',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(SalesWizardScreen()),
                      ),
                      _buildMenuCard(
                        icon: Icons.receipt_long,
                        title: 'Penjualan Saya',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(MySalesScreen()),
                      ),
                      _buildMenuCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Daftar Piutang',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(ReceivablesListScreen()),
                      ),
                      _buildMenuCard(
                        icon: Icons.payment,
                        title: 'Bayar Piutang',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(PaymentFormScreen()),
                      ),
                      _buildMenuCard(
                        icon: Icons.people,
                        title: 'Pelanggan',
                        color: PalletConfig.primaryColor,
                        onTap: () => _navigateTo(CustomerScreen()),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: PalletConfig.fontLargeSize,
                      fontWeight: FontWeight.bold,
                      color: PalletConfig.shadePrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _buildMenuCard(
                      icon: Icons.person,
                      title: 'Profil',
                      color: PalletConfig.primaryColor,
                      onTap: () => _navigateTo(const ProfileScreen()),
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PalletConfig.padding / 2),
          child: isFullWidth
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              PalletConfig.borderRadius / 2,
                            ),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: PalletConfig.fontMediumSize,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          PalletConfig.borderRadius / 2,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $feature akan segera hadir'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
