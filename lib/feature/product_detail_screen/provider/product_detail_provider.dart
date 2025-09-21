import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/xd.dart';

class ProductDetailProvider extends ChangeNotifier {
  // List state (for "More Popular Products")
  bool isListLoading = false;
  List<Product> detailProducts = [];
  String? listMessage;

  // Detail state (for the hero product)
  bool isDetailLoading = false;
  Product? specificProduct;
  String? detailMessage;

  // --- DETAIL STATE ---
  int selectedVariantIndex = 0;

  void _resetSelection() {
    selectedVariantIndex = 0;
  }

  void selectVariantByIndex(int i) {
    if (specificProduct == null) return;
    if (i < 0 || i >= specificProduct!.variants.length) return;
    selectedVariantIndex = i;
    notifyListeners();
  }

  void selectVariantByMl(int ml) {
    if (specificProduct == null) return;
    final idx = specificProduct!.variants.indexWhere((v) => v.quantityInMl == ml);
    if (idx != -1) {
      selectedVariantIndex = idx;
      notifyListeners();
    }
  }

  String get selectedPriceLabel {
    if (specificProduct == null || specificProduct!.variants.isEmpty) return '₹ 0';
    final price = double.tryParse(specificProduct!.variants[selectedVariantIndex].price) ?? 0.0;
    return '₹ ${price.toInt()}';
  }

  List<String> get variantVolumesMl {
    if (specificProduct == null) return [];
    return specificProduct!.variants.map((v) => v.quantityInMl).toList();
  }

  // -------- LIST: /getAllProducts ----------
  Future<void> fetchDetailProducts(Map<String, dynamic> requestData) async {
    log("fetchDetailProducts started");
    isListLoading = true;
    listMessage = null;
    notifyListeners();

    try {
      final response = await Api.post('getAllProducts', requestData);
      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        detailProducts = items.map((e) => Product.fromJson(e)).toList();

        // sign image URLs if present
        for (var p in detailProducts) {
          for (var img in p.images) {
            final raw = img.rawImageUrl;
            if (raw != null && raw.isNotEmpty) {
              img.signedUrl = await generateSignedUrl(raw);
            }
          }
        }
        listMessage = response['message'] ?? "Products fetched successfully";
      } else {
        detailProducts = [];
        listMessage = response['message'] ?? "Failed to fetch products";
      }
    } catch (e) {
      detailProducts = [];
      listMessage = "Exception: $e";
    }

    isListLoading = false;
    notifyListeners();
  }

  // -------- DETAIL: /getSpecificProducts ----------
  Future<void> fetchSpecificProduct(int productId) async {
    log("fetchSpecificProduct($productId) started");
    isDetailLoading = true;
    specificProduct = null;
    detailMessage = null;
    notifyListeners();

    try {
      final body = {
        "data": {"productId": productId},
      };
      final response = await Api.post('getSpecificProducts', body);

      final data = response['data'];
      if (data != null) {
        final p = Product.fromJson(data);
        for (var img in p.images) {
          final raw = img.rawImageUrl;
          if (raw != null && raw.isNotEmpty) {
            img.signedUrl = await generateSignedUrl(raw);
          }
        }

        specificProduct = p;
      } else {
        detailMessage = "No product found";
      }
    } catch (e) {
      detailMessage = "Exception: $e";
    }

    isDetailLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    listMessage = null;
    detailMessage = null;
    notifyListeners();
  }
}
