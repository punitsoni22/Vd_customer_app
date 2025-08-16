import 'package:flutter/material.dart';
import 'package:vd_customer_app/constants/pick_region_list.dart';
import 'package:vd_customer_app/theme/colors.dart';

class City {
  final String name;
  final String image;

  City({required this.name, required this.image});
}

class CityContainer extends StatelessWidget {
  final City city;
  final bool selected;
  const CityContainer({super.key, required this.city, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AllColors.buttonColor : AllColors.backgroundColor,
        border: Border.all(color: AllColors.buttonColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 90,
            child: Image.asset(city.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 7),
          Text(
            city.name,
            style: TextStyle(
              color: selected
                  ? AllColors.backgroundColor
                  : AllColors.buttonColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
