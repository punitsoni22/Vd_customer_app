import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth_screen/auth_screen.dart';
import '../../feature/home_screen/home_screen.dart';
import '../../feature/login_screen/login_screen.dart';
import '../../feature/navigation_bottom_bar/bottom_bar_screen.dart';
import '../../feature/product_detail_screen/product_detail_screen.dart';
import '../../feature/product_screen/products_screen.dart';
import '../../feature/signup_screen/signup_screen.dart';
import 'routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.authScreen,
    routes: [
      GoRoute(
        path: '/auth_screen',
        name: AppRoutes.authScreen,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/login_screen',
        name: AppRoutes.loginScreen,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signup_screen',
        name: AppRoutes.signupScreen,
        builder: (context, state) => SignupScreen(),
      ),
      GoRoute(
        path: '/bottom_bar_screen',
        name: AppRoutes.bottomBarScreen,
        builder: (context, state) => BottomBarScreen(),
      ),
      GoRoute(
        path: '/home_screen',
        name: AppRoutes.homeScreen,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: "/product_screen",
        name: AppRoutes.productScreen,
        builder: (context, state) => ProductScreen(),
      ),
      GoRoute(
        path: '/product_detail_screen/:id',
        name: AppRoutes.productDetailScreen,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailScreen(productId: id);
        },
      ),
    ],
  );
}
