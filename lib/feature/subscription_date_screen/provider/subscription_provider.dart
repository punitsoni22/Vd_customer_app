import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/models/admin_plan_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/helpers/auth_helper.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

import '../../../core/services/signedurl.dart';

class SubscriptionProvider extends ChangeNotifier {
  late Razorpay _razorpay;
  int? _pendingOrderId;
  String? _pendingOrderNo;
  BuildContext? _pendingContext;

  SubscriptionProvider() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  bool _subscriptionCreatedSuccessfully = false;
  bool get subscriptionCreatedSuccessfully => _subscriptionCreatedSuccessfully;

  bool _isCheckingDelivery = false;
  bool get isCheckingDelivery => _isCheckingDelivery;

  bool _isDeliverable = false;
  bool get isDeliverable => _isDeliverable;

  String _deliveryMessage = '';
  String get deliveryMessage => _deliveryMessage;
  List<String> _undeliverableProducts = [];
  List<String> get undeliverableProducts => _undeliverableProducts;
  List<String> _deliverableProducts = [];
  List<String> get deliverableProducts => _deliverableProducts;

  Future<void> checkDeliveryPincode(
    String pinCode,
    List<int> productIds,
  ) async {
    _isCheckingDelivery = true;
    _deliveryMessage = '';
    _undeliverableProducts = [];
    _deliverableProducts = [];
    notifyListeners();

    try {
      final response = await Api.post('checkDeliveryPincode', {
        "data": {
          "pinCode": pinCode,
          "productId": productIds,
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
        if (data['undeliverableProducts'] != null) {
          _undeliverableProducts =
              List<String>.from(data['undeliverableProducts']);
        }
        if (data['deliverableProducts'] != null) {
          _deliverableProducts = List<String>.from(data['deliverableProducts']);
        }
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
      log("this is addEditSubscription api response: $response");
      final isSuccess =
          response['dataResponse']?['returnCode'] == 0 ||
          response['success'] == true;

      if (isSuccess) {
        final orderData = response['data'] as Map<String, dynamic>? ?? {};
        final respPaymentMode = orderData['paymentMode']?.toString() ?? '';
        Map<String, dynamic>? paymentData =
            orderData['payment'] as Map<String, dynamic>?;

        if (paymentData == null && orderData.containsKey('razorpayOrderId')) {
          paymentData = orderData;
        }

        if (respPaymentMode.toUpperCase() == 'ONLINE' && paymentData != null) {
          _openRazorpay(paymentData, orderData, context);
          return {'success': true, 'message': 'Proceeding to payment...'};
        } else {
          _subscriptionCreatedSuccessfully = true;
          notifyListeners();
          return response;
        }
      } else {
        return {
          "success": false,
          "message":
              response['message'] ??
              response['dataResponse']?['description'] ??
              "Failed to create subscription",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  void _openRazorpay(
    Map<String, dynamic> paymentData,
    Map<String, dynamic> orderData,
    BuildContext context,
  ) {
    _pendingOrderId = orderData['id'] is int
        ? orderData['id']
        : (int.tryParse(orderData['id']?.toString() ?? ''));
    _pendingOrderNo = orderData['orderNo']?.toString();
    _pendingContext = context;

    final key =
        paymentData['keyId']?.toString() ?? paymentData['key']?.toString();
    double amountDouble = 0;
    try {
      amountDouble = paymentData['amount'] is String
          ? double.tryParse(paymentData['amount']) ?? 0
          : (paymentData['amount'] is num
                ? (paymentData['amount'] as num).toDouble()
                : 0);
    } catch (_) {}

    final options = {
      'key': key,
      'amount': (amountDouble * 100).toInt(),
      'name': paymentData['name'] ?? 'Store',
      'description': paymentData['description'] ?? 'Subscription Payment',
      'order_id': paymentData['razorpayOrderId'] ?? paymentData['orderId'],
      'currency': paymentData['currency'] ?? 'INR',
      'prefill': paymentData['prefill'] ?? {},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      MySnackBar.showSnackBar(
        context,
        'Payment gateway error. Please try again.',
      );
      _pendingOrderId = null;
      _pendingOrderNo = null;
      _pendingContext = null;
      notifyListeners();
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    notifyListeners();

    try {
      final payload = {
        'data': {
          'orderId': _pendingOrderId,
          'orderNo': _pendingOrderNo,
          'paymentId': response.paymentId,
          'razorpayOrderId': response.orderId,
          'razorpaySignature': response.signature,
        },
      };

      await Api.post('generateInvoice', payload);

      if (_pendingContext != null) {
        _subscriptionCreatedSuccessfully = true;
        notifyListeners();
        MySnackBar.showSnackBar(
          _pendingContext!,
          'Subscription created successfully!',
        );
        _pendingContext!.pushReplacement(AppRoutes.myOrderScreen);
      }
    } catch (e) {
      if (_pendingContext != null) {
        MySnackBar.showSnackBar(
          _pendingContext!,
          'Payment succeeded but finalizing failed.',
        );
      }
    } finally {
      _pendingOrderId = null;
      _pendingOrderNo = null;
      _pendingContext = null;
      notifyListeners();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    notifyListeners();
    if (_pendingContext != null) {
      MySnackBar.showSnackBar(
        _pendingContext!,
        'Payment failed: ${response.message ?? 'Please try again'}',
      );
    }
    _pendingOrderId = null;
    _pendingOrderNo = null;
    _pendingContext = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_pendingContext != null) {
      MySnackBar.showSnackBar(
        _pendingContext!,
        'External wallet selected: ${response.walletName}',
      );
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

  bool isLoadingPlans = false;
  bool isMorePlansLoading = false;
  List<AdminPlanModel> adminPlans = [];
  AdminPlanModel? selectedPlan;

  int currentPlanPage = 1;
  int totalPlanPages = 1;
  static const int _planPageSize = 10;

  Future<void> getAllActivePlans(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      currentPlanPage = 1;
      adminPlans.clear();
      isLoadingPlans = true;
      notifyListeners();
    } else {
      if (isLoadingPlans || isMorePlansLoading) return;
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

      if (response['success'] == true) {
        final List<dynamic> plansData = response['data']?['plans'] ?? [];
        final pagination = response['data']?['pagination'];

        if (pagination != null) {
          totalPlanPages = pagination['totalPages'] ?? 1;
        }

        final newPlans = plansData
            .map((e) => AdminPlanModel.fromJson(e))
            .toList();

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
