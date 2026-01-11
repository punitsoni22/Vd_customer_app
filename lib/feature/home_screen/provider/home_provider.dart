import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  final List<Product> _homeProducts = [];

  // Exposed read-only API
  bool get isLoading => _isLoading;

  String? get message => _message;

  List<Product> get homeProducts => UnmodifiableListView(_homeProducts);

  // Guard against out-of-order responses
  int _requestId = 0;
  bool _hasLoaded = false;

  // Disposal guard for safe notifications
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchHomeProducts(Map<String, dynamic> requestData, {bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    final int rid = ++_requestId;

    _isLoading = true;
    _message = null;
    _safeNotify();

    try {
      final response = await Api.post('getAllProducts', requestData);
      if (rid != _requestId) return;
      final bool ok = response['success'] == true;
      final List<dynamic> items = response['data']?['items'] ?? const [];
      _homeProducts
        ..clear()
        ..addAll(items.map((e) => Product.fromJson(e)));

      if (!ok) {
        _homeProducts.clear();
        _message = response['message'] ?? "Failed to fetch products";
      } else {
        _message = response['message'] ?? "Products fetched successfully";
        _hasLoaded = true;

        // Parallel signed URL generation (fast)
        await Future.wait(
          _homeProducts.map((product) async {
            // Only process images that need signing
            final futures = product.images
                .where(
                  (img) =>
                      img.rawImageUrl.isNotEmpty &&
                      (img.signedUrl == null || img.signedUrl!.isEmpty),
                )
                .map((img) async {
                  try {
                    img.signedUrl = await generateSignedUrl(img.rawImageUrl);
                  } catch (e, st) {
                    // Non-fatal: keep going even if one image fails
                    if (kDebugMode)
                      log("Signed URL failed for ${img.rawImageUrl}: $e\n$st");
                  }
                })
                .toList();
            await Future.wait(futures);
          }),
        );
      }
    } catch (e, st) {
      if (rid != _requestId) return; // stale response, ignore
      _homeProducts.clear();
      _message = "Exception: $e";
      if (kDebugMode) log("Home fetch error: $e\n$st");
    } finally {
      if (rid != _requestId) return; // stale response, ignore
      _isLoading = false;
      _safeNotify();
    }
  }

  void clearMessage() {
    _message = null;
    _safeNotify();
  }
}
