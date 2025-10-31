class SubscriptionModel {
  final int id;
  final String customerName;
  final String deliveryFrequencyType;
  final String subscriptionType;
  final DateTime startDate;
  final DateTime endDate;
  final List<SubscriptionProduct> products;

  SubscriptionModel({
    required this.id,
    required this.customerName,
    required this.deliveryFrequencyType,
    required this.subscriptionType,
    required this.startDate,
    required this.endDate,
    required this.products,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      customerName: json['customerName'] ?? '',
      deliveryFrequencyType: json['deliveryFrequencyType'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      products: (json['products'] as List<dynamic>)
          .map((e) => SubscriptionProduct.fromJson(e))
          .toList(),
    );
  }
}

class SubscriptionProduct {
  final int productId;
  final String productName;
  final int quantity;

  String? imageUrl;
  String? signedUrl;

  SubscriptionProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.imageUrl,
    this.signedUrl,
  });

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionProduct(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}
