import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';

import '../../../core/models/order_model.dart';
import '../../../core/models/subscription_model.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/signedurl.dart';

class MyOrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  final List<Order> _orders = [];

  int currentPage = 1;
  int totalPages = 1;

  int _ordersRequestId = 0;
  int _subscriptionsRequestId = 0;

  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<Order> get orders => UnmodifiableListView(_orders);

  final List<SubscriptionModel> _subscriptions = [];
  List<SubscriptionModel> get subscriptions =>
      UnmodifiableListView(_subscriptions);

  bool subscriptionsLoaded = false;
  bool ordersLoaded = false;
  bool isMoreOrdersLoading = false;
  bool isMoreSubscriptionsLoading = false;

  int currentOrderPage = 1;
  int totalOrderPages = 1;

  int currentSubscriptionPage = 1;
  int totalSubscriptionPages = 1;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchOrders({int page = 1}) async {
    final int rid = ++_ordersRequestId;
    if (page == 1) {
      _isLoading = true;
      _orders.clear();
    } else {
      isMoreOrdersLoading = true;
    }
    _message = null;
    _safeNotify();

    log("Fetching orders, page: $page, requestId: $rid");

    try {
      final response = await Api.post('getAllOrders', {
        "data": {"page": page, "pageSize": 10, "searchText": ""},
      });

      log("API Response: $response");

      if (rid != _ordersRequestId) return;

      if (response['success'] == true) {
        final List<dynamic> items = response['data']?['items'] ?? [];
        final pagination = response['data']?['pagination'] ?? {};
        currentOrderPage = pagination['page'] ?? 1;
        totalOrderPages = pagination['totalPages'] ?? 1;

        final newOrders = items.map((e) => Order.fromJson(e)).toList();
        _orders.addAll(newOrders);

        await Future.wait(
          newOrders.map((order) async {
            for (var cartDetail in order.cart.cartDetails) {
              final imageUrl = cartDetail.productImages.imageUrl;
              if (imageUrl.isNotEmpty) {
                try {
                  cartDetail.productImages.signedUrl = await generateSignedUrl(
                    imageUrl,
                  );
                } catch (e) {
                  if (kDebugMode) log("S3 URL failed for $imageUrl: $e");
                  cartDetail.productImages.signedUrl = null;
                }
              }
            }
            if (order.invoice != null && order.invoice!.filePath.isNotEmpty) {
              try {
                order.invoice!.signedUrl = await generateSignedUrl(
                  order.invoice!.filePath,
                );
              } catch (e) {
                if (kDebugMode) log("Invoice S3 URL failed: $e");
                order.invoice!.signedUrl = null;
              }
            }
          }),
        );

        ordersLoaded = true;
        _message = response['message'] ?? "Orders fetched successfully";
      } else {
        _orders.clear();
        ordersLoaded = true;
        _message = response['message'] ?? "Failed to fetch orders";
        log("API returned failure: $_message");
      }
    } catch (e, st) {
      if (rid != _ordersRequestId) return;
      _orders.clear();
      ordersLoaded = true;
      _message = "Exception: $e";
      log("MyOrder fetch exception: $e\n$st");
    } finally {
      if (rid != _ordersRequestId) return;
      _isLoading = false;
      isMoreOrdersLoading = false;
      _safeNotify();
    }
  }

  Future<void> fetchSubscriptions({int page = 1}) async {
    final int rid = ++_subscriptionsRequestId;
    if (page == 1) {
      _isLoading = true;
      _subscriptions.clear();
    } else {
      isMoreSubscriptionsLoading = true;
    }
    _message = null;
    _safeNotify();

    try {
      final response = await Api.post("getAllSubscription", {
        "data": {"page": page, "pageSize": 10, "searchText": ""},
      });
      if (rid != _subscriptionsRequestId) return;

      if (response["success"] == true) {
        final List<dynamic> items = response["data"]?["subscription"] ?? [];
        final newSubscriptions = items
            .map((e) => SubscriptionModel.fromJson(e))
            .toList();
        _subscriptions.addAll(newSubscriptions);

        await Future.wait(
          newSubscriptions.map((sub) async {
            if (sub.invoice != null && sub.invoice!.invoiceUrl.isNotEmpty) {
              try {
                sub.invoice!.signedUrl = await generateSignedUrl(
                  sub.invoice!.invoiceUrl,
                );
              } catch (e) {
                if (kDebugMode) log("Subscription Invoice S3 URL failed: $e");
                sub.invoice!.signedUrl = null;
              }
            }

            for (var product in sub.products) {
              if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
                try {
                  product.signedUrl = await generateSignedUrl(
                    product.imageUrl!,
                  );
                } catch (e) {
                  if (kDebugMode) log("Product image S3 URL failed: $e");
                  product.signedUrl = null;
                }
              }
            }
          }),
        );

        subscriptionsLoaded = true;
        _message = "Subscriptions fetched";
      } else {
        _subscriptions.clear();
        subscriptionsLoaded = true;
        _message = response["message"] ?? "Failed to fetch subscriptions";
      }
    } catch (e, st) {
      if (rid != _subscriptionsRequestId) return;
      _subscriptions.clear();
      subscriptionsLoaded = true;
      _message = "Error: $e";
      log("fetchSubscriptions err: $e\n$st");
    } finally {
      if (rid != _subscriptionsRequestId) return;
      _isLoading = false;
      isMoreSubscriptionsLoading = false;
      _safeNotify();
    }
  }

  void clearMessage() {
    _message = null;
    _safeNotify();
  }
}
