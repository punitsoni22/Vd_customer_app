import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = true;
  String? token;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    isLoading = true;
    notifyListeners();

    token = await Prefs.getToken(); // get token from SharedPreferences

    isLoading = false;
    notifyListeners();
  }

  Future<void> clearToken() async {
    await Prefs.clearToken();
    token = null;
    notifyListeners();
  }
}
