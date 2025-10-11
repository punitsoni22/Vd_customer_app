class AddressModel {
  final int id;
  final int userId;
  final String fullAddress;
  final String city;
  final String state;
  final String country;
  final String latitude;
  final String longitude;
  final String postalCode;
  final bool isDefault;
  final String? createdOn;

  AddressModel({
    required this.id,
    required this.userId,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.postalCode,
    required this.isDefault,
    this.createdOn,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String parseString(dynamic v) => v?.toString() ?? '';

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return AddressModel(
      id: parseInt(json['id'] ?? json['Id']),
      userId: parseInt(json['userId'] ?? json['user_id']),
      fullAddress: parseString(
        json['fullAddress'] ?? json['full_address'] ?? json['address'],
      ),
      city: parseString(json['city']),
      state: parseString(json['state']),
      country: parseString(json['country']),
      latitude: parseString(json['latitude']),
      longitude: parseString(json['longitude']),
      postalCode: parseString(json['postalCode'] ?? json['postal_code']),
      isDefault: parseBool(
        json['isDefault'] ?? json['is_default'] ?? json['default'],
      ),
      createdOn: (json['createdOn'] ?? json['createdon'] ?? json['created_on'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullAddress': fullAddress,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'createdOn': createdOn,
    };
  }

  double? get latitudeDouble => double.tryParse(latitude);
  double? get longitudeDouble => double.tryParse(longitude);
}
