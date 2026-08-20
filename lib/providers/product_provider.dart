import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  dynamic _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<Category> _categories = [
    Category(id: 'all', name: 'Semua Kategori', label: 'Semua'),
    Category(id: 1, name: 'Makanan', label: 'Makanan'),
    Category(id: 2, name: 'Minuman', label: 'Minuman'),
    Category(id: 3, name: 'Cemilan', label: 'Cemilan'),
    Category(id: 4, name: 'Paket Hemat', label: 'Paket Hemat'),
  ];

  final List<Product> _defaultMockProducts = [
    Product(
      id: 1,
      categoryId: 1,
      name: 'Baso Aci',
      variant: 'Spesial Kuah Pedas',
      sku: 'MAKAN-001',
      barcode: '8991001001',
      stockQty: 150,
      unit: 'Porsi',
      costPrice: 8000,
      sellPrice: 13000,
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=400&q=80',
    ),
    Product(
      id: 2,
      categoryId: 1,
      name: 'Ayam Goreng Sambal Ijo',
      variant: 'Dada / Paha',
      sku: 'MAKAN-002',
      barcode: '8991001002',
      stockQty: 85,
      unit: 'Porsi',
      costPrice: 15000,
      sellPrice: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=400&q=80',
    ),
    Product(
      id: 3,
      categoryId: 1,
      name: 'Nasi Goreng Spesial',
      variant: 'Komplit Telur + Sosis',
      sku: 'MAKAN-003',
      barcode: '8991001003',
      stockQty: 120,
      unit: 'Porsi',
      costPrice: 12000,
      sellPrice: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=400&q=80',
    ),
    Product(
      id: 4,
      categoryId: 2,
      name: 'Kopi Susu Gula Aren',
      variant: 'Less Ice',
      sku: 'MINUM-001',
      barcode: '8991002001',
      stockQty: 200,
      unit: 'Gelas',
      costPrice: 8000,
      sellPrice: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=400&q=80',
    ),
    Product(
      id: 5,
      categoryId: 2,
      name: 'Es Teh Manis',
      variant: 'Dingin',
      sku: 'MINUM-002',
      barcode: '8991002002',
      stockQty: 300,
      unit: 'Gelas',
      costPrice: 1500,
      sellPrice: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=400&q=80',
    ),
    Product(
      id: 6,
      categoryId: 3,
      name: 'Roti Bakar Coklat Keju',
      variant: 'Porsi Besar',
      sku: 'CEMIL-001',
      barcode: '8991003001',
      stockQty: 95,
      unit: 'Porsi',
      costPrice: 10000,
      sellPrice: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bff?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  dynamic get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'all' || product.categoryId == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.barcode.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  ProductProvider() {
    initProducts();
  }

  Future<void> initProducts() async {
    final saved = await StorageService.getProducts();
    if (saved != null && saved.isNotEmpty) {
      _products = saved;
    } else {
      _products = List.from(_defaultMockProducts);
      await StorageService.saveProducts(_products);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(dynamic categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct(Product newProduct) async {
    _products.add(newProduct);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct(int id, Product updated) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updated;
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> adjustStock(int id, int newQty) async {
    final product = _products.firstWhere((p) => p.id == id, orElse: () => _products.first);
    product.stockQty = newQty < 0 ? 0 : newQty;
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> deductStock(List<Map<String, dynamic>> cartItems) async {
    for (var item in cartItems) {
      final int prodId = item['id'];
      final int qty = item['qty'] ?? 1;
      final idx = _products.indexWhere((p) => p.id == prodId);
      if (idx != -1) {
        _products[idx].stockQty = (_products[idx].stockQty - qty).clamp(0, 999999);
      }
    }
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> moveUp(int id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index > 0) {
      final item = _products.removeAt(index);
      _products.insert(index - 1, item);
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> moveDown(int id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0 && index < _products.length - 1) {
      final item = _products.removeAt(index);
      _products.insert(index + 1, item);
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> reorderProduct(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _products.removeAt(oldIndex);
    _products.insert(newIndex, item);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }
}
