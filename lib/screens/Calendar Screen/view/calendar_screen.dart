import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/add_subt_button.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/calendar_container.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/text_field.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Order Calendar',
        islineNeeded: true,
        actions: [
          Icon(Icons.shopping_cart_outlined, color: AllColors.olivegreenColor),
          Icon(Icons.search, color: AllColors.olivegreenColor),
        ],
      ),
      body: SingleChildScrollView(
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

                  AddSubtButton(),
                ],
              ),
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
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CommonButton(
                      buttonValue: 'Daily',
                      backgroundColor: AllColors.iconColor,
                    ),
                    CommonButton(
                      buttonValue: 'Weekly',
                      backgroundColor: AllColors.iconColor,
                    ),
                    CommonButton(
                      buttonValue: 'Custom',
                      backgroundColor: AllColors.iconColor,
                    ),
                  ],
                ),
              ),
              CustomCalendar(),

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
              MyTextField(label: 'Select Duration'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Select Delivery',
                  style: TextStyle(
                    color: AllColors.olivegreenColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
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
                    buttonValue: 'Thurs',
                    backgroundColor: AllColors.backgroundColor,
                    textStyle: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CommonButton(
                    buttonValue: 'Friday',
                    backgroundColor: AllColors.backgroundColor,
                    textStyle: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              CommonButton(
                buttonValue: 'Add to Cart',
                backgroundColor: AllColors.iconColor,
                color: AllColors.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
