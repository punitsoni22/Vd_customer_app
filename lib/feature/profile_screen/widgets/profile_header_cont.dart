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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColors.outlineColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27.r,
            backgroundImage: AssetImage('assets/images/bottlerect.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phoneNumber,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AllColors.profileBackColor,

              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit, size: 23, color: AllColors.iconColor),
          ),
        ],
      ),
    );
  }
}
