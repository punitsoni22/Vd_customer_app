import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
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
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go(AppRoutes.bottomBarScreen);
          }
        },
      ),
      body: const MyOrderTabBar(),
    );
  }
}
