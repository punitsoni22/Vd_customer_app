import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  List<Product> products = [];

  Future<void> getProducts(Map<String, dynamic> requestData) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        products = items.map((e) => Product.fromJson(e)).toList();
        for (var product in products) {
          for (var image in product.images) {
            if (image.rawImageUrl.isNotEmpty) {
              image.signedUrl = await generateSignedUrl(image.rawImageUrl);
            }
          }
        }
        message = response['message'] ?? "Products fetched successfully";
      } else {
        products = [];
        message = response['message'] ?? "Failed to fetch products";
      }
    } catch (e) {
      products = [];
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
