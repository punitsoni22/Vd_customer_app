import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';

class CustomContainer extends StatelessWidget {
  final String text;
  final String text2;
  const CustomContainer({super.key, required this.text, required this.text2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, bottom: 8),
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        color: AllColors.buttonColor,

        boxShadow: [BoxShadow(spreadRadius: 0.5, blurRadius: 9)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          Text(text2, style: TextStyle(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }
}

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

class PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final bool selected;

  const PaymentOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.badge,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: selected ? AllColors.iconColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? AllColors.badgeSelectedColor
                  : AllColors.badgeUnselectedColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AllColors.iconColor : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class BuildmenuCont extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textcolor;
  final Color? iconColor;

  const BuildmenuCont({
    super.key,
    required this.icon,
    required this.title,
    this.textcolor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor ?? Colors.green),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textcolor ?? AllColors.buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final CrossAxisAlignment? crossAxisAlignment;
  final double? iconSize;
  final double? borderRadius;

  const CustomInfoContainer({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.crossAxisAlignment,
    this.iconSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize ?? 20, color: iconColor ?? Colors.black),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
