import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/routes/routes.dart';
import 'package:vd_customer_app/screens/Cart/view/cart_screen.dart';
import 'package:vd_customer_app/screens/Home/view/home_page.dart';
import 'package:vd_customer_app/screens/Product%20Listing/view/products_page.dart';
import 'package:vd_customer_app/screens/Profile/view/profile_page.dart';
import 'package:vd_customer_app/screens/Region%20Screen/view/region_screen.dart';
import 'package:vd_customer_app/screens/Subscription/view/subscription_screen.dart';
import 'package:vd_customer_app/screens/auth/view/login_screen.dart';
import 'package:vd_customer_app/screens/auth/view/otp_screen.dart';
import 'package:vd_customer_app/widgets/tab_bar.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    initialLocation: '/otp',
    routes: [
      GoRoute(
        name: AppRoutes.otpscreen,
        path: '/otp',
        builder: (context, state) => OtpScreen(),
      ),
      GoRoute(
        name: AppRoutes.loginscreen,
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.regionscreen,
        path: '/region',
        builder: (context, state) => RegionScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => CommonBottomAppbar(child: child),
        routes: [
          GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
          GoRoute(
            path: "/products",
            builder: (context, state) => ProductsPage(),
          ),
          GoRoute(
            path: "/subscription",
            builder: (context, state) => SubscriptionScreen(),
          ),
          GoRoute(path: "/cart", builder: (context, state) => CartScreen()),
          GoRoute(path: "/profile", builder: (context, state) => ProfilePage()),
        ],
      ),
    ],
  );
}
