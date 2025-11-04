import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Orders",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AllColors.buttonColor,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push(AppRoutes.myOrderScreen);
            },
            child: BuildmenuCont(
              icon: Icons.inventory_2_outlined,
              title: 'All Order’s',
            ),
          ),
          BuildmenuCont(
            icon: Icons.calendar_today_outlined,
            title: 'Order Calendar',
          ),
          BuildmenuCont(
            icon: Icons.location_on_outlined,
            title: 'Address Book',
          ),
          BuildmenuCont(
            icon: Icons.local_drink_outlined,
            title: 'Return Empty Bottle',
          ),
        ],
      ),
    );
  }
}

class BuildmenuCont extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textcolor;
  final Color? iconColor;

  const BuildmenuCont({
    super.key,
    required this.icon,
    required this.title,
    this.textcolor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AllColors.profileBackColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.r,
              color: iconColor ?? AllColors.profileIconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textcolor ?? AllColors.buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}
