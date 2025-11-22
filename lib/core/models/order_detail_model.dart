class OrderDetailModel {
  final int id;
  final int userId;
  final int cartId;
  final int addressId;
  final String totalAmount;
  final String status;
  final String discountAmount;
  final String createdOn;
  final AddressDetail address;
  final CartDetail cart;

  OrderDetailModel({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.addressId,
    required this.totalAmount,
    required this.status,
    required this.discountAmount,
    required this.createdOn,
    required this.address,
    required this.cart,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      cartId: json['cartId'] ?? 0,
      addressId: json['addressId'] ?? 0,
      totalAmount: json['totalAmount'] ?? '0.00',
      status: json['status'] ?? '',
      discountAmount: json['discountAmount'] ?? '0.00',
      createdOn: json['createdOn'] ?? '',
      address: AddressDetail.fromJson(json['address'] ?? {}),
      cart: CartDetail.fromJson(json['cart'] ?? {}),
    );
  }
}

class AddressDetail {
  final int id;
  final String fullAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  AddressDetail({
    required this.id,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      id: json['id'] ?? 0,
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}

class CartDetail {
  final int id;
  final String totalPrice;
  final List<CartDetailItem> cartDetails;

  CartDetail({
    required this.id,
    required this.totalPrice,
    required this.cartDetails,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'] ?? 0,
      totalPrice: json['totalPrice'] ?? '0.00',
      cartDetails:
          (json['cartDetails'] as List<dynamic>?)
              ?.map((e) => CartDetailItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CartDetailItem {
  final int id;
  final int quantity;
  final String price;
  final String totalPrice;
  final ProductDetail product;
  final ProductVariantDetail productVariants;

  CartDetailItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.product,
    required this.productVariants,
  });

  factory CartDetailItem.fromJson(Map<String, dynamic> json) {
    return CartDetailItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0.00',
      totalPrice: json['totalPrice'] ?? '0.00',
      product: ProductDetail.fromJson(json['product'] ?? {}),
      productVariants: ProductVariantDetail.fromJson(
        json['productVariants'] ?? {},
      ),
    );
  }
}

class ProductDetail {
  final int id;
  final String productName;
  final String description;
  final List<ProductImage> images;

  ProductDetail({
    required this.id,
    required this.productName,
    required this.description,
    required this.images,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProductImage {
  final String imageUrl;
  String? signedUrl;

  ProductImage({required this.imageUrl, this.signedUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(imageUrl: json['imageUrl'] ?? '');
  }
}

class ProductVariantDetail {
  final int id;
  final String price;
  final int quantityinml;

  ProductVariantDetail({
    required this.id,
    required this.price,
    required this.quantityinml,
  });

  factory ProductVariantDetail.fromJson(Map<String, dynamic> json) {
    return ProductVariantDetail(
      id: json['id'] ?? 0,
      price: json['price'] ?? '0.00',
      quantityinml: json['quantityinml'] ?? 0,
    );
  }
}
