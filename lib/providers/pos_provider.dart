import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction_model.dart';
import '../models/cash_flow.dart';
import '../models/shift_closing.dart';
import '../services/storage_service.dart';
import 'product_provider.dart';

class PosProvider with ChangeNotifier {
  final List<CartItem> _cart = [];
  String _orderType = 'DINE-IN (1 Pax)';
  String _orderNotes = '';
  double _discount = 0.0;
  double _shippingFee = 0.0;
  String _cashierName = 'bien';
  String _customerName = 'Pelanggan Umum';
  String _selectedPaymentMethod = 'CASH';
  double _tenderedAmount = 0.0;
  PosTransaction? _activeTransaction;

  List<PosTransaction> _transactionsHistory = [];
  List<CashFlow> _cashFlowHistory = [];
  List<ShiftClosing> _shiftClosingsHistory = [];

  List<CartItem> get cart => _cart;
  String get orderType => _orderType;
  String get orderNotes => _orderNotes;
  double get discount => _discount;
  double get shippingFee => _shippingFee;
  String get cashierName => _cashierName;
  String get customerName => _customerName;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  double get tenderedAmount => _tenderedAmount;
  PosTransaction? get activeTransaction => _activeTransaction;

  List<PosTransaction> get transactionsHistory => _transactionsHistory;
  List<CashFlow> get cashFlowHistory => _cashFlowHistory;
  List<ShiftClosing> get shiftClosingsHistory => _shiftClosingsHistory;

  int get totalItemsCount => _cart.fold(0, (sum, item) => sum + item.qty);
  double get subtotalAmount => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalAmount {
    final afterDiscount = (subtotalAmount - _discount).clamp(0.0, double.infinity);
    return afterDiscount + _shippingFee;
  }
  double get changeAmount => (_tenderedAmount - totalAmount).clamp(0.0, double.infinity);

  PosProvider() {
    initData();
  }

  Future<void> initData() async {
    _transactionsHistory = await StorageService.getTransactions();
    _cashFlowHistory = await StorageService.getCashFlow();
    _shiftClosingsHistory = await StorageService.getShiftClosings();

    final receiptSettings = await StorageService.getReceiptSettings();
    if (receiptSettings['cashierName'] != null && receiptSettings['cashierName']!.isNotEmpty) {
      _cashierName = receiptSettings['cashierName']!;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_transactionsHistory.isEmpty) {
      _transactionsHistory = [
        PosTransaction(
          id: 1,
          transactionNo: '8FC126081500000001',
          cashierName: 'bien',
          orderType: 'DINE-IN (1 Pax)',
          totalItems: 3,
          subtotal: 39000,
          discount: 0,
          shippingFee: 0,
          tax: 0,
          totalAmount: 39000,
          paymentMethod: 'CASH',
          tenderedAmount: 50000,
          changeAmount: 11000,
          status: 'SUKSES',
          createdAt: '$today 14:20:11',
          dateStr: today,
          items: [
            {'id': 1, 'name': 'Baso Aci', 'sell_price': 13000, 'qty': 3}
          ],
        ),
        PosTransaction(
          id: 2,
          transactionNo: '8FC126081500000002',
          cashierName: 'Siti Rahma',
          orderType: 'TAKEAWAY',
          totalItems: 2,
          subtotal: 43000,
          discount: 0,
          shippingFee: 0,
          tax: 0,
          totalAmount: 43000,
          paymentMethod: 'QRIS_BCA',
          tenderedAmount: 43000,
          changeAmount: 0,
          status: 'SUKSES',
          createdAt: '$today 16:45:00',
          dateStr: today,
          items: [
            {'id': 2, 'name': 'Ayam Goreng Sambal Ijo', 'sell_price': 25000, 'qty': 1},
            {'id': 4, 'name': 'Kopi Susu Gula Aren', 'sell_price': 18000, 'qty': 1}
          ],
        )
      ];
      await StorageService.saveTransactions(_transactionsHistory);
    }

    if (_cashFlowHistory.isEmpty) {
      _cashFlowHistory = [
        CashFlow(
          id: 1,
          date: '$today 09:00',
          type: 'Kas Masuk',
          amount: 500000,
          cashier: 'bien',
          notes: 'Modal awal laci kasir (Float balance)',
        ),
        CashFlow(
          id: 2,
          date: '$today 18:00',
          type: 'Kas Keluar',
          amount: 50000,
          cashier: 'bien',
          notes: 'Beli galon air minum resto',
        )
      ];
      await StorageService.saveCashFlow(_cashFlowHistory);
    }

    notifyListeners();
  }

  void setCashierName(String name) {
    _cashierName = name;
    StorageService.saveCashierName(name);
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name.isEmpty ? 'Pelanggan Umum' : name;
    notifyListeners();
  }

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cart[index].qty += 1;
    } else {
      _cart.add(CartItem(product: product, qty: 1));
    }
    notifyListeners();
  }

  void updateQty(int productId, int delta) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cart[index].qty += delta;
      if (_cart[index].qty <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _discount = 0.0;
    _shippingFee = 0.0;
    _orderNotes = '';
    _customerName = 'Pelanggan Umum';
    notifyListeners();
  }

  void setOrderType(String type) {
    _orderType = type;
    notifyListeners();
  }

  void setDiscount(double amount) {
    _discount = amount;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setTenderedAmount(double amount) {
    _tenderedAmount = amount;
    notifyListeners();
  }

  Future<PosTransaction?> submitPayment(ProductProvider productProvider) async {
    if (_cart.isEmpty) return null;

    final now = DateTime.now();
    final dateStr = DateFormat('yyMMdd').format(now);
    final fullDateStr = DateFormat('yyyy-MM-dd').format(now);
    final randomId = Random().nextInt(900000000) + 100000000;
    final txNo = '8FC$dateStr$randomId';

    final cartItemsMap = _cart.map((item) => {
      'id': item.product.id,
      'name': item.product.name,
      'sell_price': item.product.sellPrice,
      'qty': item.qty,
    }).toList();

    final txData = PosTransaction(
      id: DateTime.now().millisecondsSinceEpoch,
      transactionNo: txNo,
      cashierName: _cashierName,
      customerName: _customerName,
      orderType: _orderType,
      totalItems: totalItemsCount,
      subtotal: subtotalAmount,
      discount: _discount,
      shippingFee: _shippingFee,
      tax: 0,
      totalAmount: totalAmount,
      paymentMethod: _selectedPaymentMethod,
      tenderedAmount: _tenderedAmount,
      changeAmount: changeAmount,
      status: 'SUKSES',
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      dateStr: fullDateStr,
      items: cartItemsMap,
    );

    _transactionsHistory.insert(0, txData);
    await StorageService.saveTransactions(_transactionsHistory);

    // Deduct Stock
    await productProvider.deductStock(cartItemsMap);

    _activeTransaction = txData;
    clearCart();
    notifyListeners();
    return txData;
  }

  Future<void> addCashFlowEntry(String type, double amount, String notes) async {
    final now = DateTime.now();
    final entry = CashFlow(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateFormat('yyyy-MM-dd HH:mm').format(now),
      type: type,
      amount: amount,
      cashier: _cashierName,
      notes: notes,
    );

    _cashFlowHistory.insert(0, entry);
    await StorageService.saveCashFlow(_cashFlowHistory);
    notifyListeners();
  }

  Future<ShiftClosing> closeShift(String notes, double commissionRate) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final shiftNo = 'SHIFT-${DateFormat('yyyyMMdd').format(now)}-${Random().nextInt(900) + 100}';

    final shiftTx = _transactionsHistory.where((tx) =>
      tx.cashierName == _cashierName && tx.dateStr == todayStr
    ).toList();

    final totalSales = shiftTx.fold(0.0, (sum, tx) => sum + tx.totalAmount);
    final cashSales = shiftTx.where((tx) => tx.paymentMethod == 'CASH').fold(0.0, (sum, tx) => sum + tx.totalAmount);
    final qrisSales = shiftTx.where((tx) => tx.paymentMethod.contains('QRIS')).fold(0.0, (sum, tx) => sum + tx.totalAmount);
    final transferSales = shiftTx.where((tx) => tx.paymentMethod == 'TRANSFER').fold(0.0, (sum, tx) => sum + tx.totalAmount);
    final voidCount = shiftTx.where((tx) => tx.status == 'VOID').length;
    final voidTotal = shiftTx.where((tx) => tx.status == 'VOID').fold(0.0, (sum, tx) => sum + tx.totalAmount);

    final commissionEarned = totalSales * (commissionRate / 100);

    final closing = ShiftClosing(
      id: DateTime.now().millisecondsSinceEpoch,
      shiftNo: shiftNo,
      employeeName: _cashierName,
      startTime: '$todayStr 08:00:00',
      endTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      totalSales: totalSales,
      cashSales: cashSales,
      qrisSales: qrisSales,
      transferSales: transferSales,
      voidCount: voidCount,
      voidTotal: voidTotal,
      commissionEarned: commissionEarned,
      notes: notes.isNotEmpty ? notes : 'Penutupan Shift Reguler',
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
    );

    _shiftClosingsHistory.insert(0, closing);
    await StorageService.saveShiftClosings(_shiftClosingsHistory);
    notifyListeners();
    return closing;
  }
}
