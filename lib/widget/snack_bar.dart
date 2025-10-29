import 'package:flutter/material.dart';
import 'package:vd_customer_app/helpers/text_style.dart';
import 'package:vd_customer_app/theme/color_pallete.dart';

class MySnackBar {
  // Global key for accessing ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,

              gradient: AppColor.mainGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message, style: whitebold),
          ),
        ),
      );
    } catch (e) {
      // Fallback to global key if context is invalid
      showGlobalSnackBar(message);
    }
  }

  static void showGlobalSnackBar(String message) {
    if (rootScaffoldMessengerKey.currentState != null) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              // gradient: AppColor.mainGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message, style: whitebold),
          ),
        ),
      );
    }
  }
}
