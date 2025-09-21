import 'package:flutter/material.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/subscription_screen/subscription_screen.dart';

import '../home_screen/home_screen.dart';
import '../product_screen/products_screen.dart';
import 'navigation_bottom_bar.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _index = 0;

  late final List<Widget> _pages = const [
    HomeScreen(),
    ProductScreen(),

    SubscriptionScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
