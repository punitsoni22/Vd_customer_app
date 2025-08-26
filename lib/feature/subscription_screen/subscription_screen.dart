import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_imgae_container.dart';
import 'package:vd_customer_app/navigation_bar.dart';

import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';

import 'package:vd_customer_app/feature/subscription_screen/widgets/subscription_tab_bar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(
        alignment: Alignment.centerLeft,
        title: 'Subscription',
        actions: [
          Icon(Icons.calendar_month_outlined, color: AllColors.olivegreenColor),
          SizedBox(width: 5),
          Icon(Icons.search_rounded, color: AllColors.olivegreenColor),
        ],
        islineNeeded: true,
      ),
      bottomNavigationBar: CommonBottomAppbar(),
      body: Column(children: [Expanded(child: SubscriptionTabBar())]),
    );
  }
}
