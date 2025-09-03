import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/feature/auth_screen/auth_screen.dart';
import 'package:vd_customer_app/feature/login_screen/login_screen.dart';
import 'package:vd_customer_app/feature/login_screen/verify_otp_screen.dart';
import 'package:vd_customer_app/feature/signup_screen/signup_screen.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/home_screen/home_page.dart';
import 'package:vd_customer_app/feature/product_list_screen/products_screen.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/region_screen/region_screen.dart';
import 'package:vd_customer_app/feature/subscription_screen/subscription_screen.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'authScreen',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: AppRoutes.otpscreen,
        builder: (context, state) => VerifyOtpScreen(),
      ),
      GoRoute(
        name: AppRoutes.loginsscreen,
        path: '/login',
        builder: (context, state) => LoginOtpScreen(),
      ),
      GoRoute(
        name: AppRoutes.registerscreen,
        path: '/register',
        builder: (context, state) => SignupScreen(),
      ),
      GoRoute(
        name: AppRoutes.regionscreen,
        path: '/region',
        builder: (context, state) => RegionScreen(),
      ),
      GoRoute(
        name: AppRoutes.homeScreen,
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => CommonBottomAppbar(),
        routes: [
          // GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
          GoRoute(
            path: "/products",
            builder: (context, state) => ProductScreen(),
          ),
          GoRoute(
            path: "/subscription",
            builder: (context, state) => SubscriptionScreen(),
          ),
          GoRoute(path: "/cart", builder: (context, state) => CartScreen()),
          GoRoute(
            path: "/profile",
            builder: (context, state) => ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
