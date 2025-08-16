import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColors.textfieldborderColor),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundImage: AssetImage('')),
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
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 23, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
