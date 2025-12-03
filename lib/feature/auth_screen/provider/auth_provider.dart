import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = true;
  String? token;

  AuthProvider() {
    checkAuth();
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> checkAuth() async {
    isLoading = true;
    notifyListeners();

    token = await Prefs.getString(Prefs.keyAuthToken);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setToken(String newToken) async {
    await Prefs.saveString(Prefs.keyAuthToken, newToken);
    token = newToken;
    notifyListeners();
  }

  Future<void> clearToken() async {
    await Prefs.clear(Prefs.keyAuthToken);
    await Prefs.clear(Prefs.keyUserId);
    token = null;
    notifyListeners();
  }
}
