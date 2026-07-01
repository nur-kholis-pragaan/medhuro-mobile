import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/sales_api.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/screen/customer/customer_screen.dart';
import 'package:medhuro_mobile/screen/product/product_screen.dart';
import 'package:medhuro_mobile/screen/sales/my_sales_screen.dart';
import 'package:medhuro_mobile/screen/sales/sales_wizard_screen.dart';
import 'package:medhuro_mobile/screen/sales_payment/receivables_list_screen.dart';
import 'package:medhuro_mobile/screen/sales_payment/payment_form_screen.dart';
import 'package:medhuro_mobile/screen/profile/profile_screen.dart';
import 'package:medhuro_mobile/util/formatter_util.dart';
import 'package:medhuro_mobile/widget/dialong_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userEmail = '';
  final SalesApi _salesApi = SalesApi();
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    print('HomeScreen initState called');
    debugPrint('HomeScreen initState called');
    super.initState();
    _loadUserData();
    _loadStats();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      userEmail = prefs.getString('userEmail') ?? 'user@email.com';
    });
  }

  void _loadStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    final stats = await _salesApi.getMyStats();

    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    }
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

  void _confirmLogout() {
    Dialogs().showConfirmDialog(
      context,
      GlobalKey(),
      'Apakah Anda yakin ingin keluar dari aplikasi?',
      () {
        Navigator.pop(context); // Close dialog
        _logout();
      },
    );
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
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Stats Cards Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PalletConfig.padding,
                  vertical: PalletConfig.padding / 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Penjualan',
                      style: TextStyle(
                        fontSize: PalletConfig.fontLargeSize,
                        fontWeight: FontWeight.bold,
                        color: PalletConfig.shadePrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    _isLoadingStats
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: PalletConfig.primaryColor,
                              ),
                            ),
                          )
                        : _stats == null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Gagal memuat statistik',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: _loadStats,
                                        icon: Icon(Icons.refresh),
                                        label: Text('Muat Ulang'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              PalletConfig.primaryColor,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // Row with 2 cards: Omzet Hari Ini & Omzet Bulan Ini
                                  Row(
                                    children: [
                                      // Omzet Hari Ini
                                      Expanded(
                                        child: _buildCompactStatsCard(
                                          title: 'Omzet Hari Ini',
                                          amount: _stats!['today']
                                                  ['total_amount_effective']
                                              .toDouble(),
                                          count: _stats!['today']
                                              ['transaction_count'],
                                          icon: Icons.today,
                                          gradientColors: [
                                            PalletConfig.primaryColor,
                                            PalletConfig.primaryColor
                                                .withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      // Omzet Bulan Ini
                                      Expanded(
                                        child: _buildCompactStatsCard(
                                          title: 'Omzet Bulan Ini',
                                          amount: _stats!['month']
                                                  ['total_amount_effective']
                                              .toDouble(),
                                          count: _stats!['month']
                                              ['transaction_count'],
                                          icon: Icons.calendar_month,
                                          gradientColors: [
                                            Colors.green,
                                            Colors.green.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                  ],
                ),
              ),

              SizedBox(height: 16),

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
      ),
    );
  }

  Widget _buildCompactStatsCard({
    required String title,
    required double amount,
    required int count,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(PalletConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(PalletConfig.borderRadius / 2),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              FormatterUtil.formatCurrency(amount),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '$count Trx',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
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
