import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/product_screen/provider/product_provider.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/subscription_product_screen.dart';

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

  Widget _buildPage(int idx, bool isLoggedIn) {
    if (!isLoggedIn) {
      switch (idx) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ProductScreen();
        case 2:
          return const SubscriptionProductScreen();
        default:
          return const SizedBox.shrink();
      }
    } else {
      switch (idx) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ProductScreen();
        case 2:
          return const SubscriptionProductScreen();
        case 3:
          return const CartScreen();
        case 4:
          return const ProfileScreen();
        default:
          return const SizedBox.shrink();
      }
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

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final tabCount = isLoggedIn ? 5 : 3;

    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(
        currentIndex: _index,
        visibleItemCount: tabCount,
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
