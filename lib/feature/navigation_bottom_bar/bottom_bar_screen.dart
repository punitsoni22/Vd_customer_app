import 'package:flutter/material.dart';

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
    ProductScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(
        currentIndex: _index,
        visibleItemCount: _pages.length,
        onTap: (i) => setState(() => _index = i),
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
