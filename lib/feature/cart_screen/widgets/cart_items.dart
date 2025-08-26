import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_add_subt_button.dart';

class CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: AllColors.greyborderColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: item["color"],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.delete, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item["price"]} per item",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),

                AddSubtButton(
                  selfconstraints: BoxConstraints(maxWidth: 80),
                  iconColor: Colors.blue,
                  bordercolor: AllColors.greyborderColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
