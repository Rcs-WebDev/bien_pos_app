import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
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
    final langProvider = Provider.of<LanguageProvider>(context);
    final isTabletLandscape = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.point_of_sale, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text(
              'BIEN POS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo,
                  fontSize: 18),
            ),
            const Spacer(),

            // Language Toggle Switcher Button
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: Icon(
                Icons.language,
                size: 18,
                color: Colors.indigo.shade700,
              ),
              label: Text(
                langProvider.isEnglish ? 'EN 🇬🇧' : 'ID 🇮🇩',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.indigo.shade900,
                ),
              ),
              onPressed: () {
                langProvider.toggleLanguage();
              },
            ),
            const SizedBox(width: 8),

            Chip(
              avatar: const Icon(Icons.person, size: 16),
              label: Text(authProvider.currentUserName,
                  style: const TextStyle(fontSize: 12)),
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
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.indigo),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.indigo, fontWeight: FontWeight.bold),
              destinations: [
                NavigationRailDestination(
                    icon: const Icon(Icons.storefront),
                    label: Text(langProvider.tr('nav_cashier'))),
                NavigationRailDestination(
                    icon: const Icon(Icons.inventory_2),
                    label: Text(langProvider.tr('nav_products'))),
                NavigationRailDestination(
                    icon: const Icon(Icons.receipt_long),
                    label: Text(langProvider.tr('nav_transactions'))),
                NavigationRailDestination(
                    icon: const Icon(Icons.bar_chart),
                    label: Text(langProvider.tr('nav_reports'))),
                NavigationRailDestination(
                    icon: const Icon(Icons.settings),
                    label: Text(langProvider.tr('nav_settings'))),
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
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.storefront),
                    label: langProvider.tr('nav_cashier')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.inventory_2),
                    label: langProvider.tr('nav_products')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.receipt_long),
                    label: langProvider.tr('nav_transactions')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.bar_chart),
                    label: langProvider.tr('nav_reports')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: langProvider.tr('nav_settings')),
              ],
            ),
    );
  }
}
