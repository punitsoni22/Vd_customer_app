import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
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
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post("getSpecificUser", {"data": {}});
      if (response["success"] == true && response["data"] != null) {
        final userData = response["data"];
        id = userData["id"];
        fullName = userData["fullName"];
        emailId = userData["emailId"];
        mobileNumber = userData["mobileNumber"];
        isVerified = userData["isVerified"];
        roleName = userData["role"]?["name"];

        message = response["message"] ?? "User details fetched successfully";
      } else {
        message = response["message"] ?? "Failed to fetch user details";
        final msgStr = message.toString();
          if (msgStr.contains('401')) {
            await Prefs.clear(Prefs.keyAuthToken);
            await Prefs.clear(Prefs.keyUserId);
            await Prefs.clearAll();
            MySnackBar.showSnackBar(
              context,
              "Session expired. Please log in again.",
            );
            // ignore: use_build_context_synchronously
            try {
              context.read<AuthProvider>().clearToken();
            } catch (_) {}
            context.goNamed(AppRoutes.bottomBarScreen);
          }
      }
    } catch (e, st) {
      message = "Exception: $e";
      log("Exception while fetching user: $e\n$st");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteAccount(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Api.post('deleteMyAccount', {});
      if (response['success'] == true) {
        await Prefs.clearAll();
        clearUserData();
        try {
          if (context.mounted) {
            context.read<AuthProvider>().clearToken();
            context.read<CartProvider>().clearCart();
          }
        } catch (_) {}

        if (context.mounted) {
          MySnackBar.showSnackBar(context, 'Account deleted successfully');
          context.goNamed(AppRoutes.bottomBarScreen);
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final msg = response['message'] ?? 'Failed to delete account';
        if (context.mounted) MySnackBar.showSnackBar(context, msg);
        try {
          final msgStr = msg.toString();
          if (msgStr.contains('401')) {
            await Prefs.clearAll();
            if (context.mounted) context.goNamed(AppRoutes.bottomBarScreen);
          }
        } catch (_) {}

        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      message = 'Exception: $e';
      if (context.mounted) MySnackBar.showSnackBar(context, message!);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addContactUs(BuildContext context, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Api.post('addContactUs', {'data': data});

      if (response['success'] == true || response['dataResponse']?['returnCode'] == 0) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final msg = response['message'] ?? 'Failed to send message';
        if (context.mounted) MySnackBar.showSnackBar(context, msg);
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      message = 'Exception: $e';
      if (context.mounted) MySnackBar.showSnackBar(context, message!);
      isLoading = false;
      notifyListeners();
      return false;
    }
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
