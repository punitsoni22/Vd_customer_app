import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';

class CheckoutProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _coupons = [];
  List<Map<String, dynamic>> get coupons => _coupons;

  bool _isLoadingCoupons = false;
  bool get isLoadingCoupons => _isLoadingCoupons;

  double _couponDiscount = 0.0;
  double get couponDiscount => _couponDiscount;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userIdString = await Prefs.getString('user_id');
      if (userIdString == null) {
        _addresses = [];
        _selectedAddress = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final userId = int.tryParse(userIdString);
      if (userId == null) {
        _addresses = [];
        _selectedAddress = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await Api.post('getAllAddress', {
        'data': {'userId': userId},
      });

      if (response['success'] == true && response['data'] != null) {
        final rows = response['data']['rows'] as List? ?? [];
        _addresses = rows
            .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        _selectedAddress = _addresses.isEmpty
            ? null
            : _addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => _addresses.first,
              );
      } else {
        _addresses = [];
        _selectedAddress = null;
      }
    } catch (e) {
      print('CheckoutProvider fetchAddresses error: $e');
      _addresses = [];
      _selectedAddress = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  int get addressCount => _addresses.length;

  Future<void> fetchCoupons(double subtotal) async {
    _isLoadingCoupons = true;
    notifyListeners();

    try {
      final response = await Api.post('getAllCoupon', {
        "data": {"page": 1, "pageSize": 10},
      });

      if (response['success'] == true && response['data'] != null) {
        final couponsList = response['data']['coupons'] as List? ?? [];
        _coupons = List<Map<String, dynamic>>.from(couponsList);

        if (_coupons.isNotEmpty) {
          final firstCoupon = _coupons.first;
          _couponDiscount =
              (firstCoupon['discountAmount'] ??
                      firstCoupon['discountValue'] ??
                      0.0)
                  .toDouble();
        } else {
          _couponDiscount = 0.0;
        }
      } else {
        _coupons = [];
        _couponDiscount = 0.0;
      }
    } catch (e) {
      print("CheckoutProvider fetchCoupons error: $e");
      _coupons = [];
      _couponDiscount = 0.0;
    }

    _isLoadingCoupons = false;
    notifyListeners();
  }

  void applyCoupon(String code) {
    final matched = _coupons.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {},
    );

    _couponDiscount =
        (matched['discountAmount'] ?? matched['discountValue'] ?? 0.0)
            .toDouble();
    notifyListeners();
  }

  Future<void> placeOrder({
    required CartProvider cartProvider,
    required BuildContext context,
    String couponCode = "",
  }) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an address.")),
      );
      return;
    }

    if (cartProvider.cartId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No active cart found.")));
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        "data": {
          "id": 0,
          "cartId": cartProvider.cartId!,
          "addressId": _selectedAddress!.id,
          "couponCode": couponCode,
        },
      };

      final response = await Api.post("addEditOrder", payload);

      _isLoading = false;
      notifyListeners();

      final isSuccess =
          response['dataResponse']?['returnCode'] == 0 ||
          response['success'] == true;

      if (isSuccess) {
        cartProvider.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );

        context.go(AppRoutes.bottomBarScreen);
      } else {
        final description =
            response['dataResponse']?['description'] ??
            response['message'] ??
            "Order failed.";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(description)));
      }
    } catch (e, st) {
      _isLoading = false;
      notifyListeners();
      debugPrint("placeOrder Exception = $e");
      debugPrint("placeOrder StackTrace = $st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
