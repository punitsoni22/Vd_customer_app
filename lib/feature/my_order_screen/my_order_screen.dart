import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/my_order_tab_bar.dart';

class MyOrderScreen extends StatelessWidget {
  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'My Orders',
        showBack: true,
        titleAlignment: BarTitleAlignment.center,
      ),
      body: const MyOrderTabBar(),
    );
  }
}
