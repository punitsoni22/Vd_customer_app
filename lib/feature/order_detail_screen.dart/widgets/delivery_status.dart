import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class DeliveryStatusCard extends StatelessWidget {
  const DeliveryStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Delivered',
                    style: TextStyle(
                      color: AllColors.tabBarline,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    'Dec 21',
                    style: TextStyle(
                      color: AllColors.tabBarline,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your item has been delivered',
            style: TextStyle(color: AllColors.myOrderTextColor, fontSize: 13),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 2,
                  color: AllColors.orderDetailIconColor,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                color: AllColors.orderDetailIconColor,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Confirmed',
                    style: TextStyle(
                      fontSize: 12,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                  Text(
                    'Mar 21',
                    style: TextStyle(
                      fontSize: 12,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Delivered',
                    style: TextStyle(
                      fontSize: 12,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                  Text(
                    'Dec 21',
                    style: TextStyle(
                      fontSize: 12,
                      color: AllColors.myOrderTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
