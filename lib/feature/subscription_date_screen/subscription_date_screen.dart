import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/widgets/date_dropdown_menu.dart';

class SubscriptionDateScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? selectedProducts;
  const SubscriptionDateScreen({super.key, this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Subscription',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                'Choose your Delivery Frequency',
                style: TextStyle(
                  color: AllColors.olivegreenColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 9.h),
              SubscriptionDateDropdown(selectedProducts: selectedProducts),
            ],
          ),
        ),
      ),
    );
  }
}
