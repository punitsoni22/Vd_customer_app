import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/constants/api_endpoints.dart';
import 'package:vd_customer_app/interceptor/dio_interceptor.dart';
import 'package:vd_customer_app/storage/flutter_secure_storage.dart';
import 'package:vd_customer_app/core/services/api_error_handler.dart';

class DioHttp {
  final Dio _dio;
  final String _baseUrl;
  final MySecureStorage _secureStorage;

  DioHttp()
    : _dio = Dio()..interceptors.add(DioInterceptor()),
      _baseUrl = dotenv.env['BASE_URL']!,
      _secureStorage = MySecureStorage();

  Future<Response> _postRequest({
    required BuildContext context,
    required ApiEndpoint endpoint,
    required dynamic data,
    bool wrapData = true,
    Function(String)? onSuccess,
  }) async {
    final url = '$_baseUrl${endpoint.fullPath}';
    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(wrapData ? {'data': data} : data),
      );

      if (onSuccess != null && response.data['data'] is String) {
        onSuccess(response.data['data']);
      }
      return response;
    } on DioException catch (err) {
      if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
        await _secureStorage.deleteToken();
        MySnackBar.showSnackBar(
          context,
          "Session expired. Please login again.",
        );
        context.go(AppRoutes.authScreen);
      }
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> login(
    BuildContext context, {
    required String userName,
  }) async {
    return _postRequest(
      context: context,
      endpoint: ApiEndpoint.login,
      data: {
        "userName": userName,
        "roleUniqueIds": ["DELIVERY_PARTNER"],
      },
      wrapData: true,
    );
  }

  Future<Response> getLatestCartByUserId(BuildContext context) async {
    return _postRequest(
      context: context,
      endpoint: ApiEndpoint.getLatestCartByUserId,
      data: {},
      wrapData: true,
    );
  }

  Future<Response> addEditCart(BuildContext context) async {
    return _postRequest(
      context: context,
      endpoint: ApiEndpoint.addEditCart,
      data: {},
      wrapData: true,
    );
  }
}
