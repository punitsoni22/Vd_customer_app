import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final bool selected;
  final VoidCallback? onTap;

  const PaymentOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.badge,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: selected ? AllColors.iconColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: selected
                    ? AllColors.badgeSelectedColor
                    : AllColors.badgeUnselectedColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: selected ? AllColors.iconColor : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
