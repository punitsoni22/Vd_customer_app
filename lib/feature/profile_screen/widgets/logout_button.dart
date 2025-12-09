import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
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
                  color: AllColors.profileBackColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AllColors.olivegreenColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Logout Confirmation',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColors.olivegreenColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Message
              Text(
                'Are you sure you want to logout from your account?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AllColors.myOrderTextColor,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AllColors.olivegreenColor,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AllColors.olivegreenColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Logout Button
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(dialogContext).pop();
                        await _handleLogout(context);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AllColors.tabBarline,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await Prefs.clear(Prefs.keyAuthToken);
    await Prefs.clear(Prefs.keyUserId);

    await Prefs.clearAll();

    Provider.of<CartProvider>(context, listen: false).clearCart();

    await context.read<AuthProvider>().clearToken();
    if (context.mounted) {
      context.goNamed(AppRoutes.bottomBarScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AllColors.olivegreenColor),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: AllColors.olivegreenColor,
                border: Border.all(color: AllColors.olivegreenColor),
              ),
              width: 25.w,
              height: 25.h,
              child: Icon(Icons.logout, size: 12.sp, color: Colors.white),
            ),
            SizedBox(width: 10.h),
            Text(
              'Logout',
              style: TextStyle(
                color: AllColors.olivegreenColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
