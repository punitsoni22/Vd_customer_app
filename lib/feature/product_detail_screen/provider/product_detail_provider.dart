import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/signedurl.dart';

class ProductDetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  List<Product> detailProducts = [];

  Product? selectedProduct;

  Future<void> fetchDetailProducts(Map<String, dynamic> requestData) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        detailProducts = items.map((e) => Product.fromJson(e)).toList();
        for (var product in detailProducts) {
          for (var image in product.images) {
            if (image.rawImageUrl.isNotEmpty) {
              image.signedUrl = await generateSignedUrl(image.rawImageUrl);
            }
          }
        }
        message = response['message'] ?? "Products fetched successfully";
      } else {
        detailProducts = [];
        message = response['message'] ?? "Failed to fetch products";
      }
    } catch (e) {
      detailProducts = [];
      message = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSpecificProduct(int productId) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getSpecificProducts', {
        "data": {"productId": productId},
      });
      if (response['success'] == true && response['data'] != null) {
        selectedProduct = Product.fromJson(response['data']);

        for (var image in selectedProduct!.images) {
          if (image.rawImageUrl.isNotEmpty) {
            image.signedUrl = await generateSignedUrl(image.rawImageUrl);
          }
        }

        message = response['message'] ?? "Product fetched successfully";
      } else {
        selectedProduct = null;
        message = response['message'] ?? "Failed to fetch product";
      }
    } catch (e) {
      selectedProduct = null;
      message = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  bool isCheckingDelivery = false;
  bool? isDeliverable;
  String? deliveryMessage;

  Future<void> checkDeliveryPincode(String pinCode, int productId) async {
    isCheckingDelivery = true;
    isDeliverable = null;
    deliveryMessage = null;
    notifyListeners();

    try {
      final response = await Api.post('checkDeliveryPincode', {
        "data": {"pinCode": pinCode, "productId": productId},
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
        isDeliverable = data['isDeliverable'] == true;
        deliveryMessage =
            data['message'] ??
            (isDeliverable!
                ? "Delivery is available."
                : "Delivery not available.");
      } else {
        isDeliverable = false;
        deliveryMessage =
            response['message'] ??
            response['dataResponse']?['description'] ??
            "Unable to verify delivery.";
      }
    } catch (e) {
      log("checkDeliveryPincode error: $e");
      isDeliverable = false;
      deliveryMessage = "Error verifying delivery pincode.";
    }

    isCheckingDelivery = false;
    notifyListeners();
  }

  void clearDeliveryStatus() {
    isDeliverable = null;
    deliveryMessage = null;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
    notifyListeners();
  }
}
