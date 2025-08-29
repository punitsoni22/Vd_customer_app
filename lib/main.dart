import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/constants/cart_items.dart';
import 'package:vd_customer_app/core/services/xd.dart';
import 'package:vd_customer_app/feature/login_screen/login_screen.dart';
import 'package:vd_customer_app/feature/register_screen/signup_screen.dart';
import 'package:vd_customer_app/feature/register_screen/provider/signup_provider.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/core/routing/route_generation.dart';
import 'package:vd_customer_app/feature/calendar_screen/calendar_screen.dart';
import 'package:vd_customer_app/feature/cart_screen/cart_screen.dart';
import 'package:vd_customer_app/feature/checkout_screen/checkout_screen.dart';
import 'package:vd_customer_app/feature/home_screen/home_page.dart';
import 'package:vd_customer_app/feature/product_detail_screen/product_detail_screen.dart';
import 'package:vd_customer_app/feature/product_list_screen/products_page.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/region_screen/region_screen.dart';
import 'package:vd_customer_app/feature/subscription_screen/subscription_screen.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_imgae_container.dart';
import 'package:vd_customer_app/feature/subscription_screen/widgets/subscription_tab_bar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SignupProvider())],
      child: MaterialApp(
        title: 'Vd Customer App',
        debugShowCheckedModeBanner: false,
        // routerConfig: MyAppRouter().router,
        home: CalendarScreen(),
      ),
    );
  }
}
