import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class DeliveryStatusCard extends StatelessWidget {
  const DeliveryStatusCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Delivered',
                    style: TextStyle(
                      color: AllColors.tabBarline,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Dec 21',
                    style: TextStyle(
                      color: AllColors.tabBarline,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 28.r,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Your item has been delivered',
            style: TextStyle(
              color: AllColors.myOrderTextColor,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 20.r,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Container(
                  height: 2.h,
                  color: AllColors.orderDetailIconColor,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 20.r,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Confirmed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                  Text(
                    'Mar 21',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Delivered',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                  Text(
                    'Dec 21',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
