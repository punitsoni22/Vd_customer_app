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
  final List<String> images;
  final List<String> variants;
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
      createdOn: json['createdon'],
      createdBy: json['createdby'],
      updatedOn: json['updatedon'],
      updatedBy: json['updatedby'],
      isDeleted: json['isdeleted'] ?? 0,
      deletedOn: json['deletedon'],
      deletedBy: json['deletedby'],
      images: List<String>.from(json['images'] ?? []),
      variants: List<String>.from(json['variants'] ?? []),
      availaibleCitiesName: List<String>.from(
        json['availaibleCitiesName'] ?? [],
      ),
    );
  }
}
