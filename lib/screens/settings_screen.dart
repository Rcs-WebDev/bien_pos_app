import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pos_provider.dart';
import '../providers/language_provider.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _cashierController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getReceiptSettings();
    setState(() {
      _headerController.text = settings['header'] ?? '';
      _cashierController.text = settings['cashierName'] ?? '';
      _footerController.text = settings['footer'] ?? '';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cashierController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final posProvider = Provider.of<PosProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('settings_title'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.person, color: Colors.indigo),
                    ),
                    title: Text(authProvider.currentUserName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${langProvider.tr('role')}: ${authProvider.currentRole}'),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 16),
                      label: Text(langProvider.tr('logout')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red),
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Language Switcher Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              langProvider.tr('language_settings'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          langProvider.tr('language_desc'),
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => langProvider.setLanguage('id'),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: langProvider.isIndonesian
                                        ? Colors.indigo.shade50
                                        : Colors.grey.shade100,
                                    border: Border.all(
                                      color: langProvider.isIndonesian
                                          ? Colors.indigo
                                          : Colors.grey.shade300,
                                      width: langProvider.isIndonesian ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        langProvider.tr('indonesian'),
                                        style: TextStyle(
                                          fontWeight: langProvider.isIndonesian
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: langProvider.isIndonesian
                                              ? Colors.indigo
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (langProvider.isIndonesian) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle, size: 18, color: Colors.indigo),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => langProvider.setLanguage('en'),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: langProvider.isEnglish
                                        ? Colors.indigo.shade50
                                        : Colors.grey.shade100,
                                    border: Border.all(
                                      color: langProvider.isEnglish
                                          ? Colors.indigo
                                          : Colors.grey.shade300,
                                      width: langProvider.isEnglish ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        langProvider.tr('english'),
                                        style: TextStyle(
                                          fontWeight: langProvider.isEnglish
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: langProvider.isEnglish
                                              ? Colors.indigo
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (langProvider.isEnglish) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle, size: 18, color: Colors.indigo),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Receipt Settings Card (Header, Cashier Name, Footer)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              langProvider.tr('receipt_settings'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          langProvider.tr('receipt_settings_desc'),
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const Divider(height: 24),

                        // Header Struk Input
                        Text(langProvider.tr('receipt_header'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _headerController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Contoh:\nBIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Kasir Input
                        Text(langProvider.tr('cashier_default_name'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cashierController,
                          onChanged: (val) {
                            if (val.trim().isNotEmpty) {
                              posProvider.setCashierName(val.trim());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: langProvider.tr('cashier_default_name'),
                            prefixIcon:
                                const Icon(Icons.badge_outlined, size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Footer Struk Input
                        Text(langProvider.tr('receipt_footer'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _footerController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText:
                                'Contoh:\n--- Terima Kasih atas Kunjungan Anda ---',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            label: Text(langProvider.tr('save_receipt_settings'),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final header = _headerController.text.trim();
                              final cashier = _cashierController.text.trim();
                              final footer = _footerController.text.trim();

                              await StorageService.saveReceiptSettings(
                                header: header.isNotEmpty
                                    ? header
                                    : 'BIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890',
                                cashierName:
                                    cashier.isNotEmpty ? cashier : 'bien',
                                footer: footer.isNotEmpty
                                    ? footer
                                    : '--- Terima Kasih atas Kunjungan Anda ---',
                              );

                              if (cashier.isNotEmpty) {
                                posProvider.setCashierName(cashier);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      langProvider.tr('settings_saved')),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Info App Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.indigo),
                    title: Text(langProvider.tr('app_version'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        const Text('Bien POS Flutter Native v1.0.0 (Offline Mode)'),
                  ),
                ),
              ],
            ),
    );
  }
}
