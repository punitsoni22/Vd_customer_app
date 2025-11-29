import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  bool get isLoading => _isLoading;

  String? get message => _message;

  bool get success => _success;

  String? _email;
  String? _password;
  String? _number;

  String? get email => _email;

  String? get password => _password;

  String? get number => _number;

  void setEmail(String v) {
    print("jugug $v");
    _email = v.trim();
    notifyListeners();
  }

  void setPassword(String v) => _password = v;

  void setNumber(String v) => _number = v.trim();

  void _setLoading(bool v) {
    if (_isLoading != v) {
      _isLoading = v;
      notifyListeners();
    }
  }

  void _result({required bool success, String? message}) {
    _success = success;
    _message = message;
    notifyListeners();
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }
    final payload = base64Url.normalize(parts[1]);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid JWT payload');
    }
    return payloadMap;
  }

  Future<void> loginViaEmail(BuildContext context) async {
    final payload = {
      "data": {
        "userName": _email,
        "password": _password,
        "roleUniqueIds": ["CUSTOMER"],
      },
    };
    print('$payload');
    _setLoading(true);
    _result(success: false, message: null);
    try {
      final res = await Api.post('login', payload);
      log("Login (email) → $res");

      final ok = res['success'] == true;
      if (ok) {
        final token = res['data']?['token']?.toString();
        if (token != null) {
          await Prefs.saveString(Prefs.keyAuthToken, token);
          try {
            final payload = _decodeJwt(token);
            final userId = payload['id'];
            if (userId != null) {
              await Prefs.saveString("user_id", userId.toString());
              context.read<CartProvider>().fetchLatestCart(context);
            }
          } catch (e) {
            print("DEBUG: Failed to decode token: $e");
          }
        }

        if (!context.mounted) return;
        _result(success: true, message: res['message']?.toString());
        context.goNamed(AppRoutes.bottomBarScreen);
      } else {
        _result(
          success: false,
          message: res['message']?.toString() ?? "Login failed",
        );
      }
    } catch (e, st) {
      log('LoginViaEmail error', error: e, stackTrace: st);
      _result(
        success: false,
        message: "Something went wrong. Please try again.",
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginViaOtp(BuildContext context) async {
    final payload = {
      "data": {
        "userName": _number,
        'roleUniqueIds': ["CUSTOMER"],
      },
    };
    _setLoading(true);
    _result(success: false, message: null);
    try {
      final res = await Api.post('login', payload);
      log("Login (OTP request) → $res");

      final ok = res['success'] == true;
      if (ok) {
        if (!context.mounted) return;
        _result(
          success: true,
          message:
              res['data']?['message']?.toString() ?? "OTP sent successfully",
        );
      } else {
        _result(success: false, message: "OTP request failed");
      }
    } catch (e, st) {
      log('LoginViaOtp error', error: e, stackTrace: st);
      _result(
        success: false,
        message: "Something went wrong. Please try again.",
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(BuildContext context, String otp) async {
    final payload = {
      "data": {"userName": _number, "otp": int.tryParse(otp.trim()) ?? 0},
    };
    _setLoading(true);
    _result(success: false, message: null);
    try {
      final res = await Api.post('verifyOTP', payload);
      log("Verify OTP → $res");

      final ok = res['success'] == true;
      if (ok) {
        if (!context.mounted) return;

        final userId = res['dataResponse']?['userId']?.toString();
        if (userId != null) {
          await Prefs.saveString("user_id", userId);
          context.read<CartProvider>().fetchLatestCart(context);
        }

        _result(
          success: true,
          message:
              res['dataResponse']?['description']?.toString() ??
              "OTP verified successfully",
        );
        context.goNamed(AppRoutes.homeScreen);
      } else {
        _result(
          success: false,
          message:
              res['dataResponse']?['description']?.toString() ??
              "OTP verification failed",
        );
      }
    } catch (e, st) {
      log('VerifyOtp error', error: e, stackTrace: st);
      _result(
        success: false,
        message: "Something went wrong. Please try again.",
      );
    } finally {
      _setLoading(false);
    }
  }

  void clearMessage() {
    _message = null;
    notifyListeners();
  }
}
