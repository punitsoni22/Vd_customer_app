import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class SubscriptionDateDropdown extends StatefulWidget {
  const SubscriptionDateDropdown({super.key});

  @override
  State<SubscriptionDateDropdown> createState() =>
      _SubscriptionDateDropdownState();
}

class _SubscriptionDateDropdownState extends State<SubscriptionDateDropdown> {
  String selectedValue = "Daily";

  final List<String> items = ["Daily", "Weekly", "Alternate Day", "Custom "];

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
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}
