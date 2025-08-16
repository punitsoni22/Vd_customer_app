import 'package:flutter/material.dart';
import 'package:vd_customer_app/screens/auth/view/checkout_screen.dart';
import 'package:vd_customer_app/screens/auth/view/login_screen.dart';
import 'package:vd_customer_app/screens/auth/view/otp_screen.dart';
import 'package:vd_customer_app/screens/auth/view/products_page.dart';
import 'package:vd_customer_app/screens/auth/view/profile_page.dart';
import 'package:vd_customer_app/screens/auth/view/region_screen.dart';
import 'package:vd_customer_app/screens/auth/view/subscription_screen.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
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
      home: ProfilePage(),
    );
  }
}
