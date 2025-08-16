import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

class SmallBottle {
  final String bottlename;
  final String bottleimage;

  SmallBottle({required this.bottlename, required this.bottleimage});
}

class SmallBottleCards extends StatelessWidget {
  final SmallBottle smallBottle;
  const SmallBottleCards({super.key, required this.smallBottle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AllColors.backgroundColor,
        border: Border.all(color: AllColors.buttonColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            child: Image.asset(smallBottle.bottleimage, fit: BoxFit.contain),
          ),
          const SizedBox(height: 1),
          Text(
            smallBottle.bottlename,
            style: TextStyle(
              color: AllColors.buttonColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
