import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  Cart? get cart => _cart;

  List<CartDetail> get cartItems => _cart?.cartDetails ?? [];

  int? get cartId => _cart?.id;

  bool get isEmpty => cartItems.isEmpty;

  void setCartFromApi(Map<String, dynamic> data) {
    if (data == null) return;

    final cart = Cart.fromJson(data);

    if (!cart.isActive) return;
    if (cart.cartDetails.isEmpty) return;

    if (_cart == null) {
      _cart = cart;
    } else {
      for (var item in cart.cartDetails) {
        final i = _cart!.cartDetails.indexWhere(
          (p) => p.productId == item.productId && p.variantId == item.variantId,
        );
        if (i >= 0) {
          _cart!.cartDetails[i].quantity = max(
            _cart!.cartDetails[i].quantity,
            item.quantity,
          );
        } else {
          _cart!.cartDetails.add(item);
        }
      }
    }
    notifyListeners();
  }

  Future<int?> getCurrentUserId() async {
    final userIdString = await Prefs.getString("user_id");
    if (userIdString == null) {
      debugPrint("DEBUG: No user_id found in prefs");
      return null;
    }
    final id = int.tryParse(userIdString);
    debugPrint("DEBUG: Current userId = $id");
    return id;
  }

  Future<void> fetchLatestCart() async {
    try {
      final userId = await getCurrentUserId();
      print("DEBUG: Current userId = $userId");

      if (userId == null) return;

      final response = await Api.post('getLatestCartByUserId', {
        "data": {"userId": userId},
      });

      print("DEBUG: API Response = $response");

      if (response['success'] == true && response['data'] != null) {
        setCartFromApi(response['data']);
      } else {
        print(
          "DEBUG: Fetch Latest Cart failed: ${response['message'] ?? 'No message'}",
        );
      }
    } catch (e) {
      print("DEBUG: Fetch Latest Cart Exception: $e");
    }
  }

  Future<void> addItem(CartDetail item) async {
    final index = cartItems.indexWhere(
      (p) => p.productId == item.productId && p.variantId == item.variantId,
    );
    if (index >= 0) {
      cartItems[index].quantity += 1;
    } else {
      item.quantity = 1;
      cartItems.add(item);
    }
    notifyListeners();
    await addEditCart();
  }

  Future<void> removeItem(CartDetail item) async {
    cartItems.removeWhere(
      (p) => p.productId == item.productId && p.variantId == item.variantId,
    );
    notifyListeners();
    await addEditCart();
  }

  Future<void> increaseQuantity(CartDetail item) async {
    final index = cartItems.indexWhere(
      (p) => p.productId == item.productId && p.variantId == item.variantId,
    );
    if (index >= 0) {
      cartItems[index].quantity += 1;
      notifyListeners();
      await addEditCart();
    }
  }

  Future<void> decreaseQuantity(CartDetail item) async {
    final index = cartItems.indexWhere(
      (p) => p.productId == item.productId && p.variantId == item.variantId,
    );
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
        notifyListeners();
        await addEditCart();
      } else {
        await removeItem(item);
      }
    }
  }

  Future<void> refreshCartFromBackend() async {
    await fetchLatestCart();
  }

  Future<void> addEditCart() async {
    try {
      final productsPayload = cartItems.map((p) {
        return {
          "productId": p.productId,
          "variantId": p.variantId,
          "quantity": p.quantity,
          "price": p.price,
        };
      }).toList();

      final payload = {
        "data": {if (cartId != null) 'id': cartId, "products": productsPayload},
      };

      final response = await Api.post('addEditCart', payload);
      print('Add/Edit Cart Response: $response');

      if (response['success'] == true && response['data'] != null) {
        _cart = _cart?.copyWith(id: response['data']['id'] ?? cartId);
      } else {
        print('Cart API error: ${response['message'] ?? 'No message'}');
      }
    } catch (e) {
      print('Add/Edit Cart Exception: $e');
    }
  }

  double get subtotal => cartItems.fold<double>(
    0,
    (sum, item) => sum + ((item.price) * (item.quantity)),
  );
}

extension CartCopy on Cart {
  Cart copyWith({
    int? id,
    int? userId,
    String? status,
    double? totalPrice,
    List<CartDetail>? cartDetails,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdOn: createdOn,
      createdBy: createdBy,
      updatedOn: updatedOn,
      updatedBy: updatedBy,
      isDeleted: isDeleted,
      deletedOn: deletedOn,
      deletedBy: deletedBy,
      cartDetails: cartDetails ?? this.cartDetails,
    );
  }
}
