import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/logout_button.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_orders_container.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_header_cont.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        titleAlignment: BarTitleAlignment.center,
      ),
      backgroundColor: Colors.white,

      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        child: Column(
          children: [
            ProfileHeader(
              name: 'Hello Emma',
              phoneNumber: '9746132587',
              ontouch: () {},
            ),
            SizedBox(height: 15.h),
            OrdersCard(),
            SizedBox(height: 15.h),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}
