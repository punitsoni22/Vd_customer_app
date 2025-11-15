import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/profile_screen/provider/profileProvider.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/logout_button.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_orders_container.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_header_cont.dart' hide LogoutButton;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchSpecificUser(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    String displayName = provider.fullName ?? 'Your name';
    String displayPhone = provider.mobileNumber ?? '';

    if (provider.isLoading) {
      displayName = 'Loading...';
      displayPhone = '';
    }

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
              name: displayName,
              phoneNumber: displayPhone,
              ontouch: () {},
            ),
            SizedBox(height: 15.h),

            if (!provider.isLoading &&
                provider.id == null &&
                provider.message != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  provider.message!,
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ),

            OrdersCard(),
            SizedBox(height: 15.h),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}
