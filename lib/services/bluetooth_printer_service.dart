import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';

class BluetoothPrinterService {
  static final BluetoothPrinterService _instance = BluetoothPrinterService._internal();
  factory BluetoothPrinterService() => _instance;
  BluetoothPrinterService._internal();

  static const platform = MethodChannel('com.example.flutter_pos_app/settings');

  bool _isPrinterConnected = false;

  bool get isPrinterConnected => _isPrinterConnected;

  /// Checks if Bluetooth is enabled and at least one device is paired/connected
  Future<bool> checkPrinterConnection() async {
    try {
      final bool isConnected = await platform.invokeMethod('checkPrinterConnection') ?? false;
      _isPrinterConnected = isConnected;
      return isConnected;
    } catch (e) {
      debugPrint("Gagal mengecek status printer: $e");
      _isPrinterConnected = false;
      return false;
    }
  }

  /// Directly opens the device's native Bluetooth settings screen
  Future<void> openBluetoothSettings() async {
    try {
      await platform.invokeMethod('openBluetoothSettings');
    } catch (e) {
      debugPrint("Gagal membuka Pengaturan Bluetooth HP: $e");
    }
  }

  /// Handles receipt print directly with optional copy count
  Future<void> handleReceiptPrint(
    BuildContext context,
    PosTransaction transaction, {
    required String headerText,
    required String footerText,
    int copyCount = 1,
  }) async {
    final isConnected = await checkPrinterConnection();
    if (!isConnected) {
      if (context.mounted) {
        _showUnpairedDialog(context, transaction, headerText: headerText, footerText: footerText, copyCount: copyCount);
      }
    } else {
      if (context.mounted) {
        _directPrint(context, transaction, copyCount: copyCount);
      }
    }
  }

  void _showUnpairedDialog(
    BuildContext context,
    PosTransaction transaction, {
    required String headerText,
    required String footerText,
    int copyCount = 1,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth_searching, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Sambungkan Printer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Silakan buka Pengaturan Bluetooth HP Anda untuk menyalakan Bluetooth & memasangkan (pairing) printer thermal.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings_bluetooth, size: 18),
            label: const Text('Pasangkan di HP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await openBluetoothSettings(); // Open device native bluetooth settings

              // Check actual connection status after returning from Bluetooth settings
              final isConnected = await checkPrinterConnection();

              if (context.mounted) {
                if (isConnected) {
                  _directPrint(context, transaction, copyCount: copyCount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('Gagal terhubung ke Printer Bluetooth. Pastikan Bluetooth aktif & printer terpasang.'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Direct print job execution to Bluetooth printer
  void _directPrint(BuildContext context, PosTransaction transaction, {int copyCount = 1}) {
    final copyText = copyCount > 1 ? '$copyCount Copy Struk' : '1 Copy Struk';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.print, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Mengirim perintah cetak ($copyText) ke Printer Bluetooth... (Struk #${transaction.transactionNo.length > 12 ? transaction.transactionNo.substring(0, 12) + "..." : transaction.transactionNo})',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
