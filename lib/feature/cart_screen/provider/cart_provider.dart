import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';

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

  Future<void> fetchLatestCart(int userId) async {
    try {
      final response = await Api.post('getLatestCartByUserId', {
        "data": {"userId": userId},
      });
      print("Latest Cart Response: $response");

      if (response['success'] == true && response['data'] != null) {
        setCartFromApi(response['data']);
      } else {
        print(
          "Fetch Latest Cart failed: ${response['message'] ?? 'No message'}",
        );
      }
    } catch (e) {
      print("Fetch Latest Cart Exception: $e");
    }
  }

  void addItem(Product product) {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) + 1;
    } else {
      product.quantity = 1;
      _cartItems.add(product);
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0 && (_cartItems[index].quantity ?? 1) > 1) {
      _cartItems[index].quantity = (_cartItems[index].quantity ?? 1) - 1;
      notifyListeners();
    }
  }

  Future<void> addEditCart(Product product, int quantity, int userId) async {
    try {
      final existingIndex = _cartItems.indexWhere((p) => p.id == product.id);
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity = quantity;
      } else {
        product.quantity = quantity;
        _cartItems.add(product);
      }
      notifyListeners();

      final payload = {
        "data": {
          'id': _cartId ?? 0,
          "products": [
            {
              "productId": product.id,
              "variantId": product.variants.first.id,
              "quantity": quantity,
              "price": double.tryParse(product.variants.first.price) ?? 0.0,
            },
          ],
        },
      };

      final response = await Api.post('addEditCart', payload);
      print('Add/Edit Cart Response: $response');

      if (response['success'] == true && response['data'] != null) {
        _cartId = response['data']['id'] ?? _cartId;

        await fetchLatestCart(userId);
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
