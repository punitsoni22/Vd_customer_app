import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  Cart? get cart => _cart;

  List<CartDetail> get cartItems => _cart?.cartDetails ?? [];

  int? get cartId => _cart?.id;

  bool get isEmpty => cartItems.isEmpty;

  void setCartFromApi(Map<String, dynamic> data) {
    // 'data' is non-nullable Map coming from API; no null check needed
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

  Future<Map<String, dynamic>> addItem(
    CartDetail item, {
    BuildContext? context,
  }) async {
    try {
      // Step 1: fetch latest cart from backend
      final latest = await Api.post('getLatestCartByUserId', {});

      int cartIdToUse = 0;
      List existingDetails = [];

      if (latest['success'] == true && latest['data'] != null) {
        final data = latest['data'] as Map<String, dynamic>;
        // use existing cart id only if status is ACTIVE
        final status = (data['status'] ?? '').toString().toUpperCase();
        if (status == 'ACTIVE') {
          cartIdToUse = data['id'] ?? 0;
          existingDetails = (data['cartDetails'] as List<dynamic>?) ?? [];
        } else {
          // non-active cart -> create new (id 0)
          cartIdToUse = 0;
          existingDetails = [];
        }
      } else {
        // no cart exists -> create new with id = 0
        cartIdToUse = 0;
        existingDetails = [];
      }

      // Step 2: build products payload from existing details + new item
      final List<Map<String, dynamic>> productsPayload = [];

      for (final d in existingDetails) {
        try {
          productsPayload.add({
            'productId': d['productId'],
            'variantId': d['variantId'],
            'quantity': d['quantity'],
            'price': d['price'],
          });
        } catch (_) {}
      }

      // Append new item (backend will decide how to merge/update quantities)
      productsPayload.add({
        'productId': item.productId,
        'variantId': item.variantId,
        'quantity': item.quantity,
        'price': item.price,
      });

      // Step 3: compute totalPrice (sum of price * quantity)
      double total = 0;
      for (final p in productsPayload) {
        final q = (p['quantity'] is int)
            ? (p['quantity'] as int)
            : int.tryParse(p['quantity'].toString()) ?? 0;
        final pr = double.tryParse(p['price'].toString()) ?? 0.0;
        total += pr * q;
      }

      final payload = {
        'data': {
          'id': cartIdToUse,
          'products': productsPayload,
          'totalPrice': total,
        },
      };

      // Step 4: call addEditCart API
      final resp = await Api.post('addEditCart', payload);
      print('addItem API Response: $resp');

      if (resp['success'] == true && resp['data'] != null) {
        // Update local cart from backend response
        setCartFromApi(resp['data']);
        return {'success': true, 'message': 'Added to cart successfully'};
      } else {
        // API returned failure - print/log and return message
        final msg = resp['message'] ?? 'Failed to add to cart';
        print('addEditCart failed: $msg');

        // If server returned 401 (unauthorized), clear prefs, clear cart and navigate to login
        try {
          final msgStr = msg.toString();
          if (msgStr.contains('401')) {
            // clear stored auth and user id
            await Prefs.clear(Prefs.keyAuthToken);
            await Prefs.clear(Prefs.keyUserId);
            await Prefs.clearAll();

            // clear local cart state
            clearCart();

            // navigate to login/auth screen if context provided
            if (context != null) {
              context.goNamed(AppRoutes.loginScreen);
            }
          }
        } catch (e) {
          // ignore errors during logout handling but log if needed
          print('Error during logout handling: $e');
        }

        return {'success': false, 'message': msg};
      }
    } catch (e) {
      print('addItem exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> removeItem(CartDetail item) async {
    try {
      final cartDetailId = item.id;

      cartItems.removeWhere(
        (p) => p.productId == item.productId && p.variantId == item.variantId,
      );
      notifyListeners();

      final response = await Api.post("deleteCartItem", {
        "data": {"cartDetailId": cartDetailId},
      });

      print("Delete Response: $response");

      final newTotal = response["data"]?["totalPrice"];
      if (newTotal != null) {
        if (double.tryParse(newTotal.toString()) == 0) {
          clearCart();
        } else {
          _cart = _cart?.copyWith(
            totalPrice: double.tryParse(newTotal.toString()),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print(" removeItem error: $e");
    }
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

  void clearCart() {
    _cart?.cartDetails.clear();

    _cart = null;

    notifyListeners();
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
