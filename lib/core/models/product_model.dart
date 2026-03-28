import 'dart:convert';

class Product {
  final int id;
  final String skuCode;
  final String productName;
  final String description;

  final List<int> availaibleCities;

  final int isApproved;
  final String? createdOn;
  final String? createdBy;
  final String? updatedOn;
  final String? updatedBy;
  final int isDeleted;
  final String? deletedOn;
  final String? deletedBy;

  final List<ProductImage> images;

  final List<Variant> variants;

  final List<String> availaibleCitiesName;

  String? signedImageUrl;

  int? quantity;

  Product({
    required this.id,
    required this.skuCode,
    required this.productName,
    required this.description,
    required this.availaibleCities,
    required this.isApproved,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    required this.isDeleted,
    this.deletedOn,
    this.deletedBy,
    required this.images,
    required this.variants,
    required this.availaibleCitiesName,
    this.signedImageUrl,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? signedUrl}) {
    final rawCities = json['availaibleCities'];
    List<int> cityIds = [];
    if (rawCities is String && rawCities.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCities);
        if (decoded is List) {
          cityIds =
              decoded.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      } catch (_) {}
    } else if (rawCities is List) {
      cityIds = rawCities.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    return Product(
      id: json['id'] ?? 0,
      skuCode: json['skuCode'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',

      availaibleCities: cityIds,

      isApproved: json['isApproved'] ?? 0,
      createdOn: json['createdon']?.toString(),
      createdBy: json['createdby']?.toString(),
      updatedOn: json['updatedon']?.toString(),
      updatedBy: json['updatedby']?.toString(),
      isDeleted: json['isdeleted'] ?? 0,
      deletedOn: json['deletedon']?.toString(),
      deletedBy: json['deletedby']?.toString(),

      images: (json['images'] as List? ?? const [])
          .map(
            (e) => ProductImage.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),

      variants: (json['variants'] as List? ?? const [])
          .map((e) => Variant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),

      availaibleCitiesName: (json['availaibleCitiesName'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),

      signedImageUrl: signedUrl,
      quantity: json['quantity'] ?? 1,
    );
  }

  String get displayPrice {
    if (variants.isNotEmpty) {
      return variants.first.price;
    }
    return "N/A";
  }

  String get displayquantity {
    if (variants.isNotEmpty) {
      return variants.first.quantityInMl;
    }
    return "N/A";
  }
}

class ProductImage {
  final int id;
  final String rawImageUrl;
  String? signedUrl;

  ProductImage({required this.id, required this.rawImageUrl, this.signedUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      rawImageUrl: json['imageUrl'] ?? '',
    );
  }
}

class Variant {
  final int id;
  final String quantityInMl;
  final String price;
  final String? originalPrice;

  Variant({
    required this.id,
    required this.quantityInMl,
    required this.price,
    this.originalPrice,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'] ?? 0,
      quantityInMl: json['quantityinml']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      originalPrice: json['originalPrice']?.toString(),
    );
  }
}
