import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

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
          _buildMenuItem(Icons.inventory_2_outlined, "All Order’s"),
          _buildMenuItem(Icons.calendar_today_outlined, "Order Calendar"),
          _buildMenuItem(Icons.location_on_outlined, "Address Book"),
          _buildMenuItem(Icons.local_drink_outlined, "Return Empty Bottle"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
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
            child: Icon(icon, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AllColors.buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}
