class AdminPlanModel {
  final int id;
  final String planName;
  final String planDescription;
  final String planUniqueCode;
  final String deliveryFrequencyType;
  final List<String> deliveryDays;
  final String subscriptionType;
  final String totalPrice;
  final String discountPercentage;
  final String finalPrice;
  final List<PlanProduct> products;

  AdminPlanModel({
    required this.id,
    required this.planName,
    required this.planDescription,
    required this.planUniqueCode,
    required this.deliveryFrequencyType,
    required this.deliveryDays,
    required this.subscriptionType,
    required this.totalPrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.products,
  });

  factory AdminPlanModel.fromJson(Map<String, dynamic> json) {
    // Parse deliveryDays from string JSON array
    List<String> days = [];
    if (json['deliveryDays'] != null) {
      try {
        final dynamic daysData = json['deliveryDays'];
        if (daysData is String) {
          // Parse string like "[\"Mon\",\"Wed\",\"Fri\"]"
          final decoded = daysData
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',');
          days = decoded.map((e) => e.trim()).toList();
        } else if (daysData is List) {
          days = List<String>.from(daysData);
        }
      } catch (e) {
        days = [];
      }
    }

    return AdminPlanModel(
      id: json['id'] ?? 0,
      planName: json['planName'] ?? '',
      planDescription: json['planDescription'] ?? '',
      planUniqueCode: json['planUniqueCode'] ?? '',
      deliveryFrequencyType: json['deliveryFrequencyType'] ?? '',
      deliveryDays: days,
      subscriptionType: json['subscriptionType'] ?? '',
      totalPrice: json['totalPrice']?.toString() ?? '0',
      discountPercentage: json['discountPercentage']?.toString() ?? '0',
      finalPrice: json['finalPrice']?.toString() ?? '0',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => PlanProduct.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanProduct {
  final int productId;
  final String productName;
  final String? description;
  final PlanVariant selectedVariant;
  final List<PlanProductImage> images;
  final int quantity;

  PlanProduct({
    required this.productId,
    required this.productName,
    this.description,
    required this.selectedVariant,
    required this.images,
    required this.quantity,
  });

  factory PlanProduct.fromJson(Map<String, dynamic> json) {
    return PlanProduct(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      description: json['description'],
      selectedVariant: PlanVariant.fromJson(json['selectedVariant'] ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => PlanProductImage.fromJson(e))
              .toList() ??
          [],
      quantity: json['quantity'] ?? 0,
    );
  }
}

class PlanVariant {
  final int id;
  final String price;
  final int quantityInMl;
  final int? isActive;

  PlanVariant({
    required this.id,
    required this.price,
    required this.quantityInMl,
    this.isActive,
  });

  factory PlanVariant.fromJson(Map<String, dynamic> json) {
    return PlanVariant(
      id: json['id'] ?? 0,
      price: json['price']?.toString() ?? '0',
      quantityInMl: json['quantityinml'] ?? 0,
      isActive: json['isActive'],
    );
  }
}

class PlanProductImage {
  final String imageUrl;
  String? signedUrl;

  PlanProductImage({
    required this.imageUrl,
    this.signedUrl,
  });

  factory PlanProductImage.fromJson(Map<String, dynamic> json) {
    return PlanProductImage(
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
