import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/custom_container.dart';

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
