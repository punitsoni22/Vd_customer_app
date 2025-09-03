class Product {
  final int id;
  final String skuCode;
  final String productName;
  final String description;
  final String availaibleCities;
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      skuCode: json['skuCode'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      availaibleCities: json['availaibleCities'] ?? '',
      isApproved: json['isApproved'] ?? 0,
      createdOn: json['createdon'] as String?,
      createdBy: json['createdby'] as String?,
      updatedOn: json['updatedon'] as String?,
      updatedBy: json['updatedby'] as String?,
      isDeleted: json['isdeleted'] ?? 0,
      deletedOn: json['deletedon'] as String?,
      deletedBy: json['deletedby'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => Variant.fromJson(e))
          .toList(),
      availaibleCitiesName:
          (json['availaibleCitiesName'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}

class ProductImage {
  final int id;
  final String imageUrl;

  ProductImage({required this.id, required this.imageUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(id: json['id'] ?? 0, imageUrl: json['imageUrl'] ?? '');
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
