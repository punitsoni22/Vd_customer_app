import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:vd_customer_app/core/models/order_model.dart';
import 'package:vd_customer_app/core/models/subscription_model.dart';
import 'package:vd_customer_app/core/models/unified_order_model_.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';

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

  final List<SubscriptionModel> _subscriptions = [];
  List<SubscriptionModel> get subscriptions =>
      UnmodifiableListView(_subscriptions);

  final List<UnifiedOrderModel> _allOrdersUnified = [];
  List<UnifiedOrderModel> get allOrdersUnified => _allOrdersUnified;

  bool allDataLoaded = false;
  bool isLoadingAll = false;
  bool subscriptionsLoaded = false;
  bool ordersLoaded = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void mergeAllOrders() {
    _allOrdersUnified.clear();

    for (var order in _orders) {
      if (order.cart.cartDetails.isNotEmpty) {
        final c = order.cart.cartDetails[0];
        _allOrdersUnified.add(
          UnifiedOrderModel(
            id: order.orderId.toString(),
            type: "order",
            date: order.orderConfirmedDate.split('T').first,
            status: order.status,
            productName: c.productName,
            quantity: c.quantity,
            signedUrl: c.productImages.signedUrl,
            rawImageUrl: c.productImages.imageUrl,
            invoiceUrl: order.invoice?.signedUrl,
            invoiceNumber: order.invoice?.invoiceNumber,
          ),
        );
      }
    }

    for (var sub in _subscriptions) {
      for (var p in sub.products) {
        _allOrdersUnified.add(
          UnifiedOrderModel(
            id: sub.id.toString(),
            type: "subscription",
            date: sub.startDate.toString().split(" ").first,
            status: sub.subscriptionType,
            productName: p.productName,
            quantity: p.quantity,
            signedUrl: p.signedUrl,
            rawImageUrl: p.imageUrl,
            nextDelivery: sub.startDate.toString().split(" ").first,
            deliveryFrequency: sub.deliveryFrequencyType,
            invoiceUrl: sub.invoice?.signedUrl,
            invoiceNumber: sub.invoice?.invoiceNumber,
          ),
        );
      }
    }

    _allOrdersUnified.sort((a, b) => b.date.compareTo(a.date));
    _safeNotify();
  }

  Future<void> loadAllForTab1() async {
    if (isLoadingAll || allDataLoaded) return;

    isLoadingAll = true;
    _safeNotify();

    await fetchSubscriptions();
    await fetchOrders();

    mergeAllOrders();
    allDataLoaded = true;
    isLoadingAll = false;
    _safeNotify();
  }

  Future<void> fetchOrders({int page = 1}) async {
    final int rid = ++_requestId;
    _isLoading = true;
    _message = null;
    _safeNotify();

    log("Fetching orders, page: $page, requestId: $rid");

    try {
      // final token = await Prefs.getString(Prefs.keyAuthToken) ?? '';

      final response = await Api.post('getAllOrders', {
        "page": page,
        "pageSize": 10,
        // "token": token,
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

            // Generate signed URL for invoice
            if (order.invoice != null && order.invoice!.filePath.isNotEmpty) {
              try {
                order.invoice!.signedUrl = await generateSignedUrl(
                  order.invoice!.filePath,
                );
                log("Invoice signed URL generated for Order ${order.orderId}");
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
      if (rid != _requestId) return;
      _orders.clear();
      ordersLoaded = true;
      _message = "Exception: $e";
      log("MyOrder fetch exception: $e\n$st");
    } finally {
      if (rid != _requestId) return;
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> fetchSubscriptions({int page = 1}) async {
    final int rid = ++_requestId;
    _isLoading = true;
    _message = null;
    _safeNotify();

    try {
      // final token = await Prefs.getString(Prefs.keyAuthToken) ?? "";

      final response = await Api.post("getAllSubscription", {
        "page": page,
        "pageSize": 10,
        "searchText": "",
        // "token": token,
      });

      log("Subscription API Response: $response");

      if (rid != _requestId) return;

      if (response["success"] == true) {
        final List<dynamic> items = response["data"]?["subscription"] ?? [];

        _subscriptions.clear();
        _subscriptions.addAll(items.map((e) => SubscriptionModel.fromJson(e)));

        await Future.wait(
          _subscriptions.map((sub) async {
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
      if (rid != _requestId) return;
      _subscriptions.clear();
      subscriptionsLoaded = true;
      _message = "Error: $e";
      log("fetchSubscriptions err: $e\n$st");
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
