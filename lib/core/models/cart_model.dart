import 'package:vd_customer_app/core/models/product_model.dart';

class Cart {
  final int id;
  final int userId;
  final String status;
  final double totalPrice;
  final List<CartDetail> cartDetails;

  Cart({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.cartDetails,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final details = (data['cartDetails'] as List? ?? [])
        .map((e) => CartDetail.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Cart(
      id: data['id'] ?? 0,
      userId: data['userId'] ?? 0,
      status: data['status'] ?? 'INACTIVE',
      totalPrice:
          double.tryParse(data['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      cartDetails: details,
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isEmpty => cartDetails.isEmpty;
}

class CartDetail {
  final int id;
  final int productId;
  int quantity;
  final double price;
  final double totalPrice;
  final Product product;

  CartDetail({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.product,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      totalPrice:
          double.tryParse(json['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }
}
