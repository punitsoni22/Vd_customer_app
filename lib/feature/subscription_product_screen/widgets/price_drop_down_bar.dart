import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class SubscriptionPriceDropdown extends StatefulWidget {
  const SubscriptionPriceDropdown({super.key});

  @override
  State<SubscriptionPriceDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<SubscriptionPriceDropdown> {
  String selectedValue = "100ml at ₹100";

  final List<String> items = [
    "100ml at ₹100",
    "200ml at ₹180",
    "500ml at ₹400",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AllColors.olivegreenColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal),
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${value.split(' at ')[0]} at ",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                    TextSpan(
                      text: value.split(' at ')[1],
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
