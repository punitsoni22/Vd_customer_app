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

    if (json['products'] != null && json['products'] is List) {
      // If products are already in the response
      productsList = (json['products'] as List)
          .map(
            (e) => SubscriptionProductDetail.fromProductIdJson(
              e['productId'] ?? e,
            ),
          )
          .toList();
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

  SubscriptionProductDetail({
    required this.productId,
    required this.variantId,
    required this.quantity,
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
}
