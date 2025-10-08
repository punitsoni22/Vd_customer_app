class Order {
  final int orderId;
  final String status;
  final String orderConfirmedDate;

  final Cart cart;

  Order({
    required this.orderId,
    required this.status,
    required this.orderConfirmedDate,

    required this.cart,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final int id = (json['id'] ?? json['orderId'] ?? 0) as int;
    final String status = (json['status'] ?? '') as String;
    final String created =
        (json['createdOn'] ??
                json['orderConfirmedDate'] ??
                json['createdAt'] ??
                '')
            as String;

    final Map<String, dynamic> cartJson =
        (json['cart'] as Map<String, dynamic>?) ?? {};

    return Order(
      orderId: id,
      status: status,
      orderConfirmedDate: created,

      cart: Cart.fromJson(cartJson),
    );
  }

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "status": status,
    "orderConfirmedDate": orderConfirmedDate,
    "cart": cart.toJson(),
  };
}

class Cart {
  final int cartId;
  final List<CartDetail> cartDetails;

  Cart({required this.cartId, required this.cartDetails});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final int id = (json['id'] ?? json['cartId'] ?? 0) as int;

    final List<dynamic> detailsList =
        (json['cartDetails'] as List<dynamic>?) ?? [];

    return Cart(
      cartId: id,
      cartDetails: detailsList
          .map((e) => CartDetail.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "cartId": cartId,
    "cartDetails": cartDetails.map((e) => e.toJson()).toList(),
  };
}

class CartDetail {
  final String productName;
  final int quantity;
  final ProductImages productImages;

  CartDetail({
    required this.productName,
    required this.quantity,
    required this.productImages,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    String name = '';

    if (json['product'] is Map<String, dynamic>) {
      name = (json['product']['productName'] ?? '') as String;
    }

    final int qty = (json['quantity'] ?? 0) as int;

    final Map<String, dynamic> imagesJson =
        (json['productImages'] as Map<String, dynamic>?) ?? {};

    return CartDetail(
      productName: name,
      quantity: qty,
      productImages: ProductImages.fromJson(imagesJson),
    );
  }

  Map<String, dynamic> toJson() => {
    "productName": productName,
    "quantity": quantity,
    "productImages": productImages.toJson(),
  };
}

class ProductImages {
  final String imageUrl;
  String? signedUrl;

  ProductImages({required this.imageUrl, this.signedUrl});

  factory ProductImages.fromJson(Map<String, dynamic> json) {
    return ProductImages(imageUrl: (json['imageUrl'] ?? '') as String);
  }

  Map<String, dynamic> toJson() => {
    "imageUrl": imageUrl,
    "signedUrl": signedUrl,
  };
}
