import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pos_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Sistem POS', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.person, color: Colors.indigo),
                    ),
                    title: Text(authProvider.currentUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Peran: ${authProvider.currentRole}'),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Keluar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Receipt Settings Card (Header, Cashier Name, Footer)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text(
                              'Pengaturan Struk Kasir',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Atur informasi header, nama kasir default, dan footer yang akan tercetak pada struk.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const Divider(height: 24),

                        // Header Struk Input
                        const Text('Header Struk (Nama Toko & Alamat)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _headerController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Contoh:\nBIEN POS RESTO\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Kasir Input
                        const Text('Nama Kasir Default', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cashierController,
                          onChanged: (val) {
                            if (val.trim().isNotEmpty) {
                              posProvider.setCashierName(val.trim());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama kasir...',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Footer Struk Input
                        const Text('Footer Struk (Pesan Terima Kasih)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _footerController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Contoh:\n--- Terima Kasih atas Kunjungan Anda ---',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('SIMPAN PENGATURAN STRUK', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final header = _headerController.text.trim();
                              final cashier = _cashierController.text.trim();
                              final footer = _footerController.text.trim();

                              await StorageService.saveReceiptSettings(
                                header: header.isNotEmpty
                                    ? header
                                    : 'BIEN POS RESTO\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890',
                                cashierName: cashier.isNotEmpty ? cashier : 'bien',
                                footer: footer.isNotEmpty ? footer : '--- Terima Kasih atas Kunjungan Anda ---',
                              );

                              if (cashier.isNotEmpty) {
                                posProvider.setCashierName(cashier);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pengaturan struk & kasir berhasil disimpan!'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.indigo),
                    title: Text('Versi Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Bien POS Flutter Native v1.0.0 (Offline Mode)'),
                  ),
                ),
              ],
            ),
    );
  }
}
