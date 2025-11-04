import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final VoidCallback ontouch;
  const ProfileHeader({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.ontouch,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.outlineColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27.r,
            backgroundImage: AssetImage('assets/images/bottlerect.png'),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AllColors.profileBackColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit, size: 23.r, color: AllColors.iconColor),
          ),
        ],
      ),
    );
  }
}
