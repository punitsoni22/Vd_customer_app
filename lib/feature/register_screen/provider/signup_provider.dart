import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:vd_customer_app/core/services/api_services.dart';

class SignupProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;

  Future<void> signup(Map<String, dynamic> data) async {
    print("Mydata → $data");
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('register', data);
      log("this is response: $response");

      if (response['success'] == true) {
        message = response['message'];
      } else {
        message = response['message'] ?? "Signup failed";
      }
    } catch (e) {
      message = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
    notifyListeners();
  }
}
