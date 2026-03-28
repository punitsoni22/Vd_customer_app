import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/my_order_screen/provider/my_order_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class CheckoutProvider extends ChangeNotifier {
  late Razorpay _razorpay;
  int? _pendingOrderId;
  String? _pendingOrderNo;
  CartProvider? _pendingCartProvider;
  BuildContext? _pendingContext;
  bool _postPaymentDialogShown = false;
  double? _lastOrderTotalAmount;
  double? _lastOrderDiscountAmount;

  double? get lastOrderTotalAmount => _lastOrderTotalAmount;
  double? get lastOrderDiscountAmount => _lastOrderDiscountAmount;

  CheckoutProvider() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // New state variables for 2-step checkout
  int _currentStep = 1;
  int get currentStep => _currentStep;

  bool _isCheckingDelivery = false;
  bool get isCheckingDelivery => _isCheckingDelivery;

  bool _isDeliverable = false;
  bool get isDeliverable => _isDeliverable;

  String _deliveryMessage = '';
  String get deliveryMessage => _deliveryMessage;

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  List<String> _undeliverableProducts = [];
  List<String> get undeliverableProducts => _undeliverableProducts;

  Future<void> checkDeliveryPincode(String pinCode, int? cartId) async {
    _isCheckingDelivery = true;
    _deliveryMessage = '';
    _undeliverableProducts = [];
    notifyListeners();

    try {
      final response = await Api.post('checkDeliveryPincode', {
        "data": {"pinCode": pinCode, if (cartId != null) "cartId": cartId},
      });

      print("checkDeliveryPincode Response: $response");

      bool isSuccess = false;
      Map<String, dynamic>? data;

      if (response['success'] == true) {
        isSuccess = true;
        data = response['data'];
      } else if (response['dataResponse']?['returnCode'] == 0) {
        isSuccess = true;
        data = response['data'];
      }

      if (isSuccess && data != null) {
        _isDeliverable = data['isDeliverable'] == true;
        _deliveryMessage =
            data['message'] ??
            (_isDeliverable
                ? "Delivery is available."
                : "Delivery not available.");

        if (data['undeliverableProducts'] != null) {
          _undeliverableProducts = List<String>.from(
            data['undeliverableProducts'],
          );
        }
      } else {
        _isDeliverable = false;
        _deliveryMessage =
            response['message'] ??
            response['dataResponse']?['description'] ??
            "Unable to verify delivery.";
      }
    } catch (e) {
      print("checkDeliveryPincode error: $e");
      _isDeliverable = false;
      _deliveryMessage = "Error verifying delivery pincode.";
    }

    _isCheckingDelivery = false;
    notifyListeners();
  }

  void resetDeliveryStatus() {
    _isDeliverable = false;
    _deliveryMessage = '';
    notifyListeners();
  }

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
      final response = await Api.post('getAllAddress', {'data': {}});

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

  void _openRazorpay(
    Map<String, dynamic> paymentData,
    Map<String, dynamic> orderData,
    CartProvider cartProvider,
    BuildContext context,
  ) {
    _pendingOrderId = orderData['id'] is int
        ? orderData['id']
        : (int.tryParse(orderData['id']?.toString() ?? ''));
    _pendingOrderNo = orderData['orderNo']?.toString();
    _pendingCartProvider = cartProvider;
    _pendingContext = context;

    final key =
        paymentData['keyId']?.toString() ?? paymentData['key']?.toString();
    double amountDouble = 0;
    try {
      amountDouble = paymentData['amount'] is String
          ? double.tryParse(paymentData['amount']) ?? 0
          : (paymentData['amount'] is num
                ? (paymentData['amount'] as num).toDouble()
                : 0);
    } catch (_) {}

    final options = {
      'key': key,
      'amount': (amountDouble * 100).toInt(),
      'name': paymentData['name'] ?? 'Veedasip',
      'description': paymentData['description'] ?? 'Order Payment',
      'order_id': paymentData['razorpayOrderId'] ?? paymentData['orderId'],
      'currency': paymentData['currency'] ?? 'INR',
      'prefill': paymentData['prefill'] ?? {},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      MySnackBar.showSnackBar(
        context,
        'Payment gateway error. Please try again.',
      );
      _pendingOrderId = null;
      _pendingOrderNo = null;
      _pendingCartProvider = null;
      _pendingContext = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void startOnlinePayment({
    required Map<String, dynamic> paymentData,
    required Map<String, dynamic> orderData,
    required CartProvider cartProvider,
    required BuildContext context,
  }) {
    _isLoading = true;
    notifyListeners();
    _openRazorpay(paymentData, orderData, cartProvider, context);
  }

  Future<void> _clearCartBackendFast(CartProvider cartProvider) async {
    final currentCartId = cartProvider.cartId;
    cartProvider.clearCart();
    if (currentCartId == null) return;
    try {
      await Api.post('addEditCart', {
        "data": {"id": currentCartId, "products": []},
      });
    } catch (_) {}
  }

  Future<void> _showPostPaymentChoiceDialog(BuildContext context) async {
    if (!context.mounted) return;
    context.goNamed(AppRoutes.myOrderScreen, extra: {'initialTabIndex': 1});
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _isLoading = false;
    notifyListeners();

    final ctx = _pendingContext;
    final payload = {
      'data': {
        'orderId': _pendingOrderId,
        'razorpayOrderId': response.orderId,
        'razorpayPaymentId': response.paymentId,
        'razorpaySignature': response.signature,
      },
    };

    try {
      if (_pendingOrderId != null) {
        final verifyResponse = await Api.post('verifyPayment', payload);
        final verified =
            verifyResponse['success'] == true ||
            verifyResponse['dataResponse']?['returnCode'] == 0;
        if (!verified) {
          throw Exception(
            verifyResponse['message'] ??
                verifyResponse['dataResponse']?['description'] ??
                'Payment verification failed.',
          );
        }
      } else {
        throw Exception('Missing order id for payment verification.');
      }

      final cp = _pendingCartProvider;
      if (cp != null) {
        _clearCartBackendFast(cp);
      }
      clearCoupon();

      if (ctx != null) {
        try {
          ctx.read<MyOrderProvider>().fetchOrders();
        } catch (_) {}
        await _showPostPaymentChoiceDialog(ctx);
      }
    } catch (e) {
      if (ctx != null) {
        MySnackBar.showSnackBar(
          ctx,
          'Payment succeeded but finalizing failed.',
        );
      }
    } finally {
      _pendingOrderId = null;
      _pendingOrderNo = null;
      _pendingCartProvider = null;
      _pendingContext = null;
      _postPaymentDialogShown = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isLoading = false;
    notifyListeners();
    if (_pendingContext != null) {
      MySnackBar.showSnackBar(
        _pendingContext!,
        'Payment failed: ${response.message ?? 'Please try again'}',
      );
    }
    _pendingOrderId = null;
    _pendingOrderNo = null;
    _pendingCartProvider = null;
    _pendingContext = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_pendingContext != null)
      MySnackBar.showSnackBar(
        _pendingContext!,
        'External wallet selected: ${response.walletName}',
      );
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

  Future<Map<String, dynamic>?> placeOrder({
    required CartProvider cartProvider,
    required BuildContext context,
    String couponCode = "",
    String paymentMode = 'ONLINE',
  }) async {
    if (_selectedAddress == null) {
      MySnackBar.showSnackBar(context, "Please select an address.");
      return null;
    }

    if (cartProvider.cartId == null) {
      MySnackBar.showSnackBar(context, "No active cart found.");
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        "cartId": cartProvider.cartId!,
        "addressId": _selectedAddress!.id,
        "paymentMode": paymentMode,
      };
      final cleanedCoupon = couponCode.trim();
      if (cleanedCoupon.isNotEmpty) {
        data["couponCode"] = cleanedCoupon;
      }
      final payload = {"data": data};

      final response = await Api.post("addEditOrder", payload);

      final isSuccess =
          response['dataResponse']?['returnCode'] == 0 ||
          response['success'] == true;

      if (isSuccess) {
        final orderData = response['data'] as Map<String, dynamic>? ?? {};
        _lastOrderTotalAmount =
            double.tryParse((orderData['totalAmount'] ?? '0').toString());
        _lastOrderDiscountAmount =
            double.tryParse((orderData['discountAmount'] ?? '0').toString());
        notifyListeners();

        // If QR payment created by backend, return orderData so UI can show QR
        if ((paymentMode.toUpperCase() == 'QR' ||
            (orderData['qrCode'] != null && orderData['qrCode'] != ""))) {
          // Do not finalize locally; UI will handle showing QR and polling
          _isLoading = false;
          notifyListeners();
          return orderData;
        }

        final respPaymentMode = orderData['paymentMode']?.toString() ?? '';
        final paymentData = orderData['payment'] as Map<String, dynamic>?;

        if (respPaymentMode.toUpperCase() == 'ONLINE' && paymentData != null) {
          _isLoading = false;
          notifyListeners();
          return orderData;
        } else {
          // For POD/COD
          _isLoading = false;
          notifyListeners();
          await cartProvider.clearCartOnBackend(context);
          clearCoupon();
          _lastOrderTotalAmount = null;
          _lastOrderDiscountAmount = null;
          try {
            await context.read<MyOrderProvider>().fetchOrders();
          } catch (_) {}
          MySnackBar.showSnackBar(context, "Order placed successfully!");
          if (context.mounted) {
            context.goNamed(
              AppRoutes.myOrderScreen,
              extra: {'initialTabIndex': 1},
            );
          }
          return orderData;
        }
      } else {
        _isLoading = false;
        notifyListeners();
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

    return null;
  }

  Future<void> handleQRPaymentSuccess(
    Map<String, dynamic> order,
    CartProvider cartProvider,
    BuildContext context,
  ) async {
    try {
      final razorpayOrderId = order['razorpayOrderId'];
      final razorpayPaymentId = order['razorpayPaymentId'];
      final razorpaySignature = order['razorpaySignature'];

      if (order['id'] != null &&
          razorpayOrderId != null &&
          razorpayPaymentId != null &&
          razorpaySignature != null) {
        await Api.post('verifyPayment', {
          'data': {
            'orderId': order['id'],
            'razorpayOrderId': razorpayOrderId,
            'razorpayPaymentId': razorpayPaymentId,
            'razorpaySignature': razorpaySignature,
          },
        });
      }

      // Clear cart and coupon
      _clearCartBackendFast(cartProvider);
      clearCoupon();

      // Show success and navigate
      try {
        context.read<MyOrderProvider>().fetchOrders();
      } catch (_) {}
      await _showPostPaymentChoiceDialog(context);
    } catch (e) {
      debugPrint('Invoice generation error: $e');
      // Even if invoice fails, order was successful
      _clearCartBackendFast(cartProvider);
      clearCoupon();
      try {
        context.read<MyOrderProvider>().fetchOrders();
      } catch (_) {}
      await _showPostPaymentChoiceDialog(context);
    }
  }
}
