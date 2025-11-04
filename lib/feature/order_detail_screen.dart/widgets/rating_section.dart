import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class RatingSection extends StatelessWidget {
  const RatingSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: AllColors.myOrderTextColor,
                size: 22.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Rate the product',
                style: TextStyle(
                  color: AllColors.myOrderTextColor,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) =>
                        Icon(Icons.star_border, color: Colors.grey, size: 22.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
