import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:vd_customer_app/core/models/order_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/xd.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';

class MyOrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  final List<Order> _orders = [];

  int currentPage = 1;
  int totalPages = 1;

  int _requestId = 0;

  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<Order> get orders => UnmodifiableListView(_orders);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchOrders({int page = 1}) async {
    final int rid = ++_requestId;
    _isLoading = true;
    _message = null;
    _safeNotify();

    log("Fetching orders, page: $page, requestId: $rid");

    try {
      final token = await Prefs.getString(Prefs.keyAuthToken) ?? '';

      final response = await Api.post('getAllOrders', {
        "page": page,
        "pageSize": 10,
        "token": token,
      });

      log("API Response: $response");

      if (rid != _requestId) return;

      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        final pagination = response['data']?['pagination'] ?? {};
        currentPage = pagination['page'] ?? 1;
        totalPages = pagination['totalPages'] ?? 1;

        _orders.clear();
        _orders.addAll(items.map((e) => Order.fromJson(e)));

        log("Orders parsed: ${_orders.length}");
        for (var order in _orders) {
          log(
            "OrderID: ${order.orderId}, CartDetails: ${order.cart.cartDetails.length}",
          );
        }

        await Future.wait(
          _orders.map((order) async {
            for (var cartDetail in order.cart.cartDetails) {
              final imageUrl = cartDetail.productImages.imageUrl;
              if (imageUrl.isNotEmpty) {
                try {
                  cartDetail.productImages.signedUrl = await generateSignedUrl(
                    imageUrl,
                  );
                  log("Signed URL generated for ${cartDetail.productName}");
                } catch (e) {
                  if (kDebugMode) log("S3 URL failed for $imageUrl: $e");
                  cartDetail.productImages.signedUrl = null;
                }
              }
            }
          }),
        );

        _message = response['message'] ?? "Orders fetched successfully";
      } else {
        _orders.clear();
        _message = response['message'] ?? "Failed to fetch orders";
        log("API returned failure: $_message");
      }
    } catch (e, st) {
      if (rid != _requestId) return;
      _orders.clear();
      _message = "Exception: $e";
      log("MyOrder fetch exception: $e\n$st");
    } finally {
      if (rid != _requestId) return;
      _isLoading = false;
      _safeNotify();
    }
  }

  void clearMessage() {
    _message = null;
    _safeNotify();
  }
}
