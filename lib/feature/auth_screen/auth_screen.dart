import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Navigate after checking token
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (auth.token != null) {
                context.goNamed(AppRoutes.bottomBarScreen);
              } else {
                context.goNamed(AppRoutes.signupScreen);
              }
            });

            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
