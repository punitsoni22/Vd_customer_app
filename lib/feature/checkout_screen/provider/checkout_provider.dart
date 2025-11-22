import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

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
      // final userIdString = await Prefs.getString('user_id');
      // if (userIdString == null) {
      //   _addresses = [];
      //   _selectedAddress = null;
      //   _isLoading = false;
      //   notifyListeners();
      //   return;
      // }

      // final userId = int.tryParse(userIdString);
      // if (userId == null) {
      //   _addresses = [];
      //   _selectedAddress = null;
      //   _isLoading = false;
      //   notifyListeners();
      //   return;
      // }

      final response = await Api.post('getAllAddress', {
        'data': {},
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

      print("Coupons API Response: $response");

      // Handle both success formats
      bool isSuccess = false;
      Map<String, dynamic>? dataResponse;

      if (response['success'] == true) {
        isSuccess = true;
        dataResponse = response['data'];
      } else if (response['dataResponse']?['returnCode'] == 0) {
        isSuccess = true;
        dataResponse = response['data'];
      }

      if (isSuccess && dataResponse != null) {
        final couponsList = dataResponse['coupons'] as List? ?? [];

        // Filter out deleted coupons and inactive ones
        _coupons = couponsList
            .cast<Map<String, dynamic>>()
            .where(
              (coupon) =>
                  (coupon['isdeleted'] == 0 || coupon['isdeleted'] == null) &&
                  (coupon['isActive'] == true),
            )
            .toList();
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

  void applyCoupon(String code, double subtotal) {
    final matched = _coupons.firstWhere(
      (c) => c['couponCode'] == code,
      orElse: () => {},
    );

    if (matched.isNotEmpty) {
      final couponValue =
          double.tryParse(matched['couponValue'].toString()) ?? 0.0;
      final couponType = matched['couponType'] ?? 'PERCENTAGE';

      if (couponType == 'PERCENTAGE') {
        _couponDiscount = (subtotal * couponValue) / 100;
      } else {
        // Fixed amount discount
        _couponDiscount = couponValue;
      }

      // Ensure discount doesn't exceed subtotal
      if (_couponDiscount > subtotal) {
        _couponDiscount = subtotal;
      }
    } else {
      _couponDiscount = 0.0;
    }
    notifyListeners();
  }

  String? _appliedCouponCode;
  String? get appliedCouponCode => _appliedCouponCode;

  void setAppliedCoupon(String? code) {
    _appliedCouponCode = code;
    notifyListeners();
  }

  void clearCoupon() {
    _couponDiscount = 0.0;
    _appliedCouponCode = null;
    notifyListeners();
  }

  Future<void> placeOrder({
    required CartProvider cartProvider,
    required BuildContext context,
    String couponCode = "",
  }) async {
    if (_selectedAddress == null) {
      MySnackBar.showSnackBar(context, "Please select an address.");
      return;
    }

    if (cartProvider.cartId == null) {
      MySnackBar.showSnackBar(context, "No active cart found.");
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

        clearCoupon();
        MySnackBar.showSnackBar(context, "Order placed successfully!");

        context.pushReplacement(AppRoutes.myOrderScreen);
      } else {
        final description =
            response['dataResponse']?['description'] ??
            response['message'] ??
            "Order failed.";
        MySnackBar.showSnackBar(context, "Error: $description");
      }
    } catch (e, st) {
      _isLoading = false;
      notifyListeners();
      debugPrint("placeOrder Exception = $e");
      debugPrint("placeOrder StackTrace = $st");
      MySnackBar.showSnackBar(context, "Error: $e");
    }
  }
}
