import 'package:vd_customer_app/core/models/product_model.dart';

class Cart {
  final int id;
  final int userId;
  final String status;
  final double totalPrice;
  final String? createdOn;
  final String? createdBy;
  final String? updatedOn;
  final String? updatedBy;
  final int isDeleted;
  final String? deletedOn;
  final String? deletedBy;
  final List<CartDetail> cartDetails;

  Cart({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    required this.isDeleted,
    this.deletedOn,
    this.deletedBy,
    this.cartDetails = const [],
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final details = (json['cartDetails'] as List? ?? [])
        .map((e) => CartDetail.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Cart(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      status: json['status'] ?? 'INACTIVE',
      totalPrice: _parseDouble(json['totalPrice']),
      createdOn: json['createdon']?.toString(),
      createdBy: json['createdby']?.toString(),
      updatedOn: json['updatedon']?.toString(),
      updatedBy: json['updatedby']?.toString(),
      isDeleted: json['isdeleted'] ?? 0,
      deletedOn: json['deletedon']?.toString(),
      deletedBy: json['deletedby']?.toString(),
      cartDetails: details,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isEmpty => cartDetails.isEmpty;
}

class CartDetail {
  final int id;
  final int productId;
  final int variantId;
  int quantity;
  final double price;
  final CartProduct? product;

  CartDetail({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.price,
    this.product,
  });

  double get totalPrice => price * quantity;

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      variantId: json['variantId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: Cart._parseDouble(json['price']),
      product: json['product'] != null
          ? CartProduct.fromJson(Map<String, dynamic>.from(json['product']))
          : null,
    );
  }

  factory CartDetail.fromProduct(Product product) {
    final price = double.tryParse(product.variants.first.price) ?? 0.0;
    return CartDetail(
      id: 0,
      productId: product.id,
      variantId: product.variants.first.id,
      quantity: 1,
      price: price,
      product: CartProduct(
        id: product.id,
        productName: product.productName,
        images: product.images.map((e) => e.signedUrl ?? '').toList(),
      ),
    );
  }
}

class CartProduct {
  final int id;
  final String productName;
  final List<String> images;

  CartProduct({
    required this.id,
    required this.productName,
    required this.images,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
