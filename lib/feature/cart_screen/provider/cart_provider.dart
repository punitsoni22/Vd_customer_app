import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/helpers/auth_helper.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';
import 'package:vd_customer_app/core/routing/routes.dart';

import '../../auth_screen/provider/auth_provider.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  Cart? get cart => _cart;

  List<CartDetail> get cartItems => _cart?.cartDetails ?? [];

  int get totalItemsCount {
    int sum = 0;
    for (final item in cartItems) {
      sum += item.quantity;
    }
    return sum;
  }

  int? get cartId => _cart?.id;

  bool get isEmpty => cartItems.isEmpty;

  // Track removing items by ID to isolate state
  final Set<int> _removingItemIds = {};
  bool isItemBeingRemoved(int cartDetailId) =>
      _removingItemIds.contains(cartDetailId);

  bool _isUpdatingQuantity = false;
  bool get isUpdatingQuantity => _isUpdatingQuantity;

  // Track quantity changes by CartDetail ID for uniqueness
  Map<int, int> _pendingQuantityChanges = {};
  Map<int, int> get pendingQuantityChanges => _pendingQuantityChanges;

  bool get hasPendingChanges => _pendingQuantityChanges.isNotEmpty;

  Timer? _autoSaveTimer;

  int getDisplayQuantity(CartDetail item) {
    return _pendingQuantityChanges[item.id] ?? item.quantity;
  }

  void cancelQuantityChanges() {
    _pendingQuantityChanges.clear();
    notifyListeners();
  }

  Future<void> saveQuantityChanges(BuildContext context) async {
    if (!hasPendingChanges) return;
    if (_isUpdatingQuantity) return;

    try {
      _isUpdatingQuantity = true;
      notifyListeners();

      final productsPayload = cartItems.map((item) {
        final newQuantity = _pendingQuantityChanges[item.id] ?? item.quantity;

        return {
          "productId": item.productId,
          "variantId": item.variantId,
          "quantity": newQuantity,
          "price": item.price,
        };
      }).toList();

      final payload = {
        "data": {if (cartId != null) 'id': cartId, "products": productsPayload},
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
            // ignore: use_build_context_synchronously
            try {
              // ignore: depend_on_referenced_packages
              context.read<AuthProvider>().clearToken();
            } catch (_) {}
            context.goNamed(AppRoutes.bottomBarScreen);
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
            clearCart();
            if (context != null) {
              try {
                context.read<AuthProvider>().clearToken();
              } catch (_) {}
              context.goNamed(AppRoutes.bottomBarScreen);
            }
          }
        } catch (e) {
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

      _pendingQuantityChanges.remove(cartDetailId);
      _autoSaveTimer?.cancel();
      _removingItemIds.add(cartDetailId);
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
      _removingItemIds.remove(item.id);
      if (context.mounted && hasPendingChanges && !_isUpdatingQuantity) {
        _scheduleAutoSave(context);
      }
      notifyListeners();
    }
  }

  void _scheduleAutoSave(BuildContext context) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!context.mounted) return;
      await saveQuantityChanges(context);
    });
  }

  void increaseQuantity(CartDetail item, {BuildContext? context}) {
    final currentQuantity = _pendingQuantityChanges[item.id] ?? item.quantity;
    _pendingQuantityChanges[item.id] = currentQuantity + 1;
    notifyListeners();
    if (context != null) _scheduleAutoSave(context);
  }

  void decreaseQuantity(CartDetail item, {BuildContext? context}) {
    if (_removingItemIds.contains(item.id)) return;

    final currentQuantity = _pendingQuantityChanges[item.id] ?? item.quantity;

    if (currentQuantity > 1) {
      _pendingQuantityChanges[item.id] = currentQuantity - 1;
      notifyListeners();
      if (context != null) _scheduleAutoSave(context);
      return;
    }

    _pendingQuantityChanges.remove(item.id);
    _autoSaveTimer?.cancel();
    notifyListeners();

    if (context != null) {
      removeItem(context, item);
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

  Future<void> clearCartOnBackend(BuildContext context) async {
    final currentCartId = cartId;
    final currentItems = List<CartDetail>.from(cartItems);

    clearCart();

    if (currentCartId == null) return;

    try {
      final response = await Api.post('addEditCart', {
        "data": {"id": currentCartId, "products": []},
      });

      if (response['success'] == true) {
        await fetchLatestCart(context);
        return;
      }
    } catch (_) {}

    for (final item in currentItems) {
      try {
        await Api.post("deleteCartItem", {
          "data": {"cartDetailId": item.id},
        });
      } catch (_) {}
    }

    await fetchLatestCart(context);
    clearCart();
  }

  void clearCart() {
    _cart?.cartDetails.clear();

    _cart = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
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
