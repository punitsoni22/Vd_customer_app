import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../utils/prefs/prefs.dart';
import 'api_return_codes.dart';

class Api {
  static const String baseUrl = 'https://api.veedasip.wikdup.in/';

  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await Prefs.getString(Prefs.keyAuthToken);
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    log("this is url: $uri, header: $headers, body: ${jsonEncode(data)}");
    try {
      if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(data),
        );
      } else {
        throw UnsupportedError('Unsupported HTTP method: $method');
      }

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
