import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_add_subt_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_calendar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/navigation_bar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(
        alignment: Alignment.centerLeft,
        title: 'Order Calendar',
        islineNeeded: true,
        actions: [
          Icon(Icons.shopping_cart_outlined, color: AllColors.olivegreenColor),
          SizedBox(width: 5),
          Icon(Icons.search, color: AllColors.olivegreenColor),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Select Quantity',
                        style: TextStyle(
                          color: AllColors.olivegreenColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    AddSubtButton(radius: 17),
                  ],
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Subscription Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AllColors.olivegreenColor,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CommonButton(
                        selfconstraints: BoxConstraints(
                          maxWidth: 90,
                          maxHeight: 35,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        radius: 20,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        buttonValue: 'Daily',
                        backgroundColor: AllColors.iconColor,
                      ),
                      CommonButton(
                        selfconstraints: BoxConstraints(
                          maxWidth: 90,
                          maxHeight: 35,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        radius: 20,
                        buttonValue: 'Weekly',
                        backgroundColor: AllColors.iconColor,
                      ),
                      CommonButton(
                        selfconstraints: BoxConstraints(
                          maxWidth: 90,
                          maxHeight: 35,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        radius: 20,
                        buttonValue: 'Custom',
                        backgroundColor: AllColors.iconColor,
                      ),
                    ],
                  ),
                ),
                CustomCalendar(),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Subscription Duration',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MyTextField(label: 'Select Duration', radius: 15),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Select Delivery Days',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 19,
                  mainAxisSpacing: 15,
                  childAspectRatio: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CommonButton(
                      buttonValue: 'Mon',
                      backgroundColor: AllColors.backgroundColor,
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CommonButton(
                      buttonValue: 'Tue',
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: AllColors.backgroundColor,
                    ),
                    CommonButton(
                      buttonValue: 'Wed',
                      backgroundColor: AllColors.backgroundColor,
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CommonButton(
                      buttonValue: 'Thu',
                      backgroundColor: AllColors.backgroundColor,
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CommonButton(
                      buttonValue: 'Fri',
                      backgroundColor: AllColors.backgroundColor,
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CommonButton(
                      buttonValue: 'Sat',
                      backgroundColor: AllColors.backgroundColor,
                      textStyle: TextStyle(
                        color: AllColors.olivegreenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CommonButton(
                    buttonValue: 'Add to Cart',
                    backgroundColor: AllColors.iconColor,
                    color: AllColors.iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
