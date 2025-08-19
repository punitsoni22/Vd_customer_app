import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/theme/colors.dart';

class CommonBottomAppbar extends StatefulWidget {
  // final Widget child;
  const CommonBottomAppbar({super.key});

  @override
  State<CommonBottomAppbar> createState() => _CommonBottomAppbarState();
}

class _CommonBottomAppbarState extends State<CommonBottomAppbar> {
  // int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AllColors.backgroundColor,
      type: BottomNavigationBarType.fixed,
      // currentIndex: currentIndex,
      // selectedItemColor: Colors.white,
      // unselectedItemColor: Colors.white.withOpacity(0.6),
      // onTap: (value) {
      //   setState(() => currentIndex = value);
      //   switch (value) {
      //     case 0:
      //       context.go("/home");
      //       break;
      //     case 1:
      //       context.go("/products");
      //       break;
      //     case 2:
      //       context.go("/subscription");
      //       break;
      //     case 3:
      //       context.go("/cart");
      //       break;
      //     case 4:
      //       context.go("/profile");
      //       break;
      //   }
      // },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box_outline_blank),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'Subscription',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
