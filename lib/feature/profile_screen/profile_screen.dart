import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

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
          ? RefreshIndicator(
              onRefresh: () async {
                await provider.fetchSpecificUser(context);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 12.w,
                  ),
                  child: Column(
                    children: [
                      ProfileHeader(
                        name: displayName,
                        phoneNumber: displayPhone,
                        ontouch: () {},
                      ),
                      SizedBox(height: 15.h),
                      OrdersCard(),
                      SizedBox(height: 12.h),
                      // Contact Us Option
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AllColors.outlineColor),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRoutes.contactUsScreen);
                          },
                          child: BuildmenuCont(
                            icon: Icons.support_agent_rounded,
                            title: 'Contact Us',
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Call Us Option
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AllColors.outlineColor),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: '+919414103794',
                            );
                            try {
                              if (!await launchUrl(launchUri)) {
                                if (context.mounted) {
                                  MySnackBar.showSnackBar(
                                    context,
                                    'Could not launch dialer',
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                MySnackBar.showSnackBar(
                                  context,
                                  'Could not launch dialer',
                                );
                              }
                            }
                          },
                          child: BuildmenuCont(
                            icon: Icons.call,
                            title: 'Call Us',
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Delete account button (themed) - left-aligned label
                      SizedBox(
                        width: double.infinity,
                        child: CommonButton(
                          isFullWidth: true,
                          isLoading: provider.isLoading,
                          buttonValue: 'Delete My Account',
                          onTap: provider.isLoading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        contentPadding: EdgeInsets.all(24.w),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Icon
                                            Container(
                                              width: 60.w,
                                              height: 60.h,
                                              decoration: BoxDecoration(
                                                color:
                                                    AllColors.profileBackColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.delete_forever_rounded,
                                                color: Colors.red.shade600,
                                                size: 28.sp,
                                              ),
                                            ),
                                            SizedBox(height: 20.h),

                                            // Title
                                            Text(
                                              'Delete Confirmation',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 12.h),

                                            // Message
                                            Text(
                                              'Are you sure you want to delete your account? This action cannot be undone and all your data will be removed.',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color:
                                                    AllColors.myOrderTextColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        actionsPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        actions: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () => Navigator.of(
                                                      ctx,
                                                    ).pop(false),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                    child: Container(
                                                      height: 44.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        border: Border.all(
                                                          color: AllColors
                                                              .olivegreenColor,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AllColors
                                                                .olivegreenColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: provider.isLoading
                                                        ? null
                                                        : () async {
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(true);
                                                          },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                    child: Container(
                                                      height: 44.h,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade600,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child:
                                                            provider.isLoading
                                                            ? SizedBox(
                                                                width: 18.w,
                                                                height: 18.w,
                                                                child: CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation(
                                                                        Colors
                                                                            .white,
                                                                      ),
                                                                  strokeWidth:
                                                                      2.0,
                                                                ),
                                                              )
                                                            : Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed == true) {
                                    await provider.deleteAccount(context);
                                  }
                                },
                          backgroundColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(5.r),
                          foregroundColor: AllColors.olivegreenColor,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              provider.isLoading
                                  ? 'Deleting...'
                                  : 'Delete My Account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: AllColors.olivegreenColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: CommonButton(
                          isFullWidth: true,
                          isLoading: provider.isLoading,
                          buttonValue: 'About Us',
                          onTap: provider.isLoading
                              ? null
                              : () async {
                                  context.pushNamed(AppRoutes.aboutUsScreen);
                                },
                          backgroundColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(5.r),
                          foregroundColor: AllColors.olivegreenColor,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              provider.isLoading ? '...' : 'About Us',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: AllColors.olivegreenColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      LogoutButton(),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
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
