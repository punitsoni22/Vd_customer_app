import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/subscription_product_card.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/subscription_tab_bar.dart';

class SubscriptionProductScreen extends StatelessWidget {
  const SubscriptionProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Subscription',
        actions: [
          Icon(Icons.calendar_month_outlined, color: AllColors.olivegreenColor),
          SizedBox(width: 5),
          Icon(Icons.search_rounded, color: AllColors.olivegreenColor),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                'Select Products',
                style: TextStyle(
                  color: AllColors.olivegreenColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.h),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 18.h),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  return SubscriptionProductCard();
                },
              ),
              CommonButton(
                buttonValue: 'Confirm Selection',
                color: AllColors.tabBarline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
