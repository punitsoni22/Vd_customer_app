import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/signedurl.dart';

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  String? message;
  List<Product> products = [];

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  Future<void> getProducts(Map<String, dynamic> requestData, {bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      log("this is product api response: $response");
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
        _hasLoaded = true;
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
