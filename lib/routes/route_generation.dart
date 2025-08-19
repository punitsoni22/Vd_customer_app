import 'package:flutter/material.dart';
import 'package:vd_customer_app/screens/Home/view/home_page.dart';
import 'package:vd_customer_app/screens/Region%20Screen/view/region_screen.dart';
import 'package:vd_customer_app/screens/auth/view/login_screen.dart';
import 'package:vd_customer_app/screens/auth/view/otp_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/otp':
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/region':
        return MaterialPageRoute(builder: (_) => const RegionScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
