import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vd_customer_app/feature/product_detail_screen/product_detail_screen.dart';
import 'package:vd_customer_app/feature/product_detail_screen/provider/product_detail_provider.dart';

import 'feature/product_list_screen/products_screen.dart';
import 'feature/product_list_screen/provider/product_screen_provider.dart';
import 'feature/login_screen/provider/login_provider.dart';
import 'feature/signup_screen/provider/signup_provider.dart';
import 'feature/auth_screen/provider/auth_provider.dart';
import 'feature/home_screen/provider/home_screen_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation != Orientation.portrait) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Please rotate your phone to portrait",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SignupProvider()),
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
            ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
          ],
          child: MaterialApp(
            title: 'Vd Customer App',
            debugShowCheckedModeBanner: false,
            home: const ProductDetailScreen(),
          ),
        );
      },
    );
  }
}
