class UnifiedOrderModel {
  final String id;
  final String type;
  final String date;
  final String status;
  final String productName;
  final int quantity;
  final String? signedUrl;
  final String? rawImageUrl;
  final String? nextDelivery;
  final String? deliveryFrequency;

  UnifiedOrderModel({
    required this.id,
    required this.type,
    required this.date,
    required this.status,
    required this.productName,
    required this.quantity,
    this.signedUrl,
    this.rawImageUrl,
    this.nextDelivery,
    this.deliveryFrequency,
  });
}
