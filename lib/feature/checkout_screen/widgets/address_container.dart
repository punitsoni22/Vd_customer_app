import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class AddressContainer extends StatelessWidget {
  final String title;
  final String? name;
  final String? address;
  final String? number;
  final IconData? icon;
  const AddressContainer({
    super.key,
    this.address,
    this.number,
    this.icon,
    this.name,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AllColors.backgroundColor,
        border: Border.all(color: AllColors.textfieldborderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(name!, style: TextStyle(fontSize: 17, color: Colors.black)),
          SizedBox(height: 0),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AllColors.greenIconBackColor,
                ),
                child: Icon(icon, size: 17, color: AllColors.iconColor),
              ),
              Text(
                address!,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color.fromARGB(255, 106, 106, 106),
                ),
                maxLines: 3,
              ),
            ],
          ),
          SizedBox(height: 3),
          Text(
            number!,
            style: TextStyle(
              fontSize: 14,
              color: const Color.fromARGB(255, 106, 106, 106),
            ),
          ),
        ],
      ),
    );
  }
}
