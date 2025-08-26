import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final bool selected;

  const PaymentOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.badge,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: selected ? AllColors.iconColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.black),
          const SizedBox(width: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? AllColors.badgeSelectedColor
                  : AllColors.badgeUnselectedColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AllColors.iconColor : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
