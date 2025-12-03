import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/helpers/auth_helper.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';
import 'package:vd_customer_app/core/routing/routes.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  Cart? get cart => _cart;

  List<CartDetail> get cartItems => _cart?.cartDetails ?? [];

  int? get cartId => _cart?.id;

  bool get isEmpty => cartItems.isEmpty;

  bool _isRemovingItem = false;
  bool get isRemovingItem => _isRemovingItem;

  bool _isUpdatingQuantity = false;
  bool get isUpdatingQuantity => _isUpdatingQuantity;

  //
  Map<String, int> _pendingQuantityChanges = {};
  Map<String, int> get pendingQuantityChanges => _pendingQuantityChanges;

  bool get hasPendingChanges => _pendingQuantityChanges.isNotEmpty;

  int getDisplayQuantity(CartDetail item) {
    final key = '${item.productId}_${item.variantId}';
    return _pendingQuantityChanges[key] ?? item.quantity;
  }

  void cancelQuantityChanges() {
    _pendingQuantityChanges.clear();
    notifyListeners();
  }

  Future<void> saveQuantityChanges(BuildContext context) async {
    if (!hasPendingChanges) return;

    try {
      _isUpdatingQuantity = true;
      notifyListeners();

      final productsPayload = cartItems.map((item) {
        final key = '${item.productId}_${item.variantId}';
        final newQuantity = _pendingQuantityChanges[key] ?? item.quantity;

        return {
          "productId": item.productId,
          "variantId": item.variantId,
          "quantity": newQuantity,
          "price": item.price,
        };
      }).toList();

      // double total = 0;
      // for (final p in productsPayload) {
      //   final q = (p['quantity'] is int)
      //       ? (p['quantity'] as int)
      //       : int.tryParse(p['quantity'].toString()) ?? 0;
      //   final pr = double.tryParse(p['price'].toString()) ?? 0.0;
      //   // total += pr * q;
      // }

      final payload = {
        "data": {
          if (cartId != null) 'id': cartId,
          "products": productsPayload,
          // "totalPrice": total,
        },
      };

      final response = await Api.post('addEditCart', payload);

      if (response['success'] == true && response['data'] != null) {
        _pendingQuantityChanges.clear();
        await setCartFromApi(response['data']);
        await fetchLatestCart(context);

        if (context.mounted) {
          MySnackBar.showSnackBar(context, "Cart updated successfully");
        }
      } else {
        final message = response['message'] ?? 'Failed to update cart';

        if (context.mounted) {
          MySnackBar.showSnackBar(context, message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        MySnackBar.showSnackBar(context, "Failed to save changes");
      }
    } finally {
      _isUpdatingQuantity = false;
      notifyListeners();
    }
  }

  Future<void> setCartFromApi(Map<String, dynamic> data) async {
    final cart = Cart.fromJson(data);

    if (cart.isActive && cart.cartDetails.isNotEmpty) {
      for (var detail in cart.cartDetails) {
        if (detail.product != null && detail.product!.images.isNotEmpty) {
          List<String> signedImages = [];
          for (var rawUrl in detail.product!.images) {
            if (rawUrl.isNotEmpty) {
              final signed = await generateSignedUrl(rawUrl);
              signedImages.add(signed);
            }
          }
          // Update the images list with signed URLs
          detail.product!.images.clear();
          detail.product!.images.addAll(signedImages);
        }
      }
      _cart = cart;
    } else {
      _cart = null;
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

  Future<void> fetchLatestCart(BuildContext context) async {
    try {
      final response = await Api.post('getLatestCartByUserId', {"data": {}});
      if (response['success'] == true && response['data'] != null) {
        await setCartFromApi(response['data']);
      } else {
        clearCart();
        final msg = response['message'] ?? 'Failed to fetch cart';
        try {
          final msgStr = msg.toString();
          if (msgStr.contains('401')) {
            await Prefs.clear(Prefs.keyAuthToken);
            await Prefs.clear(Prefs.keyUserId);
            await Prefs.clearAll();
            clearCart();
            context.goNamed(AppRoutes.loginScreen);
          }
        } catch (e) {
          print('Error during logout handling: $e');
        }
      }
    } catch (e) {
      print("DEBUG: Fetch Latest Cart Exception: $e");
    }
  }

  Future<Map<String, dynamic>> addItem(
    CartDetail item, {
    BuildContext? context,
  }) async {
    // Check login before allowing cart operations
    if (context != null &&
        !AuthHelper.requireLogin(
          context,
          message: 'Please login to add items to cart',
        )) {
      return {'success': false, 'message': 'Login required'};
    }

    try {
      final latest = await Api.post('getLatestCartByUserId', {});
      int cartIdToUse = 0;
      List existingDetails = [];

      if (latest['success'] == true && latest['data'] != null) {
        final data = latest['data'] as Map<String, dynamic>;
        final status = (data['status'] ?? '').toString().toUpperCase();
        if (status == 'ACTIVE') {
          cartIdToUse = data['id'] ?? 0;
          existingDetails = (data['cartDetails'] as List<dynamic>?) ?? [];
        } else {
          cartIdToUse = 0;
          existingDetails = [];
        }
      } else {
        cartIdToUse = 0;
        existingDetails = [];
      }
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
      productsPayload.add({
        'productId': item.productId,
        'variantId': item.variantId,
        'quantity': item.quantity,
        'price': item.price,
      });
      final payload = {
        'data': {'id': cartIdToUse, 'products': productsPayload},
      };
      final resp = await Api.post('addEditCart', payload);
      print('addItem API Response: $resp');

      if (resp['success'] == true && resp['data'] != null) {
        setCartFromApi(resp['data']);
        await fetchLatestCart(context!);
        return {'success': true, 'message': 'Added to cart successfully'};
      } else {
        final msg = resp['message'] ?? 'Failed to add to cart';
        print('addEditCart failed: $msg');
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

  Future<void> removeItem(BuildContext context, CartDetail item) async {
    // Check login before allowing cart operations
    if (!AuthHelper.requireLogin(
      context,
      message: 'Please login to manage cart',
    )) {
      return;
    }

    try {
      final cartDetailId = item.id;

      _isRemovingItem = true;
      notifyListeners();

      final response = await Api.post("deleteCartItem", {
        "data": {"cartDetailId": cartDetailId},
      });

      print("Delete Response: $response");

      if (response["success"] == true) {
        final message = response["message"] ?? "Item removed successfully";

        if (context.mounted) {
          MySnackBar.showSnackBar(context, message);
        }

        await fetchLatestCart(context);

        final newTotal = response["data"]?["totalPrice"];
        if (newTotal != null && double.tryParse(newTotal.toString()) == 0) {
          clearCart();
        }
      } else {
        final message = response["message"] ?? "Failed to remove item";

        if (context.mounted) {
          MySnackBar.showSnackBar(context, message);
        }

        print("Remove item failed: $message");
      }
    } catch (e) {
      print("RemoveItem error: $e");

      if (context.mounted) {
        MySnackBar.showSnackBar(
          context,
          "An error occurred while removing item",
        );
      }
    } finally {
      _isRemovingItem = false;
      notifyListeners();
    }
  }

  void increaseQuantity(CartDetail item) {
    final key = '${item.productId}_${item.variantId}';
    final currentQuantity = _pendingQuantityChanges[key] ?? item.quantity;
    _pendingQuantityChanges[key] = currentQuantity + 1;
    notifyListeners();
  }

  void decreaseQuantity(CartDetail item) {
    final key = '${item.productId}_${item.variantId}';
    final currentQuantity = _pendingQuantityChanges[key] ?? item.quantity;

    if (currentQuantity > 1) {
      _pendingQuantityChanges[key] = currentQuantity - 1;
      notifyListeners();
    }
  }

  Future<void> refreshCartFromBackend(BuildContext context) async {
    await fetchLatestCart(context);
  }

  Future<void> addEditCart(BuildContext context) async {
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
        await setCartFromApi(response['data']);
        await fetchLatestCart(context);
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
    (sum, item) => sum + ((item.price) * getDisplayQuantity(item)),
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
