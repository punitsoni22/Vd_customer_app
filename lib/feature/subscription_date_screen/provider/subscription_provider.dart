import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/models/admin_plan_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/helpers/auth_helper.dart';

import '../../../core/services/signedurl.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _subscriptionCreatedSuccessfully = false;
  bool get subscriptionCreatedSuccessfully => _subscriptionCreatedSuccessfully;

  // Pincode Validation State
  bool _isCheckingDelivery = false;
  bool get isCheckingDelivery => _isCheckingDelivery;

  bool _isDeliverable = false;
  bool get isDeliverable => _isDeliverable;

  String _deliveryMessage = '';
  String get deliveryMessage => _deliveryMessage;

  Future<void> checkDeliveryPincode(String pinCode) async {
    _isCheckingDelivery = true;
    _deliveryMessage = '';
    notifyListeners();

    try {
      final response = await Api.post('checkDeliveryPincode', {
        "data": {
          "pinCode": [pinCode],
        },
      });

      log("checkDeliveryPincode Response: $response");

      bool isSuccess = false;
      Map<String, dynamic>? data;

      if (response['success'] == true) {
        isSuccess = true;
        data = response['data'];
      } else if (response['dataResponse']?['returnCode'] == 0) {
        isSuccess = true;
        data = response['data'];
      }

      if (isSuccess && data != null) {
        _isDeliverable = data['isDeliverable'] == true;
        _deliveryMessage =
            data['message'] ??
            (_isDeliverable
                ? "Delivery is available."
                : "Delivery not available.");
      } else {
        _isDeliverable = false;
        _deliveryMessage =
            response['message'] ??
            response['dataResponse']?['description'] ??
            "Unable to verify delivery.";
      }
    } catch (e) {
      log("checkDeliveryPincode error: $e");
      _isDeliverable = false;
      _deliveryMessage = "Error verifying delivery pincode.";
    }

    _isCheckingDelivery = false;
    notifyListeners();
  }

  void resetDeliveryStatus() {
    _isDeliverable = false;
    _deliveryMessage = '';
    notifyListeners();
  }

  void clearSuccessFlag() {
    _subscriptionCreatedSuccessfully = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createOrEditSubscription(
    BuildContext context,
    Map<String, dynamic> payload,
  ) async {
    if (!AuthHelper.requireLogin(
      context,
      message: 'Please login to create subscription',
    )) {
      return {'success': false, 'message': 'Login required'};
    }

    try {
      final response = await Api.post('addEditSubscription', payload);
      if (response["success"] == true) {
        _subscriptionCreatedSuccessfully = true;
        notifyListeners();
      }
      return response;
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  bool isLoading = false;
  List<AddressModel> addresses = [];
  String? message;

  Future<void> getAllAddresses(BuildContext context) async {
    if (!AuthHelper.requireLogin(
      context,
      message: 'Please login to view addresses',
    )) {
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      final response = await Api.post('getAllAddress', {});
      if (response['success'] == true) {
        final List<dynamic> rows = response['data']?['rows'] ?? [];
        addresses = rows.map((e) => AddressModel.fromJson(e)).toList();
        message = response['message'] ?? 'Addresses fetched successfully';
      } else {
        addresses = [];
        message = response['message'] ?? 'Failed to fetch addresses';
      }
    } catch (e) {
      addresses = [];
      message = 'Exception: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
    notifyListeners();
  }

  // Admin Plans
  bool isLoadingPlans = false;
  bool isMorePlansLoading = false;
  List<AdminPlanModel> adminPlans = [];
  AdminPlanModel? selectedPlan;

  // Pagination state for plans
  int currentPlanPage = 1;
  int totalPlanPages = 1;
  static const int _planPageSize = 10;

  Future<void> getAllActivePlans(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    // If refreshing, reset pagination and clear list
    if (forceRefresh) {
      currentPlanPage = 1;
      adminPlans.clear();
      isLoadingPlans = true;
      notifyListeners();
    } else {
      // If not refreshing and already loading, do nothing
      if (isLoadingPlans || isMorePlansLoading) return;

      // If we've reached the end, do nothing
      if (currentPlanPage > totalPlanPages && totalPlanPages > 0) return;

      if (currentPlanPage == 1) {
        isLoadingPlans = true;
      } else {
        isMorePlansLoading = true;
      }
      notifyListeners();
    }

    try {
      final response = await Api.post('getAllActivePlansForUsers', {
        "data": {
          "searchText": "",
          "page": currentPlanPage,
          "pageSize": _planPageSize,
        },
      });

      log("this is response: $response");

      if (response['success'] == true) {
        final List<dynamic> plansData = response['data']?['plans'] ?? [];
        final pagination = response['data']?['pagination'];
        
        if (pagination != null) {
          totalPlanPages = pagination['totalPages'] ?? 1;
        }

        final newPlans =
            plansData.map((e) => AdminPlanModel.fromJson(e)).toList();

        // Generate signed URLs for images
        for (var plan in newPlans) {
          for (var product in plan.products) {
            for (var image in product.images) {
              if (image.imageUrl.isNotEmpty) {
                image.signedUrl = await generateSignedUrl(image.imageUrl);
              }
            }
          }
        }

        if (forceRefresh || currentPlanPage == 1) {
          adminPlans = newPlans;
        } else {
          adminPlans.addAll(newPlans);
        }

        // Increment page for next fetch
        if (newPlans.isNotEmpty) {
          currentPlanPage++;
        }
        
        message = response['message'] ?? 'Plans fetched successfully';
      } else {
        if (currentPlanPage == 1) {
          adminPlans = [];
        }
        message = response['message'] ?? 'Failed to fetch plans';
      }
    } catch (e) {
      if (currentPlanPage == 1) {
        adminPlans = [];
      }
      message = 'Exception: $e';
    }

    isLoadingPlans = false;
    isMorePlansLoading = false;
    notifyListeners();
  }

  Future<AdminPlanModel?> getSpecificAdminPlan(
    BuildContext context,
    int planId,
  ) async {
    isLoadingPlans = true;
    notifyListeners();

    try {
      final response = await Api.post('getSpecificAdminPlan', {
        "data": {"id": planId},
      });

      log("thgis is $response");

      if (response['success'] == true) {
        final planData = response['data'];
        if (planData != null) {
          selectedPlan = AdminPlanModel.fromJson(planData);
          for (var product in selectedPlan!.products) {
            for (var image in product.images) {
              if (image.imageUrl.isNotEmpty) {
                image.signedUrl = await generateSignedUrl(image.imageUrl);
              }
            }
          }
          message = 'Plan details fetched successfully';
          isLoadingPlans = false;
          notifyListeners();
          return selectedPlan;
        }
      } else {
        message = response['message'] ?? 'Failed to fetch plan details';
      }
    } catch (e) {
      message = 'Exception: $e';
    }

    isLoadingPlans = false;
    notifyListeners();
    return null;
  }

  void clearSelectedPlan() {
    selectedPlan = null;
    notifyListeners();
  }
}
