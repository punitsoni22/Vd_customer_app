import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  int? _cartId;
  int? get cartId => _cartId;

  bool get isEmpty => _cartItems.isEmpty;

  void setCartFromApi(Map<String, dynamic> data) {
    _cartItems.clear();

    if (data != null) {
      _cartId = data['id'];

      if (data['status'] == 'ACTIVE') {
        final cartDetails = data['cartDetails'] as List? ?? [];

        _cartItems.addAll(
          cartDetails.map((item) {
            final productJson = item['product'] ?? {};
            final product = Product.fromJson(productJson);
            product.quantity = item['quantity'] ?? 1;
            return product;
          }),
        );
      }
    }

    notifyListeners();
  }

  Future<int?> getCurrentUserId() async {
    final userIdString = await Prefs.getString("user_id");
    if (userIdString == null) return null;
    return int.tryParse(userIdString);
  }

  Future<void> fetchLatestCart() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return;

      final response = await Api.post('getLatestCartByUserId', {
        "data": {"userId": userId},
      });
      print("Latest Cart Response: $response");

      if (response['success'] == true && response['data'] != null) {
        dynamic cartData = response['data'];

        if (cartData is String && cartData.isNotEmpty) {
          cartData = Map<String, dynamic>.from(jsonDecode(cartData));
        }

        setCartFromApi(cartData);
      } else {
        print(
          "Fetch Latest Cart failed: ${response['message'] ?? 'No message'}",
        );
      }
    } catch (e) {
      print("Fetch Latest Cart Exception: $e");
    }
  }

  Future<void> addItem(Product product) async {
    await fetchLatestCart();
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) + 1;
    } else {
      product.quantity = 1;
      _cartItems.add(product);
    }
    notifyListeners();
    await addEditCart();
  }

  Future<void> removeItem(Product product) async {
    await fetchLatestCart();
    _cartItems.removeWhere((p) => p.id == product.id);
    notifyListeners();
    await addEditCart();
  }

  Future<void> increaseQuantity(Product product) async {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) + 1;
      notifyListeners();
      await addEditCart();
    }
  }

  Future<void> decreaseQuantity(Product product) async {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      if ((_cartItems[index].quantity ?? 1) > 1) {
        _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) - 1;
        notifyListeners();
        await addEditCart();
      } else {
        await removeItem(product);
      }
    }
  }

  Future<void> addEditCart() async {
    try {
      final productsPayload = _cartItems.map((p) {
        return {
          "productId": p.id,
          "variantId": p.variants.first.id,
          "quantity": p.quantity,
          "price": double.tryParse(p.variants.first.price) ?? 0.0,
        };
      }).toList();

      final payload = {
        "data": {
          if (_cartId != null) 'id': _cartId,
          "products": productsPayload,
        },
      };

      final response = await Api.post('addEditCart', payload);
      print('Add/Edit Cart Response: $response');

      if (response['success'] == true && response['data'] != null) {
        _cartId = response['data']['id'] ?? _cartId;
        await fetchLatestCart();
      } else {
        print('Cart API error: ${response['message'] ?? 'No message'}');
      }
    } catch (e) {
      print('Add/Edit Cart Exception: $e');
    }
  }

  double get subtotal => _cartItems.fold<double>(
    0,
    (sum, item) =>
        sum +
        ((double.tryParse(item.variants.first.price) ?? 0.0) *
            (item.quantity ?? 1)),
  );
}
