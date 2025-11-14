import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;

  const CommonEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 110.h),
        Center(
          child: Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: 0.07),
                ),
              ],
            ),
            child: Icon(icon, size: 55.w, color: Colors.grey.shade400),
          ),
        ),
        SizedBox(height: 24.h),
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.w),
            child: Text(
              message!,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        SizedBox(height: 40.h),
      ],
    );
  }
}
