import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await Prefs.clear(Prefs.keyAuthToken);
    await Prefs.clear(Prefs.keyUserId);

    await Prefs.clearAll();

    Provider.of<CartProvider>(context, listen: false).clearCart();

    if (context.mounted) {
      context.go(AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => _handleLogout(context),
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
