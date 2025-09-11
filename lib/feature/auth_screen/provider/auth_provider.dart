import 'dart:developer';

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

    token = await Prefs.getString(Prefs.keyAuthToken);
    log('Auth Token: $token');

    isLoading = false;
    notifyListeners();
  }

  Future<void> clearToken() async {
    await Prefs.clear(Prefs.keyAuthToken);
    token = null;
    notifyListeners();
  }
}
