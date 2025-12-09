import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/product_screen/provider/product_provider.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/subscription_product_screen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import '../home_screen/home_screen.dart';
import '../product_screen/products_screen.dart';
import 'navigation_bottom_bar.dart';

class BottomBarScreen extends StatefulWidget {
  final int initialIndex;
  const BottomBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _index = 0;
  late final List<Widget?> _pages = List<Widget?>.filled(5, null);

  Widget _buildLoginRequiredView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 24.h),
            Text(
              'Login to Access Your Cart',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Sign in to view your cart items and checkout',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            CommonButton(
              buttonValue: 'Login',
              onTap: () {
                context.pushNamed(AppRoutes.loginScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int idx, bool isLoggedIn) {
    switch (idx) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ProductScreen();
      case 2:
        return const SubscriptionProductScreen();
      case 3:
        return isLoggedIn ? const CartScreen() : _buildLoginRequiredView(context);
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    // trigger provider fetch for the initial page centrally here so child
    // screens don't need to run network calls in their initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

      _pages[_index] = _buildPage(_index, isLoggedIn);
      setState(() {});

      if (_index == 3 && isLoggedIn) {
        context.read<CartProvider>().fetchLatestCart(context);
      } else if (_index == 1) {
        context.read<ProductProvider>().getProducts({
          "filterModel": {},
          "orderBy": "productName",
          "orderDir": "ASC",
          "searchText": "",
          "page": 1,
          "pageSize": 10,
        });
      }
    });
  }

  bool? _lastLoggedInState;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    if (_lastLoggedInState != null && _lastLoggedInState != isLoggedIn) {
      // Login state changed, invalidate pages that depend on it
      _pages[3] = null; // Cart
      
      // If we are currently on the cart page, rebuild it immediately
      if (_index == 3) {
        _pages[3] = _buildPage(3, isLoggedIn);
        if (isLoggedIn) {
          // Fetch cart data if we just logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) context.read<CartProvider>().fetchLatestCart(context);
          });
        }
      }
    }
    _lastLoggedInState = isLoggedIn;
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(
        currentIndex: _index,
        visibleItemCount: 5,
        onTap: (i) {
          final wasCreated = _pages[i] != null;
          setState(() {
            _index = i;
            // lazily instantiate page when first accessed
            if (!wasCreated) _pages[i] = _buildPage(i, isLoggedIn);
          });

          // If page was just created, run its initial fetch centrally. If it
          // already existed, treat this as a refresh and call the provider too.
          if (i == 3 && isLoggedIn) {
            context.read<CartProvider>().fetchLatestCart(context);
          } else if (i == 1) {
            context.read<ProductProvider>().getProducts({
              "filterModel": {},
              "orderBy": "productName",
              "orderDir": "ASC",
              "searchText": "",
              "page": 1,
              "pageSize": 10,
            });
          }
        },
      ),
      body: IndexedStack(
        index: _index,
        children: _pages.map((w) => w ?? const SizedBox.shrink()).toList(),
      ),
    );
  }
}
