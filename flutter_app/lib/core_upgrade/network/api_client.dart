flutter pub add http

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../errors/app_exception.dart';

class ApiClient {
  final http.Client client;

  ApiClient({http.Client? client})
      : client = client ?? http.Client();

  Future<dynamic> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await client.get(
      Uri.parse('${Env.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    String? token,
  }) async {
    final response = await client.post(
      Uri.parse('${Env.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw AppException(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
}