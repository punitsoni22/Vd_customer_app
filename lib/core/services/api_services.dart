import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:vd_customer_app/core/services/api_return_codes.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart'; // prefs helper for token

class Api {
  static const String baseUrl = 'https://devbackend.veedasip.com/api';
  static Future<String?>? _refreshFuture;

  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await Prefs.getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      if (method == 'POST') {
        print("this insiode post: $data");
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(data),
        );
      } else {
        throw UnsupportedError('Unsupported HTTP method: $method');
      }

      log(
        'Response ($method $endpoint): ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final dataResponse = decoded["dataResponse"];
        final data = decoded["data"];

        final int returnCode = dataResponse["returnCode"];
        final String description = dataResponse["description"];

        if (returnCode == ReturnCodes.R_SUCCESS.value ||
            returnCode == ReturnCodes.R_CREATED.value) {
          return {"success": true, "message": description, "data": data};
        } else {
          return {"success": false, "message": description, "code": returnCode};
        }
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      log('Error ($method $endpoint): $e');
      return {"success": false, "message": "Exception: $e"};
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await _makeRequest('POST', endpoint, data: data);
  }
}
