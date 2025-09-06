import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/xd.dart';

class ProductDetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  List<Product> detailProducts = [];

  Future<void> fetchDetailProducts(Map<String, dynamic> requestData) async {
    log("HomeScreen fetch started");
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      log("DetailScreen API Response → $response");

      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        detailProducts = items.map((e) => Product.fromJson(e)).toList();

        // Generate signed URLs for each product image , forloop
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

  void clearMessage() {
    message = null;
    notifyListeners();
  }
}
