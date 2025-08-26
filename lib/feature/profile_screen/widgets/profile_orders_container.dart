import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColors.textfieldborderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Orders",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AllColors.buttonColor,
            ),
          ),
          const SizedBox(height: 12),
          BuildmenuCont(icon: Icons.inventory_2_outlined, title: 'All Order’s'),
          BuildmenuCont(
            icon: Icons.calendar_today_outlined,
            title: 'Order Calendar',
          ),
          BuildmenuCont(
            icon: Icons.location_on_outlined,
            title: 'Address Book',
          ),
          BuildmenuCont(
            icon: Icons.local_drink_outlined,
            title: 'Return Empty Bottle',
          ),
        ],
      ),
    );
  }
}

class BuildmenuCont extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textcolor;
  final Color? iconColor;

  const BuildmenuCont({
    super.key,
    required this.icon,
    required this.title,
    this.textcolor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor ?? Colors.green),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textcolor ?? AllColors.buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}
