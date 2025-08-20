import 'package:flutter/material.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: "Home", islineNeeded: true));
  }
}
