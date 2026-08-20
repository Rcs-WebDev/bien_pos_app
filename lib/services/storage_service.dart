import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/cash_flow.dart';
import '../models/shift_closing.dart';

class StorageService {
  static const String keyProducts = 'bien_pos_products';
  static const String keyTransactions = 'bien_pos_transactions';
  static const String keyCashFlow = 'bien_pos_cashflow';
  static const String keyShiftClosings = 'bien_pos_shift_closings';
  static const String keyAuth = 'bien_pos_auth';
  static const String keyCommission = 'bien_pos_commission_rate';
  static const String keyReceiptHeader = 'bien_pos_receipt_header';
  static const String keyReceiptCashier = 'bien_pos_receipt_cashier';
  static const String keyReceiptFooter = 'bien_pos_receipt_footer';
  static const String keyLanguage = 'bien_pos_language';

  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, langCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'en';
  }

  static Future<void> saveCashierName(String cashierName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyReceiptCashier, cashierName);
  }

  static Future<void> saveReceiptSettings({
    required String header,
    required String cashierName,
    required String footer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyReceiptHeader, header);
    await prefs.setString(keyReceiptCashier, cashierName);
    await prefs.setString(keyReceiptFooter, footer);
  }

  static Future<Map<String, String>> getReceiptSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final header = prefs.getString(keyReceiptHeader) ??
        'BIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890';
    final cashierName = prefs.getString(keyReceiptCashier) ?? 'bien';
    final footer = prefs.getString(keyReceiptFooter) ??
        '--- Terima Kasih atas Kunjungan Anda ---';
    return {
      'header': header,
      'cashierName': cashierName,
      'footer': footer,
    };
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(keyProducts, jsonEncode(jsonList));
  }

  static Future<List<Product>?> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyProducts);
    if (data == null) return null;
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveTransactions(
      List<PosTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(keyTransactions, jsonEncode(jsonList));
  }

  static Future<List<PosTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyTransactions);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((item) => PosTransaction.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCashFlow(List<CashFlow> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((c) => c.toJson()).toList();
    await prefs.setString(keyCashFlow, jsonEncode(jsonList));
  }

  static Future<List<CashFlow>> getCashFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyCashFlow);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((item) => CashFlow.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveShiftClosings(List<ShiftClosing> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((s) => s.toJson()).toList();
    await prefs.setString(keyShiftClosings, jsonEncode(jsonList));
  }

  static Future<List<ShiftClosing>> getShiftClosings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyShiftClosings);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((item) => ShiftClosing.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAuth(Map<String, dynamic>? userObj) async {
    final prefs = await SharedPreferences.getInstance();
    if (userObj == null) {
      await prefs.remove(keyAuth);
    } else {
      await prefs.setString(keyAuth, jsonEncode(userObj));
    }
  }

  static Future<Map<String, dynamic>?> getAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyAuth);
    if (data == null) return null;
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveCommissionRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyCommission, rate);
  }

  static Future<double> getCommissionRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyCommission) ?? 10.0;
  }
}
