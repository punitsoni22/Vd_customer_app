import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/services/api_services.dart';
import '../../../core/utils/prefs/prefs.dart';

class SignupProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobileNumber,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final payload = {
        "data": {
          "emailId": email.trim(),
          "password": password.trim(),
          "fullName": fullName.trim(),
          "mobileNumber": mobileNumber.trim(),
        },
      };
      log("Signup payload → $payload");

      final response = await Api.post('register', payload);
      log("Signup response → $response");

      final success = response['success'] == true;
      final msg =
          (response['message'] ??
                  (success ? 'Signup successful' : 'Signup failed'))
              .toString();
      final data = response['data'];
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        final token = data['token'];
        await Prefs.saveString(Prefs.keyAuthToken, token);
        context.goNamed(AppRoutes.bottomBarScreen);
      } else {
        _showError(context, msg);
      }
    } catch (e, st) {
      log('Signup exception', error: e, stackTrace: st);
      if (context.mounted) {
        _showError(context, 'Something went wrong. Please try again.');
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    if (_isLoading != v) {
      _isLoading = v;
      notifyListeners();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
