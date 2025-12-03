import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class AuthHelper {
  static bool requireLogin(BuildContext context, {String? message}) {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      MySnackBar.showSnackBar(context, message ?? 'Please login to continue');

      Future.microtask(() {
        if (context.mounted) {
          context.pushNamed(AppRoutes.loginScreen);
        }
      });

      return false;
    }

    return true;
  }
}
