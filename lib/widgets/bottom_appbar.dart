import 'package:flutter/material.dart';

class CommonBottomAppbar extends StatelessWidget {
  const CommonBottomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      ],
    );
  }
}
