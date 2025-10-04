import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_calendar.dart';

class SubscriptionDateDropdown extends StatefulWidget {
  const SubscriptionDateDropdown({super.key});

  @override
  State<SubscriptionDateDropdown> createState() =>
      _SubscriptionDateDropdownState();
}

class _SubscriptionDateDropdownState extends State<SubscriptionDateDropdown> {
  String selectedValue = "Daily";

  final List<String> items = ["Daily", "Weekly", "Alternate Day", "Custom"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38.h,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AllColors.olivegreenColor, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        _buildWidgetForSelection(selectedValue),
      ],
    );
  }

  Widget _buildWidgetForSelection(String value) {
    switch (value) {
      case "Weekly":
        return _weeklyWidget();
      case "Alternate Day":
        return _alternateDayWidget();
      case "Custom":
        return _customWidget();
      default:
        return const SizedBox();
    }
  }

  Widget _weeklyWidget() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Delivery Days',
            style: TextStyle(
              color: AllColors.olivegreenColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 19,
            mainAxisSpacing: 15,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
                CommonButton(
                  buttonValue: day,
                  backgroundColor: Colors.grey[50],
                  textStyle: TextStyle(
                    color: AllColors.olivegreenColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alternateDayWidget() => _simpleBox("Alternate Day");

  Widget _customWidget() {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: const CustomCalendar(),
    );
  }

  Widget _simpleBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        border: Border.all(color: AllColors.olivegreenColor),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(text),
    );
  }
}
