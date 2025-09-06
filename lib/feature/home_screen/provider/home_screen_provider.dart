import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/xd.dart';

class HomeScreenProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  List<Product> homeProducts = [];

  Future<void> fetchHomeProducts(Map<String, dynamic> requestData) async {
    log("HomeScreen fetch started");
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      log("Home API Response → $response");

      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        homeProducts = items.map((e) => Product.fromJson(e)).toList();

        for (var product in homeProducts) {
          for (var image in product.images) {
            if (image.rawImageUrl.isNotEmpty) {
              image.signedUrl = await generateSignedUrl(image.rawImageUrl);
            }
          }
        }
        message = response['message'] ?? "Products fetched successfully";
      } else {
        homeProducts = [];
        message = response['message'] ?? "Failed to fetch products";
      }
    } catch (e) {
      homeProducts = [];
      message = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
    notifyListeners();
  }
}
