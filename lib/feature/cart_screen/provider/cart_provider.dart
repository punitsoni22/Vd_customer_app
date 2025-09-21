import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];
  List get cartItems => _cartItems;

  void addItem(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeItem(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }
}
