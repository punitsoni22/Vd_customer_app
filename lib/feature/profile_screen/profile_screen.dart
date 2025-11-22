import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/utils/common_widgets/common_appbar.dart';
import 'provider/profileProvider.dart';
import 'widgets/logout_button.dart';
import 'widgets/profile_header_cont.dart';
import 'widgets/profile_orders_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    String displayName = provider.fullName ?? 'Your name';
    String displayPhone = provider.mobileNumber ?? 'xxxxx-xxxxx';

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        titleAlignment: BarTitleAlignment.center,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        child: Column(
          children: [
            ProfileHeader(
              name: displayName,
              phoneNumber: displayPhone,
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
