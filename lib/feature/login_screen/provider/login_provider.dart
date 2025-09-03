import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  bool success = false;
  String? otp;
  String? _password;
  String? get password => _password;

  String? _email;
  String? get email => _email;

  String? _number;
  String? get number => _number;

  void emailchange(String value) {
    print("$value");
    _email = value;
  }

  passwordchange(String value) {
    print("$value");
    _password = value;
  }

  numberchange(String value) {
    print("$value");
    _number = value;
  }

  Future<void> loginViaEmail(BuildContext context) async {
    final data = {
      "data": {"userName": email, "password": password},
    };
    print("Login data → $data");
    isLoading = true;
    message = null;
    success = false;
    notifyListeners();

    try {
      final response = await Api.post('login', data);
      log("Login response: $response");

      if (response['success'] == true) {
        final token = response['data']['token'];
        await Prefs.saveToken(token);

        success = true;
        message = response['message'];

        context.goNamed(AppRoutes.homeScreen);
      } else {
        success = false;
        message = response['message'] ?? "Login failed";
      }
    } catch (e) {
      success = false;
      message = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  /// Login via OTP
  Future<void> loginViaOtp(BuildContext context) async {
    final data = {
      "data": {"userName": number},
    };
    print("OTP Login data → $data");

    isLoading = true;
    message = null;
    success = false;
    otp = null;
    notifyListeners();

    try {
      final response = await Api.post('login', data);
      log("OTP Login response: $response");
      final dataObj = response['data'];

      if (response['success'] == true) {
        success = true;

        message = dataObj?['message'] ?? "OTP sent successfully";
        otp = dataObj?['otp'];

        context.goNamed(AppRoutes.otpscreen);
      } else {
        success = false;
        message = "OTP request failed";
      }
    } catch (e) {
      success = false;
      message = "Exception: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    print("Verify OTP data → $data");
    isLoading = true;
    message = null;
    success = false;
    notifyListeners();

    try {
      final response = await Api.post('verifyOTP', data);
      log("Verify OTP response: $response");

      if (response['success'] == true) {
        success = true;
        message =
            response['dataResponse']?['description'] ??
            "OTP verified successfully";

        // Optionally: save token after verification
        // await Prefs.saveToken(response['data']?['token']);
        context.goNamed(AppRoutes.homeScreen);
      } else {
        success = false;
        message =
            response['dataResponse']?['description'] ??
            "OTP verification failed";
      }
    } catch (e) {
      success = false;
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
