import 'package:flutter/material.dart';
import 'package:vd_customer_app/navigation_bar.dart';

import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/custom_container.dart';
import 'package:vd_customer_app/widgets/tab_bar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Subscription',
        actions: [Icon(Icons.search_rounded)],
        islineNeeded: true,
      ),
      bottomNavigationBar: CommonBottomAppbar(),
      body: SubscriptionTabBar(),
    );
  }
}
