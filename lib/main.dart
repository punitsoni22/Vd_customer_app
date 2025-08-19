import 'package:flutter/material.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/routes/route_generation.dart';
import 'package:vd_customer_app/screens/Calendar%20Screen/view/calendar_screen.dart';
import 'package:vd_customer_app/screens/Cart/view/cart_screen.dart';
import 'package:vd_customer_app/screens/Checkout%20Screen/view/checkout_screen.dart';
import 'package:vd_customer_app/screens/Home/view/home_page.dart';
import 'package:vd_customer_app/screens/auth/view/login_screen.dart';
import 'package:vd_customer_app/screens/auth/view/otp_screen.dart';
import 'package:vd_customer_app/screens/Product%20Detail/view/product_detail_screen.dart';
import 'package:vd_customer_app/screens/Product%20Listing/view/products_page.dart';
import 'package:vd_customer_app/screens/Profile/view/profile_page.dart';
import 'package:vd_customer_app/screens/Region%20Screen/view/region_screen.dart';
import 'package:vd_customer_app/screens/Subscription/view/subscription_screen.dart';
import 'package:vd_customer_app/screens/auth/view/xd.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/image_container.dart';
import 'package:vd_customer_app/widgets/tab_bar.dart';
import 'package:vd_customer_app/widgets/text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vd Customer App',
      debugShowCheckedModeBanner: false,
      // initialRoute: '/otp',
      // onGenerateRoute: RouteGenerator.generateRoute,
      home: CartScreen(),
    );
  }
}
