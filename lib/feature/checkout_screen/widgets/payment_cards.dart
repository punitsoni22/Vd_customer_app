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
    final Color primary = AllColors.iconColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? primary.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: selected ? primary : Colors.grey[800],
              ),
            ),

            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.black : Colors.black87,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: selected ? primary : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
