import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/services/api_services.dart';

class AddressModel {
  final int id;
  final String fullAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class SubscriptionProvider extends ChangeNotifier {
  bool _subscriptionCreatedSuccessfully = false;
  bool get subscriptionCreatedSuccessfully => _subscriptionCreatedSuccessfully;

  void clearSuccessFlag() {
    _subscriptionCreatedSuccessfully = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createOrEditSubscription(
    Map<String, dynamic> payload,
  ) async {
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

  Future<void> getAllAddresses() async {
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
}
