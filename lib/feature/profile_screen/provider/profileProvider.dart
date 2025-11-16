import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;

  int? id;
  String? fullName;
  String? emailId;
  String? mobileNumber;
  bool? isVerified;
  String? roleName;

  Future<void> fetchSpecificUser(BuildContext context) async {
    log("Fetching specific user started");
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post("getSpecificUser", {"data": {}});

      log("getSpecificUser API Response → $response");

      if (response["success"] == true && response["data"] != null) {
        final userData = response["data"];
        id = userData["id"];
        fullName = userData["fullName"];
        emailId = userData["emailId"];
        mobileNumber = userData["mobileNumber"];
        isVerified = userData["isVerified"];
        roleName = userData["role"]?["name"];

        message = response["message"] ?? "User details fetched successfully";
        log("User fetched → $fullName | $mobileNumber | Role: $roleName");
      } else {
        message = response["message"] ?? "Failed to fetch user details";
        log("Fetch failed → $message");
        final msgStr = message.toString();
        if (msgStr.contains('401')) {
          await Prefs.clear(Prefs.keyAuthToken);
          await Prefs.clear(Prefs.keyUserId);
          await Prefs.clearAll();
          MySnackBar.showSnackBar(
            context,
            "Session expired. Please log in again.",
          );
          context.goNamed(AppRoutes.loginScreen);
        }
      }
    } catch (e, st) {
      message = "Exception: $e";
      log("Exception while fetching user: $e\n$st");
    }

    isLoading = false;
    notifyListeners();
  }

  void clearUserData() {
    id = null;
    fullName = null;
    emailId = null;
    mobileNumber = null;
    isVerified = null;
    roleName = null;
    message = null;
    notifyListeners();
  }
}
