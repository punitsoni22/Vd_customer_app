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
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),

        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.grey.shade50,
                border: Border.all(
                  color: selected ? primary.withValues(alpha: 0.2) : Colors.transparent,
                ),
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: selected ? primary : Colors.grey[600],
              ),
            ),

            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.black : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            if (selected)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 14.sp,
                  color: Colors.white,
                ),
              )
            else if (badge.isNotEmpty)
               Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AllColors.badgeUnselectedColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
