class Product {
  final int id;
  final String skuCode;
  final String productName;
  final String description;

  // API gives a list of ints
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

  // ✅ variants is a list
  final List<Variant> variants;

  final List<String> availaibleCitiesName;

  String? signedImageUrl; // optional extra

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
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? signedUrl}) {
    return Product(
      id: json['id'] ?? 0,
      skuCode: json['skuCode'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',

      availaibleCities: (json['availaibleCitiesName'] as List? ?? const [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),

      isApproved: json['isApproved'] ?? 0,
      createdOn: json['createdon']?.toString(),
      createdBy: json['createdby']?.toString(),
      updatedOn: json['updatedon']?.toString(),
      updatedBy: json['updatedby']?.toString(),
      isDeleted: json['isdeleted'] ?? 0,
      deletedOn: json['deletedon']?.toString(),
      deletedBy: json['deletedby']?.toString(),

      images: (json['images'] as List? ?? const [])
          .map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),

      // ✅ parse list of variants
      variants: (json['variants'] as List? ?? const [])
          .map((e) => Variant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),

      availaibleCitiesName:
      (json['availaibleCitiesName'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),

      signedImageUrl: signedUrl,
    );
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

  Variant({required this.id, required this.quantityInMl, required this.price});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'] ?? 0,
      quantityInMl: json['quantityinml']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }
}
