import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'cashier_screen.dart';
import 'products_screen.dart';
import 'transactions_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({Key? key}) : super(key: key);

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CashierScreen(),
    ProductsScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isTabletLandscape = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.point_of_sale, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text(
              'BIEN POS RESTO',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 18),
            ),
            const Spacer(),
            Chip(
              avatar: const Icon(Icons.person, size: 16),
              label: Text(authProvider.currentUserName, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.indigo.shade50,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Row(
        children: [
          if (isTabletLandscape)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.indigo),
              selectedLabelTextStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.storefront), label: Text('Kasir')),
                NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Produk')),
                NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Transaksi')),
                NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Laporan')),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Pengaturan')),
              ],
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isTabletLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Kasir'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
              ],
            ),
    );
  }
}
