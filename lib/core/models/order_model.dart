class Order {
  final int orderId;
  final String status;
  final String orderConfirmedDate;
  final double totalAmount;
  final double discountAmount;
  final Cart cart;
  final Invoice? invoice;

  Order({
    required this.orderId,
    required this.status,
    required this.orderConfirmedDate,
    required this.totalAmount,
    required this.discountAmount,
    required this.cart,
    this.invoice,
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
    final totalAmount =
        double.tryParse((json['totalAmount'] ?? '0').toString()) ?? 0.0;
    final discountAmount =
        double.tryParse((json['discountAmount'] ?? '0').toString()) ?? 0.0;

    final Map<String, dynamic> cartJson =
        (json['cart'] as Map<String, dynamic>?) ?? {};

    final Map<String, dynamic>? invoiceJson =
        (json['invoice'] as Map<String, dynamic>?);

    return Order(
      orderId: id,
      status: status,
      orderConfirmedDate: created,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      cart: Cart.fromJson(cartJson),
      invoice: invoiceJson != null ? Invoice.fromJson(invoiceJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "status": status,
    "orderConfirmedDate": orderConfirmedDate,
    "totalAmount": totalAmount,
    "discountAmount": discountAmount,
    "cart": cart.toJson(),
    "invoice": invoice?.toJson(),
  };
}

class Cart {
  final int cartId;
  final double totalPrice;
  final List<CartDetail> cartDetails;

  Cart({required this.cartId, required this.totalPrice, required this.cartDetails});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final int id = (json['id'] ?? json['cartId'] ?? 0) as int;
    final totalPrice =
        double.tryParse((json['totalPrice'] ?? '0').toString()) ?? 0.0;

    final List<dynamic> detailsList =
        (json['cartDetails'] as List<dynamic>?) ?? [];

    return Cart(
      cartId: id,
      totalPrice: totalPrice,
      cartDetails: detailsList
          .map((e) => CartDetail.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "cartId": cartId,
    "totalPrice": totalPrice,
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

class Invoice {
  final int id;
  final String invoiceNumber;
  final String filePath;
  String? signedUrl;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.filePath,
    this.signedUrl,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: (json['id'] ?? 0) as int,
      invoiceNumber: (json['invoiceNumber'] ?? '') as String,
      filePath: (json['filePath'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoiceNumber": invoiceNumber,
    "filePath": filePath,
    "signedUrl": signedUrl,
  };
}
