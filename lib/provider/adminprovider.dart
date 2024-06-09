import 'package:flutter_admin/dto/AdminDTO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/service/adminservice.dart';
import 'package:flutter_admin/secure_storage/secure_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminDTO? _admin;
  AdminDTO? get admin => _admin;
  final SecureService _secureService = SecureService();
  final AdminService _adminService = AdminService();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initializeAdmin() async {
    try {
      String? refreshToken = await _secureService.readToken("refreshToken");
      if (refreshToken != null) {
        AdminDTO admin = await _adminService.getAdminInfo(refreshToken);
        _admin = admin;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to initialize admin: $e');
    }
  }

  void updateLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  void updateAdmin(AdminDTO newUser) {
    _admin = newUser;
    notifyListeners();
  }

  void clearAdmin() {
    _admin = null;
    notifyListeners();
  }
}