import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/widgets/date_dropdown_menu.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/price_drop_down_bar.dart';

class SubscriptionDateScreen extends StatelessWidget {
  const SubscriptionDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Subscription'),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Text(
            'Choose your Delivery Frequency',
            style: TextStyle(
              color: AllColors.olivegreenColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          SubscriptionDateDropdown(),
        ],
      ),
    );
  }
}
