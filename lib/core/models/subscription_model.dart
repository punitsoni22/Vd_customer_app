class SubscriptionModel {
  final int id;
  final String customerName;
  final String deliveryFrequencyType;
  final String subscriptionType;
  final DateTime startDate;
  final DateTime endDate;
  final List<SubscriptionProduct> products;
  final SubscriptionInvoice? invoice;
  final int? status;

  SubscriptionModel({
    required this.id,
    required this.customerName,
    required this.deliveryFrequencyType,
    required this.subscriptionType,
    required this.startDate,
    required this.endDate,
    required this.products,
    this.invoice,
    this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? invoiceJson =
        (json['invoice'] as Map<String, dynamic>?);

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
      invoice: invoiceJson != null
          ? SubscriptionInvoice.fromJson(invoiceJson)
          : null,
      status: json['status'] is int
          ? json['status'] as int
          : (json['status'] is String ? int.tryParse(json['status']) : null),
    );
  }
}
enum eSubscriptionStatus { PAUSED, RESUMED, CANCELLED }

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
    // Extract image URL from the images array
    String? imgUrl;
    if (json['images'] != null && json['images'] is List) {
      final images = json['images'] as List;
      if (images.isNotEmpty) {
        imgUrl = images[0]['imageUrl'] as String?;
      }
    }

    return SubscriptionProduct(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'],
      imageUrl: imgUrl,
    );
  }
}

class SubscriptionInvoice {
  final String invoiceNumber;
  final String invoiceUrl;
  String? signedUrl;

  SubscriptionInvoice({
    required this.invoiceNumber,
    required this.invoiceUrl,
    this.signedUrl,
  });

  factory SubscriptionInvoice.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoice(
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
    );
  }
}
