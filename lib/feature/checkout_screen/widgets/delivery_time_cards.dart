import 'package:flutter/material.dart';
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AllColors.iconColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.access_time,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
            Text(
              time,
              style: TextStyle(color: selected ? Colors.white : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
