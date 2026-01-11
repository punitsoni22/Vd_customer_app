import 'dart:convert';

class SubscriptionDetailModel {
  final int id;
  final String customerName;
  final String deliveryFrequencyType;
  final String subscriptionType;
  final DateTime startDate;
  final DateTime endDate;
  final int addressId;
  final int status;
  final List<SubscriptionProductDetail> products;

  SubscriptionDetailModel copyWith({
    List<SubscriptionProductDetail>? products,
  }) {
    return SubscriptionDetailModel(
      id: id,
      customerName: customerName,
      deliveryFrequencyType: deliveryFrequencyType,
      subscriptionType: subscriptionType,
      startDate: startDate,
      endDate: endDate,
      addressId: addressId,
      status: status,
      products: products ?? this.products,
    );
  }

  SubscriptionDetailModel({
    required this.id,
    required this.customerName,
    required this.deliveryFrequencyType,
    required this.subscriptionType,
    required this.startDate,
    required this.endDate,
    required this.addressId,
    required this.status,
    required this.products,
  });

  factory SubscriptionDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse productIds JSON string
    List<SubscriptionProductDetail> productsList = [];

    // New API: 'products' is a list of detailed product objects
    if (json['products'] != null && json['products'] is List) {
      productsList = (json['products'] as List)
          .map((e) => SubscriptionProductDetail.fromApiProductJson(e))
          .toList();
    } else if (json['productIds'] != null && json['productIds'] is String) {
      try {
        final decoded = jsonDecode(json['productIds'] as String);
        if (decoded is List) {
          productsList = decoded
              .map((e) => SubscriptionProductDetail.fromProductIdJson(e))
              .toList();
        }
      } catch (_) {
      }
    }

    return SubscriptionDetailModel(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? '',
      deliveryFrequencyType: json['deliveryFrequencyType'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toString()),
      addressId: json['addressId'] ?? 0,
      status: json['status'] ?? 0,
      products: productsList,
    );
  }
}

class SubscriptionProductDetail {
  final int productId;
  final int variantId;
  final int quantity;
  final String? productName;
  final String? imageUrl;
  final String? price;
  final int? quantityInMl;
  final String? signedUrl;

  SubscriptionProductDetail({
    required this.productId,
    required this.variantId,
    required this.quantity,
    this.productName,
    this.imageUrl,
    this.price,
    this.quantityInMl,
    this.signedUrl,
  });

  factory SubscriptionProductDetail.fromProductIdJson(
    Map<String, dynamic> json,
  ) {
    return SubscriptionProductDetail(
      productId: json['productId'] ?? 0,
      variantId: json['variantId'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }

  SubscriptionProductDetail copyWith({
    int? productId,
    int? variantId,
    int? quantity,
    String? productName,
    String? imageUrl,
    String? price,
    int? quantityInMl,
    String? signedUrl,
  }) {
    return SubscriptionProductDetail(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantityInMl: quantityInMl ?? this.quantityInMl,
      signedUrl: signedUrl ?? this.signedUrl,
    );
  }

  factory SubscriptionProductDetail.fromApiProductJson(
    Map<String, dynamic> json,
  ) {
    final selectedVariant = json['selectedVariant'] ?? {};
    String? imageUrl;
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      if (first is Map && first['imageUrl'] != null) {
        imageUrl = first['imageUrl'] as String;
      }
    }

    // Fallback: check productImages map
    if (imageUrl == null &&
        json['productImages'] != null &&
        json['productImages'] is Map) {
      final productImages = json['productImages'] as Map<String, dynamic>;
      imageUrl = productImages['imageUrl'] as String?;
    }

    // Fallback: direct imageUrl
    if (imageUrl == null && json['imageUrl'] != null) {
      imageUrl = json['imageUrl'] as String?;
    }

    return SubscriptionProductDetail(
      productId: json['productId'] ?? 0,
      variantId: selectedVariant['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productName: json['productName'] != null
          ? json['productName'] as String
          : null,
      imageUrl: imageUrl,
      price: selectedVariant['price'] != null
          ? selectedVariant['price'].toString()
          : null,
      quantityInMl: selectedVariant['quantityinml'] is int
          ? selectedVariant['quantityinml'] as int
          : (selectedVariant['quantityinml'] is String
                ? int.tryParse(selectedVariant['quantityinml'])
                : null),
    );
  }
}
