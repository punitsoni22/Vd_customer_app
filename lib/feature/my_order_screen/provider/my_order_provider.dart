import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/models/order_model.dart';
import '../../../core/models/subscription_model.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/signedurl.dart';
import '../../../widget/snack_bar.dart';

class MyOrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  final List<Order> _orders = [];
  final Map<int, String> _orderThumbUrlByOrderId = {};
  final Map<int, String> _subscriptionThumbUrlById = {};
  bool _didLogOrderImageDebug = false;
  bool _didLogSubscriptionImageDebug = false;

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

  String _normalizeProductImagesFolderKey(String key) {
    final lower = key.toLowerCase();
    const needle = 'productimages/';
    final idx = lower.indexOf(needle);
    if (idx == -1) return key;
    return '${key.substring(0, idx)}productImages/${key.substring(idx + needle.length)}';
  }

  Future<String?> _generateSignedOrderProductImageUrl(String rawUrl) async {
    final raw = rawUrl.trim();
    if (raw.isEmpty) return null;

    try {
      final signed = await generateSignedUrl(raw);
      if (signed.trim().isNotEmpty) return signed;
    } catch (_) {}

    final uri = Uri.tryParse(raw);
    final isHttp =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isHttp) return raw;

    var normalized = raw.replaceAll('\\', '/');
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    normalized = _normalizeProductImagesFolderKey(normalized);

    if (normalized != raw) {
      try {
        final signed = await generateSignedUrl(normalized);
        if (signed.trim().isNotEmpty) return signed;
      } catch (_) {}
    }

    if (!normalized.contains('/')) {
      final withFolder = 'productImages/$normalized';
      try {
        final signed = await generateSignedUrl(withFolder);
        if (signed.trim().isNotEmpty) return signed;
      } catch (_) {}
    }

    return null;
  }

  String? _extractFirstImageUrlFromSpecificOrder(dynamic data) {
    if (data is! Map) return null;
    final cart = data['cart'];
    if (cart is! Map) return null;
    final cartDetails = cart['cartDetails'];
    if (cartDetails is! List || cartDetails.isEmpty) return null;
    final first = cartDetails.first;
    if (first is! Map) return null;

    final product = first['product'];
    if (product is Map) {
      final images = product['images'];
      if (images is List && images.isNotEmpty) {
        final img0 = images.first;
        if (img0 is Map && img0['imageUrl'] != null) {
          final v = img0['imageUrl']?.toString().trim();
          if (v != null && v.isNotEmpty) return v;
        }
      }
    }

    final variant = first['productVariants'];
    if (variant is Map) {
      final vProduct = variant['product'];
      if (vProduct is Map) {
        final images = vProduct['images'];
        if (images is List && images.isNotEmpty) {
          final img0 = images.first;
          if (img0 is Map && img0['imageUrl'] != null) {
            final v = img0['imageUrl']?.toString().trim();
            if (v != null && v.isNotEmpty) return v;
          }
        }
      }
    }

    final productImages = first['productImages'];
    if (productImages is Map && productImages['imageUrl'] != null) {
      final v = productImages['imageUrl']?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }

    return null;
  }

  String? _extractFirstImageUrlFromSpecificSubscription(dynamic data) {
    if (data is! Map) return null;
    final products = data['products'];
    if (products is! List || products.isEmpty) return null;
    final first = products.first;
    if (first is! Map) return null;

    final images = first['images'];
    if (images is List && images.isNotEmpty) {
      final img0 = images.first;
      if (img0 is Map && img0['imageUrl'] != null) {
        final v = img0['imageUrl']?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
    }

    final productImages = first['productImages'];
    if (productImages is Map && productImages['imageUrl'] != null) {
      final v = productImages['imageUrl']?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }

    final v = first['imageUrl']?.toString().trim();
    if (v != null && v.isNotEmpty) return v;
    return null;
  }

  Future<void> fetchOrders({int page = 1}) async {
    final int rid = ++_ordersRequestId;
    const pageSize = 10;
    if (page == 1) {
      _isLoading = true;
      _orders.clear();
    } else {
      isMoreOrdersLoading = true;
    }
    _message = null;
    _safeNotify();
    try {
      final response = await Api.post('getAllOrders', {
        "data": {"page": page, "pageSize": pageSize, "searchText": ""},
      });
      log("messageL: $response");
      if (rid != _ordersRequestId) return;
      if (response['success'] == true) {
        int? asInt(dynamic v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        }

        final data = response['data'];
        List<dynamic> items = [];
        Map<String, dynamic> pagination = {};

        if (data is Map<String, dynamic>) {
          final rawItems =
              data['items'] ??
              data['rows'] ??
              data['orders'] ??
              data['order'] ??
              data['list'];
          if (rawItems is List) items = rawItems;

          final rawPagination = data['pagination'];
          if (rawPagination is Map<String, dynamic>) pagination = rawPagination;
        } else if (data is List) {
          items = data;
        }

        currentOrderPage =
            asInt(
              pagination['page'] ??
                  pagination['pageNo'] ??
                  pagination['currentPage'] ??
                  pagination['pageNumber'],
            ) ??
            asInt((data is Map<String, dynamic>) ? data['page'] : null) ??
            page;

        totalOrderPages =
            asInt(
              pagination['totalPages'] ??
                  pagination['totalPage'] ??
                  pagination['pages'],
            ) ??
            asInt((data is Map<String, dynamic>) ? data['totalPages'] : null) ??
            1;

        final totalCount = asInt(
          pagination['totalCount'] ??
              pagination['totalRecords'] ??
              pagination['totalItems'],
        );
        if (totalOrderPages <= 1 && totalCount != null && totalCount > 0) {
          totalOrderPages = (totalCount / pageSize).ceil();
        }

        final newOrders = <Order>[];
        for (final e in items) {
          try {
            if (e is Map<String, dynamic>) {
              newOrders.add(Order.fromJson(e));
            } else if (e is Map) {
              newOrders.add(Order.fromJson(Map<String, dynamic>.from(e)));
            }
          } catch (e, st) {
            log("Order parse failed: $e\n$st");
          }
        }
        _orders.addAll(newOrders);

        await Future.wait(
          newOrders.map((order) async {
            if (rid != _ordersRequestId) return;

            String? fallbackImageUrl = _orderThumbUrlByOrderId[order.orderId];
            var didTryFallbackFetch = false;

            Future<String?> ensureFallbackImageUrl() async {
              if (didTryFallbackFetch) return fallbackImageUrl;
              didTryFallbackFetch = true;
              if (fallbackImageUrl != null && fallbackImageUrl!.isNotEmpty) {
                return fallbackImageUrl;
              }
              try {
                final detailRes = await Api.post('getSpecificOrder', {
                  'data': {'orderId': order.orderId},
                });
                if (rid != _ordersRequestId) return null;
                if (detailRes['success'] == true) {
                  final extracted = _extractFirstImageUrlFromSpecificOrder(
                    detailRes['data'],
                  );
                  if (extracted != null && extracted.isNotEmpty) {
                    fallbackImageUrl = extracted;
                    _orderThumbUrlByOrderId[order.orderId] = extracted;
                  }
                }
              } catch (_) {}
              return fallbackImageUrl;
            }

            final fallbackRaw = await ensureFallbackImageUrl();
            String? signedFallback;
            if (fallbackRaw != null && fallbackRaw.trim().isNotEmpty) {
              try {
                signedFallback = await _generateSignedOrderProductImageUrl(
                  fallbackRaw,
                );
              } catch (_) {}
              if (signedFallback == null || signedFallback.trim().isEmpty) {
                signedFallback = null;
              }
            }

            for (var cartDetail in order.cart.cartDetails) {
              final imageUrl = cartDetail.productImages.imageUrl.trim();

              String? signedUrl;
              if (signedFallback != null) {
                signedUrl = signedFallback;
              }
              if (imageUrl.isNotEmpty) {
                try {
                  signedUrl ??=
                      await _generateSignedOrderProductImageUrl(imageUrl);
                } catch (e) {
                  if (kDebugMode) log("S3 URL failed for $imageUrl: $e");
                }
              }

              if (signedUrl == null || signedUrl.trim().isEmpty) {
                signedUrl = null;
              }

              cartDetail.productImages.signedUrl =
                  (signedUrl == null || signedUrl.trim().isEmpty)
                      ? null
                      : signedUrl;
            }

            if (kDebugMode && !_didLogOrderImageDebug) {
              _didLogOrderImageDebug = true;
              final first = order.cart.cartDetails.isNotEmpty
                  ? order.cart.cartDetails.first
                  : null;
              log(
                'OrderImageDebug orderId=${order.orderId} raw=${first?.productImages.imageUrl} signed=${first?.productImages.signedUrl} fallback=${fallbackImageUrl ?? ""}',
              );
            }
            if (order.invoice != null && order.invoice!.filePath.isNotEmpty) {
              try {
                final signed = await generateSignedUrl(order.invoice!.filePath);
                order.invoice!.signedUrl = signed.trim().isEmpty
                    ? null
                    : signed;
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
    const pageSize = 10;
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
        "data": {"page": page, "pageSize": pageSize, "searchText": ""},
      });
      if (rid != _subscriptionsRequestId) return;

      if (response["success"] == true) {
        int? asInt(dynamic v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        }

        final data = response['data'];
        List<dynamic> items = [];
        Map<String, dynamic> pagination = {};

        if (data is Map<String, dynamic>) {
          final rawItems =
              data['subscription'] ??
              data['subscriptions'] ??
              data['items'] ??
              data['list'];
          if (rawItems is List) items = rawItems;

          final rawPagination = data['pagination'];
          if (rawPagination is Map<String, dynamic>) pagination = rawPagination;
        } else if (data is List) {
          items = data;
        }

        currentSubscriptionPage =
            asInt(
              pagination['page'] ??
                  pagination['pageNo'] ??
                  pagination['currentPage'] ??
                  pagination['pageNumber'],
            ) ??
            asInt((data is Map<String, dynamic>) ? data['page'] : null) ??
            page;

        totalSubscriptionPages =
            asInt(
              pagination['totalPages'] ??
                  pagination['totalPage'] ??
                  pagination['pages'],
            ) ??
            asInt((data is Map<String, dynamic>) ? data['totalPages'] : null) ??
            1;

        final totalCount = asInt(
          pagination['totalCount'] ??
              pagination['totalRecords'] ??
              pagination['totalItems'],
        );
        if (totalSubscriptionPages <= 1 &&
            totalCount != null &&
            totalCount > 0) {
          totalSubscriptionPages = (totalCount / pageSize).ceil();
        }

        final newSubscriptions = items
            .map((e) => SubscriptionModel.fromJson(e))
            .toList();
        _subscriptions.addAll(newSubscriptions);

        await Future.wait(
          newSubscriptions.map((sub) async {
            if (rid != _subscriptionsRequestId) return;

            if (sub.invoice != null && sub.invoice!.invoiceUrl.isNotEmpty) {
              try {
                final signed = await generateSignedUrl(sub.invoice!.invoiceUrl);
                if (signed.trim().isNotEmpty) {
                  sub.invoice!.signedUrl = signed;
                } else {
                  final uri = Uri.tryParse(sub.invoice!.invoiceUrl);
                  final isHttp =
                      uri != null &&
                      uri.hasScheme &&
                      (uri.scheme == 'http' || uri.scheme == 'https');
                  sub.invoice!.signedUrl = isHttp ? sub.invoice!.invoiceUrl : null;
                }
              } catch (e) {
                if (kDebugMode) log("Subscription Invoice S3 URL failed: $e");
                sub.invoice!.signedUrl = null;
              }
            }

            String? fallbackImageUrl = _subscriptionThumbUrlById[sub.id];
            var didTryFallbackFetch = false;

            Future<String?> ensureFallbackImageUrl() async {
              if (didTryFallbackFetch) return fallbackImageUrl;
              didTryFallbackFetch = true;
              if (fallbackImageUrl != null && fallbackImageUrl!.isNotEmpty) {
                return fallbackImageUrl;
              }
              try {
                final detailRes = await Api.post('getSpecificSubscription', {
                  'data': {'id': sub.id},
                });
                if (rid != _subscriptionsRequestId) return null;
                if (detailRes['success'] == true) {
                  final extracted = _extractFirstImageUrlFromSpecificSubscription(
                    detailRes['data'],
                  );
                  if (extracted != null && extracted.isNotEmpty) {
                    fallbackImageUrl = extracted;
                    _subscriptionThumbUrlById[sub.id] = extracted;
                  }
                }
              } catch (_) {}
              return fallbackImageUrl;
            }

            final fallbackRaw = await ensureFallbackImageUrl();
            String? signedFallback;
            if (fallbackRaw != null && fallbackRaw.trim().isNotEmpty) {
              try {
                signedFallback = await _generateSignedOrderProductImageUrl(
                  fallbackRaw,
                );
              } catch (_) {}
              if (signedFallback == null || signedFallback.trim().isEmpty) {
                signedFallback = null;
              }
            }

            for (final product in sub.products) {
              String? signedUrl = signedFallback;
              final raw = product.imageUrl?.trim() ?? '';
              if (raw.isNotEmpty) {
                try {
                  signedUrl ??= await _generateSignedOrderProductImageUrl(raw);
                } catch (e) {
                  if (kDebugMode) log("Product image S3 URL failed: $e");
                }
              }
              product.signedUrl =
                  (signedUrl == null || signedUrl.trim().isEmpty)
                      ? null
                      : signedUrl;
            }

            if (kDebugMode && !_didLogSubscriptionImageDebug) {
              _didLogSubscriptionImageDebug = true;
              final first = sub.products.isNotEmpty ? sub.products.first : null;
              log(
                'SubscriptionImageDebug subId=${sub.id} raw=${first?.imageUrl} signed=${first?.signedUrl} fallback=${fallbackImageUrl ?? ""}',
              );
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

  Future<void> updateSubscriptionStatus(
    BuildContext context, {
    required int subscriptionId,
    required int statusValue,
  }) async {
    try {
      final response = await Api.post('updateSubscriptionStatus', {
        'data': {'id': subscriptionId, 'status': statusValue},
      });

      if (response['success'] == true) {
        final idx = _subscriptions.indexWhere((s) => s.id == subscriptionId);
        if (idx != -1) {
          final sub = _subscriptions[idx];
          _subscriptions[idx] = SubscriptionModel(
            id: sub.id,
            customerName: sub.customerName,
            deliveryFrequencyType: sub.deliveryFrequencyType,
            subscriptionType: sub.subscriptionType,
            startDate: sub.startDate,
            endDate: sub.endDate,
            totalAmount: sub.totalAmount,
            products: sub.products,
            invoice: sub.invoice,
            status: statusValue,
          );
          _safeNotify();
        }

        if (context.mounted) {
          MySnackBar.showSnackBar(
            context,
            response['message']?.toString() ?? 'Subscription updated',
          );
        }
      } else {
        if (context.mounted) {
          MySnackBar.showSnackBar(
            context,
            response['message']?.toString() ?? 'Failed to update subscription',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        MySnackBar.showSnackBar(context, 'Error updating subscription');
      }
    }
  }

  Future<void> cancelOrder(
    BuildContext context, {
    required int orderId,
  }) async {
    try {
      final response = await Api.post('cancelOrder', {
        'data': {'orderId': orderId},
      });

      final dataResponse = response['dataResponse'];
      final returnCode = (dataResponse is Map) ? dataResponse['returnCode'] : null;
      final ok = response['success'] == true || returnCode == 0;
      final msg =
          (dataResponse is Map ? dataResponse['description'] : null)?.toString() ??
              response['message']?.toString() ??
              (ok ? 'Order cancelled' : 'Failed to cancel order');

      if (ok) {
        final idx = _orders.indexWhere((o) => o.orderId == orderId);
        if (idx != -1) {
          final o = _orders[idx];
          _orders[idx] = Order(
            orderId: o.orderId,
            status: 'CANCELLED',
            orderConfirmedDate: o.orderConfirmedDate,
            totalAmount: o.totalAmount,
            discountAmount: o.discountAmount,
            cart: o.cart,
            invoice: o.invoice,
          );
          _safeNotify();
        }
      }

      if (context.mounted) {
        MySnackBar.showSnackBar(context, msg);
      }
    } catch (e) {
      if (context.mounted) {
        MySnackBar.showSnackBar(context, 'Error cancelling order');
      }
    }
  }
}
