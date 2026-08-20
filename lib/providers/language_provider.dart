import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

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

  String tr(String key, {Map<String, String>? args}) {
    String value = key;
    if (_localizedValues.containsKey(_currentLanguage)) {
      if (_localizedValues[_currentLanguage]!.containsKey(key)) {
        value = _localizedValues[_currentLanguage]![key]!;
      }
    }
    // Fallback to English if key missing in target language
    if (value == key && _localizedValues['en']!.containsKey(key)) {
      value = _localizedValues['en']![key]!;
    }
    // Fallback to Indonesian
    if (value == key && _localizedValues['id']!.containsKey(key)) {
      value = _localizedValues['id']![key]!;
    }
    if (args != null) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // Navigation
      'nav_cashier': 'Kasir',
      'nav_products': 'Produk',
      'nav_transactions': 'Transaksi',
      'nav_reports': 'Laporan',
      'nav_settings': 'Pengaturan',

      // Categories
      'cat_all': 'Semua Kategori',
      'cat_all_short': 'Semua',
      'cat_food': 'Makanan',
      'cat_drink': 'Minuman',
      'cat_snack': 'Cemilan',
      'cat_combo': 'Paket Hemat',

      // App Header & Profile
      'role': 'Peran',
      'logout': 'Keluar',
      'staff': 'Staff',
      'manager': 'Manager',

      // Login Screen
      'login_title': 'Masuk ke Sistem POS',
      'login_subtitle': 'Silakan masukkan username dan password Anda',
      'username_label': 'Nama Pengguna (Username)',
      'password_label': 'Kata Sandi (Password)',
      'password_pin_role': 'Password / PIN {role}',
      'pin_hint_staff': 'Default PIN Staff: staff123',
      'pin_hint_manager': 'Default PIN Manager: manager123',
      'login_btn': 'MASUK SEKARANG',
      'login_error': 'Username atau password salah!',
      'demo_accounts': 'Akun Demo Tersedia:',

      // Cashier Screen & Cart Drawer
      'search_product_barcode_hint': 'Cari Produk, SKU, atau Scan Barcode...',
      'no_products_found': 'Tidak ada produk ditemukan',
      'cart_title': 'Keranjang',
      'clear_cart_tooltip': 'Kosongkan Keranjang',
      'order_type_dine_in': 'DINE-IN (1 Pax)',
      'order_type_takeaway': 'TAKEAWAY',
      'order_type_online': 'ONLINE DELIVERY',
      'cart_empty_title': 'Keranjang masih kosong',
      'cart_empty_desc': 'Pilih produk dari katalog untuk ditambahkan ke transaksi',
      'checkout_btn': 'BAYAR SEKARANG',
      'subtotal': 'Subtotal',
      'tax': 'Pajak',
      'discount': 'Diskon',
      'grand_total': 'Total Bayar',
      'items_count': 'item',
      'clear_cart': 'Kosongkan',

      // Payment Dialog
      'payment_title': 'Pembayaran POS',
      'total_due_banner': 'TOTAL HARUS DIBAYAR',
      'customer_name': 'Nama Customer',
      'customer_name_hint': 'Masukkan nama customer (opsional)',
      'payment_method': 'Metode Pembayaran',
      'cash': 'CASH',
      'qris_bca': 'QRIS BCA',
      'card': 'Kartu Debit/Kredit',
      'amount_paid_rp': 'Jumlah Uang Diterima (Rp)',
      'quick_nominal': 'Nominal Cepat',
      'exact_amount': 'Uang Pas',
      'change_due_label': 'Uang Kembalian',
      'insufficient_amount': 'Uang diterima kurang dari total!',
      'process_payment': 'PROSES PEMBAYARAN',
      'finish_transaction_btn': 'SELESAIKAN TRANSAKSI',
      'payment_success': 'Pembayaran Berhasil!',

      // Receipt Dialog & Printer Service
      'receipt_title': 'Transaksi Sukses',
      'thermal_receipt': 'Struk Pembayaran',
      'print_receipt': 'Cetak Struk',
      'print_copy': 'Cetak ({count} Copy)',
      'print_success': 'Struk berhasil dicetak!',
      'close': 'Tutup',
      'new_transaction': 'TRANSAKSI BARU',
      'transaction_no': 'No. Transaksi',
      'date': 'Tanggal',
      'cashier': 'Kasir',
      'customer': 'Customer',
      'type': 'Tipe',
      'status_success': 'Status: SUKSES',
      'receipt_copy_count': 'Jumlah Copy Struk:',
      'connect_printer_title': 'Sambungkan Printer',
      'connect_printer_desc': 'Silakan buka Pengaturan Bluetooth HP Anda untuk menyalakan Bluetooth & memasangkan (pairing) printer thermal.',
      'pair_on_phone': 'Pasangkan di HP',
      'printer_connect_failed': 'Gagal terhubung ke Printer Bluetooth. Pastikan Bluetooth aktif & printer terpasang.',
      'sending_print_job': 'Mengirim perintah cetak ({copyText}) ke Printer Bluetooth... (Struk #{no})',

      // Products Screen
      'products_title': 'Manajemen Produk & Stok',
      'add_product': 'Tambah Produk Baru',
      'search_product_sku_hint': 'Cari Produk / SKU...',
      'sku': 'SKU',
      'variant': 'Varian',
      'price': 'Harga',
      'cost': 'Modal',
      'stock': 'Stok',
      'edit_product_tooltip': 'Edit Detail & Foto Produk',
      'delete_product_tooltip': 'Hapus Produk',
      'stock_adjustment_title': 'Penyesuaian Stok',
      'new_stock_qty': 'Jumlah Stok Baru',
      'delete_product': 'Hapus Produk',
      'confirm_delete': 'Apakah Anda yakin ingin menghapus "{name}"?',
      'product_name': 'Nama Produk',
      'product_category': 'Kategori',
      'product_price': 'Harga Jual (Rp)',
      'product_cost': 'Harga Modal (Rp)',
      'product_stock': 'Stok Saat Ini',
      'product_sku': 'Kode Barcode / SKU',
      'product_image': 'URL Gambar Produk',
      'save_product': 'SIMPAN PRODUK',
      'save_changes': 'SIMPAN PERUBAHAN',
      'cancel': 'Batal',
      'save': 'Simpan',
      'delete': 'Hapus',
      'stock_low': 'Stok Menipis',
      'stock_available': 'Stok',
      'variant_desc': 'Varian / Keterangan',
      'unit': 'Satuan Unit',
      'unit_desc': 'Satuan (Porsi/Gelas)',
      'initial_stock': 'Stok Awal',
      'product_photo': 'Foto Produk',
      'url_file_path': 'URL Foto / Path File Perangkat',
      'photo_hint': 'https://... atau /storage/emulated/0/...',
      'select_from_device': 'Pilih dari Perangkat',
      'photo_selected_snack': 'Foto dipilih dari galeri/perangkat',
      'change_photo_device': 'Ganti Foto Produk dari Perangkat',
      'upload_gallery': 'Upload dari Galeri / File',
      'photo_success_snack': 'Foto berhasil dipilih dari perangkat!',
      'product_updated_snack': 'Detail produk "{name}" berhasil diperbarui!',
      'barcode': 'Barcode',

      // Transactions Screen
      'transactions_title': 'Riwayat Transaksi Kasir',
      'filter_by_date_all': 'Filter Per Tanggal: (Semua)',
      'filter_date_selected': 'Tanggal: {date}',
      'reset_date_filter': 'Reset Filter Tanggal',
      'total_tx_count_fmt': 'Total: {count} Transaksi',
      'total_omzet_fmt': 'Omzet: {amount}',
      'search_transaction_hint': 'Cari transaksi berdasarkan No. Struk...',
      'all_payments': 'Semua Pembayaran',
      'no_transactions': 'Belum ada riwayat transaksi',
      'no_transactions_date': 'Tidak ada transaksi pada tanggal {date}',
      'reprint_receipt': 'Cetak Ulang Struk',

      // Reports Screen
      'reports_title': 'Laporan & Analisis POS',
      'tab_shift_method': 'Laporan Shift & Metode',
      'tab_pnl': 'Ringkasan Laba Rugi (P&L)',
      'filter_date_all_period': 'Filter Tanggal: Semua Periode',
      'filter_date_fmt': 'Filter Tanggal: {date}',
      'select_date': 'Pilih Tanggal',
      'change_date': 'Ubah',
      'total_sales': 'Total Omzet Penjualan',
      'all_methods_subtitle': 'Keseluruhan metode',
      'total_tx_count': 'Total Transaksi',
      'receipts_issued': 'Jumlah struk terbit',
      'total_cash_sales': 'Total Transaksi Cash',
      'cash_tx_subtitle': '{count} Transaksi Tunai',
      'total_qris_sales': 'Total Transaksi QRIS',
      'qris_tx_subtitle': '{count} Transaksi Non-Tunai',
      'total_dine_in': 'Total Dine-In',
      'dine_in_subtitle': '{count} Pesanan Makan di Tempat',
      'total_takeaway': 'Total Takeaway',
      'takeaway_subtitle': '{count} Pesanan Bawa Pulang',
      'shift_closing': 'Penutupan Shift Kasir',
      'shift_closing_desc': 'Rekap omzet, QRIS, & tunai shift ini',
      'close_shift': 'Tutup Shift',
      'shift_history_title': 'Riwayat Penutupan Shift',
      'no_shift_closings': 'Belum ada penutupan shift recorded',
      'omzet_label': 'Omzet',
      'cash_label': 'Tunai',
      'qris_label': 'QRIS',
      'time_label': 'Waktu',
      'pnl_report_title': 'Laporan Ringkasan Laba Rugi',
      'pnl_subtitle': '(Income Statement / P&L)',
      'pnl_sec1': '1. PENDAPATAN OPERASIONAL',
      'pnl_gross_sales': 'Penjualan Kotor Kasir POS',
      'pnl_discounts': 'Potongan Diskon Pesanan',
      'pnl_net_revenue': 'PENDAPATAN BERSIH (NET REVENUE)',
      'pnl_sec2': '2. HARGA POKOK PENJUALAN (HPP / COGS)',
      'pnl_raw_materials': 'Biaya Bahan Baku Terpakai ({percent}%)',
      'pnl_gross_profit': 'LABA KOTOR (GROSS PROFIT)',
      'pnl_sec3': '3. BEBAN OPERASIONAL (OPEX)',
      'pnl_petty_cash': 'Pengeluaran Kas Keluar (Petty Cash)',
      'pnl_opex_est': 'Estimasi Gaji & Operasional',
      'pnl_total_opex': 'TOTAL BEBAN OPERASIONAL',
      'pnl_net_profit': 'LABA / (RUGI) BERSIH RESTO\n(NET PROFIT)',
      'pnl_settings_title': 'Pengaturan Parameter P&L',
      'cogs_percent_label': 'Persentase Estimasi HPP / COGS (%)',
      'cogs_percent_hint': 'Misal: 45',
      'opex_est_label': 'Estimasi Beban Operasional OPEX (Rp)',
      'opex_est_hint': 'Misal: 100000',
      'shift_close_confirm_title': 'Konfirmasi Tutup Shift Kasir',
      'active_cashier_label': 'Kasir Aktif',
      'shift_notes_label': 'Catatan Penutupan Shift (Opsional)',
      'process_shift_close': 'PROSES TUTUP SHIFT',
      'shift_closed_snack': 'Shift {no} berhasil ditutup!',

      // Settings Screen
      'settings_title': 'Pengaturan Sistem POS',
      'language_settings': 'Pengaturan Bahasa / Language',
      'language_desc': 'Pilih bahasa tampilan aplikasi.',
      'indonesian': 'Bahasa Indonesia 🇮🇩',
      'english': 'English 🇬🇧',
      'receipt_settings': 'Pengaturan Struk Kasir',
      'receipt_settings_desc': 'Atur informasi header, nama kasir default, dan footer yang akan tercetak pada struk.',
      'receipt_header': 'Header Struk (Nama Toko & Alamat)',
      'receipt_header_hint': 'Contoh:\nBIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890',
      'cashier_default_name': 'Nama Kasir Default',
      'receipt_footer': 'Footer Struk (Pesan Terima Kasih)',
      'receipt_footer_hint': 'Contoh:\n--- Terima Kasih atas Kunjungan Anda ---',
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

      // Categories
      'cat_all': 'All Categories',
      'cat_all_short': 'All',
      'cat_food': 'Foods',
      'cat_drink': 'Beverages',
      'cat_snack': 'Snacks',
      'cat_combo': 'Combo Deals',

      // App Header & Profile
      'role': 'Role',
      'logout': 'Logout',
      'staff': 'Staff',
      'manager': 'Manager',

      // Login Screen
      'login_title': 'Login to POS System',
      'login_subtitle': 'Please enter your username and password',
      'username_label': 'Username',
      'password_label': 'Password',
      'password_pin_role': '{role} Password / PIN',
      'pin_hint_staff': 'Default Staff PIN: staff123',
      'pin_hint_manager': 'Default Manager PIN: manager123',
      'login_btn': 'LOGIN NOW',
      'login_error': 'Invalid username or password!',
      'demo_accounts': 'Available Demo Accounts:',

      // Cashier Screen & Cart Drawer
      'search_product_barcode_hint': 'Search Product, SKU, or Scan Barcode...',
      'no_products_found': 'No products found',
      'cart_title': 'Cart',
      'clear_cart_tooltip': 'Clear Cart',
      'order_type_dine_in': 'DINE-IN (1 Pax)',
      'order_type_takeaway': 'TAKEAWAY',
      'order_type_online': 'ONLINE DELIVERY',
      'cart_empty_title': 'Cart is empty',
      'cart_empty_desc': 'Select items from catalog to add to transaction',
      'checkout_btn': 'CHECKOUT NOW',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'discount': 'Discount',
      'grand_total': 'Grand Total',
      'items_count': 'items',
      'clear_cart': 'Clear',

      // Payment Dialog
      'payment_title': 'POS Payment',
      'total_due_banner': 'TOTAL AMOUNT DUE',
      'customer_name': 'Customer Name',
      'customer_name_hint': 'Enter customer name (optional)',
      'payment_method': 'Payment Method',
      'cash': 'CASH',
      'qris_bca': 'QRIS BCA',
      'card': 'Debit/Credit Card',
      'amount_paid_rp': 'Amount Received (Rp)',
      'quick_nominal': 'Quick Cash',
      'exact_amount': 'Exact Amount',
      'change_due_label': 'Change Due',
      'insufficient_amount': 'Amount received is less than total!',
      'process_payment': 'PROCESS PAYMENT',
      'finish_transaction_btn': 'COMPLETE TRANSACTION',
      'payment_success': 'Payment Successful!',

      // Receipt Dialog & Printer Service
      'receipt_title': 'Transaction Successful',
      'thermal_receipt': 'Payment Receipt',
      'print_receipt': 'Print Receipt',
      'print_copy': 'Print ({count} Copies)',
      'print_success': 'Receipt printed successfully!',
      'close': 'Close',
      'new_transaction': 'NEW TRANSACTION',
      'transaction_no': 'Transaction No.',
      'date': 'Date',
      'cashier': 'Cashier',
      'customer': 'Customer',
      'type': 'Type',
      'status_success': 'Status: SUCCESS',
      'receipt_copy_count': 'Receipt Copies:',
      'connect_printer_title': 'Connect Printer',
      'connect_printer_desc': 'Please open your phone Bluetooth settings to turn on Bluetooth & pair thermal printer.',
      'pair_on_phone': 'Pair on Phone',
      'printer_connect_failed': 'Failed to connect to Bluetooth Printer. Ensure Bluetooth is active & printer paired.',
      'sending_print_job': 'Sending print command ({copyText}) to Bluetooth Printer... (Receipt #{no})',

      // Products Screen
      'products_title': 'Product & Stock Management',
      'add_product': 'Add New Product',
      'search_product_sku_hint': 'Search Product / SKU...',
      'sku': 'SKU',
      'variant': 'Variant',
      'price': 'Price',
      'cost': 'Cost',
      'stock': 'Stock',
      'edit_product_tooltip': 'Edit Product Details & Photo',
      'delete_product_tooltip': 'Delete Product',
      'stock_adjustment_title': 'Stock Adjustment',
      'new_stock_qty': 'New Stock Quantity',
      'delete_product': 'Delete Product',
      'confirm_delete': 'Are you sure you want to delete "{name}"?',
      'product_name': 'Product Name',
      'product_category': 'Category',
      'product_price': 'Selling Price (Rp)',
      'product_cost': 'Cost Price (Rp)',
      'product_stock': 'Current Stock',
      'product_sku': 'Barcode / SKU Code',
      'product_image': 'Product Image URL',
      'save_product': 'SAVE PRODUCT',
      'save_changes': 'SAVE CHANGES',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'stock_low': 'Low Stock',
      'stock_available': 'Stock',
      'variant_desc': 'Variant / Description',
      'unit': 'Unit',
      'unit_desc': 'Unit (Portion/Glass)',
      'initial_stock': 'Initial Stock',
      'product_photo': 'Product Photo',
      'url_file_path': 'Photo URL / Device File Path',
      'photo_hint': 'https://... or /storage/emulated/0/...',
      'select_from_device': 'Select from Device',
      'photo_selected_snack': 'Photo selected from gallery/device',
      'change_photo_device': 'Change Product Photo from Device',
      'upload_gallery': 'Upload from Gallery / File',
      'photo_success_snack': 'Photo selected successfully from device!',
      'product_updated_snack': 'Product details for "{name}" updated successfully!',
      'barcode': 'Barcode',

      // Transactions Screen
      'transactions_title': 'Cashier Transaction History',
      'filter_by_date_all': 'Filter By Date: (All)',
      'filter_date_selected': 'Date: {date}',
      'reset_date_filter': 'Reset Date Filter',
      'total_tx_count_fmt': 'Total: {count} Transactions',
      'total_omzet_fmt': 'Revenue: {amount}',
      'search_transaction_hint': 'Search transaction by receipt no...',
      'all_payments': 'All Payments',
      'no_transactions': 'No transaction history recorded yet',
      'no_transactions_date': 'No transactions on {date}',
      'reprint_receipt': 'Reprint Receipt',

      // Reports Screen
      'reports_title': 'POS Reports & Analysis',
      'tab_shift_method': 'Shift & Payment Method Report',
      'tab_pnl': 'Income Statement Summary (P&L)',
      'filter_date_all_period': 'Date Filter: All Periods',
      'filter_date_fmt': 'Date Filter: {date}',
      'select_date': 'Select Date',
      'change_date': 'Change',
      'total_sales': 'Total Sales Revenue',
      'all_methods_subtitle': 'All payment methods',
      'total_tx_count': 'Total Transactions',
      'receipts_issued': 'Receipts issued',
      'total_cash_sales': 'Total Cash Transactions',
      'cash_tx_subtitle': '{count} Cash Transactions',
      'total_qris_sales': 'Total QRIS Transactions',
      'qris_tx_subtitle': '{count} Non-Cash Transactions',
      'total_dine_in': 'Total Dine-In',
      'dine_in_subtitle': '{count} Dine-In Orders',
      'total_takeaway': 'Total Takeaway',
      'takeaway_subtitle': '{count} Takeaway Orders',
      'shift_closing': 'Cashier Shift Closing',
      'shift_closing_desc': 'Recap of sales, QRIS, & cash for this shift',
      'close_shift': 'Close Shift',
      'shift_history_title': 'Shift Closing History',
      'no_shift_closings': 'No recorded shift closings yet',
      'omzet_label': 'Revenue',
      'cash_label': 'Cash',
      'qris_label': 'QRIS',
      'time_label': 'Time',
      'pnl_report_title': 'Income Statement Report',
      'pnl_subtitle': '(Income Statement / P&L)',
      'pnl_sec1': '1. OPERATING REVENUE',
      'pnl_gross_sales': 'Gross POS Cashier Sales',
      'pnl_discounts': 'Order Discounts',
      'pnl_net_revenue': 'NET REVENUE',
      'pnl_sec2': '2. COST OF GOODS SOLD (COGS)',
      'pnl_raw_materials': 'Raw Material Cost ({percent}%)',
      'pnl_gross_profit': 'GROSS PROFIT',
      'pnl_sec3': '3. OPERATING EXPENSES (OPEX)',
      'pnl_petty_cash': 'Petty Cash Outflow',
      'pnl_opex_est': 'Estimated Salary & Operating Expenses',
      'pnl_total_opex': 'TOTAL OPERATING EXPENSES',
      'pnl_net_profit': 'RESTO NET PROFIT / (LOSS)\n(NET PROFIT)',
      'pnl_settings_title': 'P&L Parameter Settings',
      'cogs_percent_label': 'Estimated COGS Percentage (%)',
      'cogs_percent_hint': 'e.g. 45',
      'opex_est_label': 'Estimated OPEX Expenses (Rp)',
      'opex_est_hint': 'e.g. 100000',
      'shift_close_confirm_title': 'Confirm Cashier Shift Closing',
      'active_cashier_label': 'Active Cashier',
      'shift_notes_label': 'Shift Closing Notes (Optional)',
      'process_shift_close': 'PROCESS SHIFT CLOSING',
      'shift_closed_snack': 'Shift {no} closed successfully!',

      // Settings Screen
      'settings_title': 'POS System Settings',
      'language_settings': 'Language Settings',
      'language_desc': 'Select application display language.',
      'indonesian': 'Indonesian 🇮🇩',
      'english': 'English 🇬🇧',
      'receipt_settings': 'Cashier Receipt Settings',
      'receipt_settings_desc': 'Configure header, default cashier name, and footer printed on receipts.',
      'receipt_header': 'Receipt Header (Store Name & Address)',
      'receipt_header_hint': 'Example:\nBIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTel: 0812-3456-7890',
      'cashier_default_name': 'Default Cashier Name',
      'receipt_footer': 'Receipt Footer (Thank You Message)',
      'receipt_footer_hint': 'Example:\n--- Thank You for Your Visit ---',
      'save_receipt_settings': 'SAVE RECEIPT SETTINGS',
      'settings_saved': 'Settings saved successfully!',
      'app_version': 'App Version',
    }
  };
}p Version',
    }
  };
}
