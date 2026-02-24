import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/feature/about_us/about_us_screen.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/checkout_screen/checkout_screen.dart';
import 'package:vd_customer_app/feature/my_order_screen/my_order_screen.dart';
import 'package:vd_customer_app/feature/order_detail_screen.dart/order_detail_screen.dart';
import 'package:vd_customer_app/feature/product_detail_screen/product_detail_screen.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/subscription_date_screen.dart';
import 'package:vd_customer_app/feature/subscription_plan_details/plan_details_screen.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/subscription_product_screen.dart';

import '../../feature/auth_screen/auth_screen.dart';
import '../../feature/home_screen/home_screen.dart';
import '../../feature/login_screen/login_screen.dart';
import '../../feature/navigation_bottom_bar/bottom_bar_screen.dart';
import '../../feature/product_screen/products_screen.dart';
import '../../feature/spalsh_screen/splash_screen.dart';
import '../../feature/signup_screen/signup_screen.dart';
import 'routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        path: '/splash_screen',
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth_screen',
        name: AppRoutes.authScreen,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/login_screen',
        name: AppRoutes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup_screen',
        name: AppRoutes.signupScreen,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/about_us_screen',
        name: AppRoutes.aboutUsScreen,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/bottom_bar_screen',
        name: AppRoutes.bottomBarScreen,
        builder: (context, state) {
          final extra = state.extra;
          int initialIndex = 0;
          if (extra is Map<String, dynamic>) {
            final idx = extra['index'];
            if (idx is int) {
              initialIndex = idx;
            } else if (idx is String) {
              initialIndex = int.tryParse(idx) ?? 0;
            }
          }
          return BottomBarScreen(
            key: UniqueKey(),
            initialIndex: initialIndex,
          );
        },
      ),
      GoRoute(
        path: '/home_screen',
        name: AppRoutes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: "/product_screen",
        name: AppRoutes.productScreen,
        builder: (context, state) => const ProductScreen(),
      ),
      GoRoute(
        path: '/product_detail_screen',
        name: AppRoutes.productDetailScreen,
        builder: (context, state) => const ProductDetailScreen(),
      ),
      GoRoute(
        path: '/cart_screen',
        name: AppRoutes.cartScreen,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout_screen',
        name: AppRoutes.checkoutScreen,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/subscription_product_screen',
        name: AppRoutes.subscriptionProductScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final preSelectedProducts =
              extra?['preSelectedProducts'] as List<Map<String, dynamic>>?;
          return SubscriptionProductScreen(
            preSelectedProducts: preSelectedProducts,
          );
        },
      ),
      GoRoute(
        path: '/subscription_date_screen',
        name: AppRoutes.subscriptionDateScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final selectedProducts =
              extra?['selectedProducts'] as List<Map<String, dynamic>>?;
          return SubscriptionDateScreen(selectedProducts: selectedProducts);
        },
      ),
      GoRoute(
        path: '/plan_details_screen',
        name: AppRoutes.planDetailsScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final planId = extra?['planId'] as int?;
          return PlanDetailsScreen(planId: planId ?? 0);
        },
      ),
      GoRoute(
        path: '/my_order_screen',
        name: AppRoutes.myOrderScreen,
        builder: (context, state) => const MyOrderScreen(),
      ),
      GoRoute(
        path: '/order_detail_screen',
        name: AppRoutes.orderDetailScreen,
        builder: (context, state) =>
            const OrderDetailScreen(imageUrl: 'assets/images/image.png'),
      ),
      GoRoute(
        path: '/profile_screen',
        name: AppRoutes.profileScreen,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: 'homescreen2',
        name: AppRoutes.homescreen2,
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
  );
}
