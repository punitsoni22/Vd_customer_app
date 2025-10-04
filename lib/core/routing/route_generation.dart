import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_subscription_container.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/checkout_screen/checkout_screen.dart';
import 'package:vd_customer_app/feature/product_detail_screen/product_detail_screen.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/subscription_date_screen.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/subscription_product_screen.dart';
import '../../feature/auth_screen/auth_screen.dart';
import '../../feature/home_screen/home_screen.dart';
import '../../feature/login_screen/login_screen.dart';
import '../../feature/navigation_bottom_bar/bottom_bar_screen.dart';
import '../../feature/product_screen/products_screen.dart';
import '../../feature/signup_screen/signup_screen.dart';
import 'routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.loginScreen,
    routes: [
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
        path: '/bottom_bar_screen',
        name: AppRoutes.bottomBarScreen,
        builder: (context, state) => const BottomBarScreen(),
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
        builder: (context, state) => const SubscriptionProductScreen(),
      ),
      GoRoute(
        path: '/subscription_date_screen',
        name: AppRoutes.subscriptionDateScreen,
        builder: (context, state) => const SubscriptionDateScreen(),
      ),
    ],
  );
}
