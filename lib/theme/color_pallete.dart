import 'package:flutter/material.dart';

class AppColor {
  static Color primaryColor = Color(0xFF4BC7A4);
  static const secondaryColor = Color(0xFF256150);
  static Color constWhite = Color(0xFFffffff);
  static Color background = Color(0xFFF7F7F7);
  static Color constBlack = Color(0xFF000000);

  static Gradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColor.primaryColor, AppColor.secondaryColor],
  );

  static LinearGradient primaryGradient = LinearGradient(
    colors: [AppColor.primaryColor, AppColor.secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
