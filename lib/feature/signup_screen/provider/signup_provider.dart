import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vd_customer_app/core/services/api_services.dart';

import '../../../core/routing/routes.dart';

class SignupProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;

  Future<void> signup(Map<String, dynamic> data, BuildContext context) async {
    print("Mydata → $data");
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('register', data);
      log("this is response: $response");

      if (response['success'] == true) {
        log("justtest");
        message = response['message'];
        context.goNamed(AppRoutes.loginsscreen);
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
