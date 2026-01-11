import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class DeliveryTimeCards extends StatelessWidget {
  final String title;
  final String time;
  final bool selected;
  final VoidCallback? onTap;

  const DeliveryTimeCards({
    super.key,
    required this.title,
    required this.time,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: selected ? AllColors.iconColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AllColors.iconColor : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (selected)
              BoxShadow(
                color: AllColors.iconColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: selected ? Colors.white : Colors.grey.shade700,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: TextStyle(
                fontSize: 12.sp,
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
