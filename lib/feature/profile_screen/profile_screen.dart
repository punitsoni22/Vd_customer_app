import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../auth_screen/provider/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context);
    final provider = Provider.of<ProfileProvider>(context);

    String displayName = provider.fullName ?? 'Your name';
    String displayPhone = provider.mobileNumber ?? 'xxxxx-xxxxx';

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        titleAlignment: BarTitleAlignment.center,
      ),
      backgroundColor: Colors.white,
      body: authProvider.isLoggedIn
          ? Padding(
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
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 100.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Login to Access Your Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Sign in to view your orders, manage subscriptions, and access exclusive features',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    CommonButton(
                      buttonValue: 'Login',
                      onTap: () {
                        context.pushNamed(AppRoutes.loginScreen);
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.signupScreen);
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AllColors.buttonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
