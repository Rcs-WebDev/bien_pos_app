import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  double _commissionRate = 10.0;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  double get commissionRate => _commissionRate;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isManager => _user?['role'] == 'Manager';
  bool get isStaff => _user?['role'] == 'Staff';
  String get currentRole => _user?['role'] ?? 'Guest';
  String get currentUserName => _user?['name'] ?? 'Kasir';

  AuthProvider() {
    loadAuth();
  }

  Future<void> loadAuth() async {
    _user = await StorageService.getAuth();
    _commissionRate = await StorageService.getCommissionRate();
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String role, String password) async {
    Map<String, dynamic>? userObj;
    if (role == 'Manager') {
      if (password != 'manager123') {
        return {'success': false, 'message': 'Password Manager salah!'};
      }
      userObj = {
        'username': 'manager',
        'name': 'Manager POS',
        'role': 'Manager',
      };
    } else if (role == 'Staff') {
      if (password != 'staff123') {
        return {'success': false, 'message': 'Password Staff salah!'};
      }
      userObj = {
        'username': 'staff',
        'name': 'Staff Kasir',
        'role': 'Staff',
      };
    } else {
      return {'success': false, 'message': 'Peran tidak valid.'};
    }

    _user = userObj;
    await StorageService.saveAuth(userObj);
    notifyListeners();
    return {'success': true, 'user': userObj};
  }

  Future<void> logout() async {
    _user = null;
    await StorageService.saveAuth(null);
    notifyListeners();
  }

  Future<bool> setCommissionRate(double newRate) async {
    if (!isManager) return false;
    _commissionRate = newRate;
    await StorageService.saveCommissionRate(newRate);
    notifyListeners();
    return true;
  }
}
