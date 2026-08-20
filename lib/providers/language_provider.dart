import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'id';

  String get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == 'en';
  bool get isIndonesian => _currentLanguage == 'id';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    _currentLanguage = await StorageService.getLanguage();
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    _currentLanguage = langCode;
    await StorageService.saveLanguage(langCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final nextLang = _currentLanguage == 'id' ? 'en' : 'id';
    await setLanguage(nextLang);
  }

  String tr(String key) {
    if (_localizedValues.containsKey(_currentLanguage)) {
      if (_localizedValues[_currentLanguage]!.containsKey(key)) {
        return _localizedValues[_currentLanguage]![key]!;
      }
    }
    // Fallback to Indonesian if key missing in target language
    if (_localizedValues['id']!.containsKey(key)) {
      return _localizedValues['id']![key]!;
    }
    return key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // Navigation
      'nav_cashier': 'Kasir',
      'nav_products': 'Produk',
      'nav_transactions': 'Transaksi',
      'nav_reports': 'Laporan',
      'nav_settings': 'Pengaturan',

      // App Header & Profile
      'role': 'Peran',
      'logout': 'Keluar',

      // Login Screen
      'login_title': 'Masuk ke Sistem POS',
      'login_subtitle': 'Silakan masukkan username dan password Anda',
      'username_label': 'Nama Pengguna (Username)',
      'password_label': 'Kata Sandi (Password)',
      'login_btn': 'MASUK SEKARANG',
      'login_error': 'Username atau password salah!',
      'demo_accounts': 'Akun Demo Tersedia:',

      // Cashier Screen
      'search_product_hint': 'Cari produk berdasarkan nama atau SKU...',
      'category_all': 'Semua',
      'view_cart': 'Lihat Keranjang',
      'cart_empty': 'Keranjang Masih Kosong',
      'cart_empty_desc': 'Pilih produk dari katalog untuk ditambahkan ke transaksi',
      'checkout_btn': 'BAYAR SEKARANG',
      'subtotal': 'Subtotal',
      'tax': 'Pajak',
      'discount': 'Diskon',
      'grand_total': 'Total Bayar',
      'items_count': 'item',
      'clear_cart': 'Kosongkan',

      // Payment Dialog
      'payment_title': 'Pembayaran Kasir',
      'payment_method': 'Metode Pembayaran',
      'cash': 'Tunai (Cash)',
      'qris': 'QRIS / E-Wallet',
      'card': 'Kartu Debit/Kredit',
      'amount_paid': 'Jumlah Uang Diterima',
      'quick_nominal': 'Nominal Cepat',
      'exact_amount': 'Uang Pas',
      'change_due': 'Kembalian',
      'insufficient_amount': 'Uang diterima kurang dari total!',
      'process_payment': 'PROSES PEMBAYARAN',
      'payment_success': 'Pembayaran Berhasil!',

      // Receipt Dialog
      'receipt_title': 'Struk Pembayaran',
      'print_receipt': 'Cetak Struk',
      'print_success': 'Struk berhasil dicetak!',
      'close': 'Tutup',
      'new_transaction': 'Transaksi Baru',
      'transaction_no': 'No. Transaksi',
      'date': 'Tanggal',
      'cashier': 'Kasir',

      // Products Screen
      'products_title': 'Manajemen Produk',
      'add_product': 'Tambah Produk Baru',
      'edit_product': 'Edit Produk',
      'delete_product': 'Hapus Produk',
      'confirm_delete': 'Apakah Anda yakin ingin menghapus produk ini?',
      'product_name': 'Nama Produk',
      'product_category': 'Kategori',
      'product_price': 'Harga Jual (Rp)',
      'product_cost': 'Harga Modal (Rp)',
      'product_stock': 'Stok Saat Ini',
      'product_sku': 'Kode Barcode / SKU',
      'product_image': 'URL Gambar Produk',
      'save_product': 'SIMPAN PRODUK',
      'cancel': 'Batal',
      'stock_low': 'Stok Menipis',
      'stock_available': 'Stok',

      // Transactions Screen
      'transactions_title': 'Riwayat Transaksi',
      'search_transaction_hint': 'Cari transaksi berdasarkan No. Struk...',
      'all_payments': 'Semua Pembayaran',
      'no_transactions': 'Belum ada transaksi recorded',
      'reprint_receipt': 'Cetak Ulang Struk',

      // Reports Screen
      'reports_title': 'Laporan & Analitik POS',
      'total_sales': 'Total Omset / Penjualan',
      'total_profit': 'Estimasi Keuntungan',
      'total_tx_count': 'Jumlah Transaksi',
      'shift_closing': 'Tutup Kasir / Shift',
      'best_selling': 'Produk Terlaris',
      'cash_flow': 'Arus Kas (Cash Flow)',
      'inflow': 'Kas Masuk',
      'outflow': 'Kas Keluar',
      'commission_rate': 'Komisi (%)',

      // Settings Screen
      'settings_title': 'Pengaturan Sistem POS',
      'language_settings': 'Pengaturan Bahasa / Language',
      'language_desc': 'Pilih bahasa tampilan aplikasi.',
      'indonesian': 'Bahasa Indonesia 🇮🇩',
      'english': 'English 🇬🇧',
      'receipt_settings': 'Pengaturan Struk Kasir',
      'receipt_settings_desc': 'Atur informasi header, nama kasir default, dan footer yang akan tercetak pada struk.',
      'receipt_header': 'Header Struk (Nama Toko & Alamat)',
      'cashier_default_name': 'Nama Kasir Default',
      'receipt_footer': 'Footer Struk (Pesan Terima Kasih)',
      'save_receipt_settings': 'SIMPAN PENGATURAN STRUK',
      'settings_saved': 'Pengaturan berhasil disimpan!',
      'app_version': 'Versi Aplikasi',
    },
    'en': {
      // Navigation
      'nav_cashier': 'Cashier',
      'nav_products': 'Products',
      'nav_transactions': 'Transactions',
      'nav_reports': 'Reports',
      'nav_settings': 'Settings',

      // App Header & Profile
      'role': 'Role',
      'logout': 'Logout',

      // Login Screen
      'login_title': 'Login to POS System',
      'login_subtitle': 'Please enter your username and password',
      'username_label': 'Username',
      'password_label': 'Password',
      'login_btn': 'LOGIN NOW',
      'login_error': 'Invalid username or password!',
      'demo_accounts': 'Available Demo Accounts:',

      // Cashier Screen
      'search_product_hint': 'Search product by name or SKU...',
      'category_all': 'All',
      'view_cart': 'View Cart',
      'cart_empty': 'Cart is Empty',
      'cart_empty_desc': 'Select items from catalog to add to transaction',
      'checkout_btn': 'CHECKOUT NOW',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'discount': 'Discount',
      'grand_total': 'Grand Total',
      'items_count': 'items',
      'clear_cart': 'Clear',

      // Payment Dialog
      'payment_title': 'Cashier Payment',
      'payment_method': 'Payment Method',
      'cash': 'Cash',
      'qris': 'QRIS / E-Wallet',
      'card': 'Debit/Credit Card',
      'amount_paid': 'Amount Received',
      'quick_nominal': 'Quick Cash',
      'exact_amount': 'Exact Amount',
      'change_due': 'Change Due',
      'insufficient_amount': 'Amount received is less than total!',
      'process_payment': 'PROCESS PAYMENT',
      'payment_success': 'Payment Successful!',

      // Receipt Dialog
      'receipt_title': 'Transaction Receipt',
      'print_receipt': 'Print Receipt',
      'print_success': 'Receipt printed successfully!',
      'close': 'Close',
      'new_transaction': 'New Transaction',
      'transaction_no': 'Transaction No.',
      'date': 'Date',
      'cashier': 'Cashier',

      // Products Screen
      'products_title': 'Product Management',
      'add_product': 'Add New Product',
      'edit_product': 'Edit Product',
      'delete_product': 'Delete Product',
      'confirm_delete': 'Are you sure you want to delete this product?',
      'product_name': 'Product Name',
      'product_category': 'Category',
      'product_price': 'Selling Price (Rp)',
      'product_cost': 'Cost Price (Rp)',
      'product_stock': 'Current Stock',
      'product_sku': 'Barcode / SKU Code',
      'product_image': 'Product Image URL',
      'save_product': 'SAVE PRODUCT',
      'cancel': 'Cancel',
      'stock_low': 'Low Stock',
      'stock_available': 'Stock',

      // Transactions Screen
      'transactions_title': 'Transaction History',
      'search_transaction_hint': 'Search transaction by receipt no...',
      'all_payments': 'All Payments',
      'no_transactions': 'No recorded transactions yet',
      'reprint_receipt': 'Reprint Receipt',

      // Reports Screen
      'reports_title': 'POS Reports & Analytics',
      'total_sales': 'Total Sales Revenue',
      'total_profit': 'Estimated Profit',
      'total_tx_count': 'Total Transactions',
      'shift_closing': 'Shift Closing',
      'best_selling': 'Best Selling Products',
      'cash_flow': 'Cash Flow',
      'inflow': 'Cash In',
      'outflow': 'Cash Out',
      'commission_rate': 'Commission (%)',

      // Settings Screen
      'settings_title': 'POS System Settings',
      'language_settings': 'Language Settings',
      'language_desc': 'Select application display language.',
      'indonesian': 'Indonesian 🇮🇩',
      'english': 'English 🇬🇧',
      'receipt_settings': 'Cashier Receipt Settings',
      'receipt_settings_desc': 'Configure header, default cashier name, and footer printed on receipts.',
      'receipt_header': 'Receipt Header (Store Name & Address)',
      'cashier_default_name': 'Default Cashier Name',
      'receipt_footer': 'Receipt Footer (Thank You Message)',
      'save_receipt_settings': 'SAVE RECEIPT SETTINGS',
      'settings_saved': 'Settings saved successfully!',
      'app_version': 'App Version',
    }
  };
}
