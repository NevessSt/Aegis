import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../errors/app_exception.dart';
import '../security/token_storage.dart';
import '../utils/logger.dart';

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<dynamic> get(String endpoint) async {
    return _request('GET', endpoint, null);
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    return _request('POST', endpoint, body);
  }

  Future<dynamic> _request(
      String method, String endpoint, dynamic body) async {
    final accessToken = await _tokenStorage.getToken();

    try {
      final response = await _sendRequest(
        method,
        endpoint,
        body,
        accessToken,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        AppLogger.info("Access token expired. Attempting refresh.");

        final refreshed = await _refreshToken();

        if (!refreshed) {
          throw AppException("Session expired. Please login again.");
        }

        final newAccessToken = await _tokenStorage.getToken();

        final retryResponse = await _sendRequest(
          method,
          endpoint,
          body,
          newAccessToken,
        );

        return _handleResponse(retryResponse);
      }

      return _handleResponse(response);
    } on TimeoutException {
      throw AppException("Request timed out. Try again.");
    } catch (e) {
      AppLogger.error(e.toString());
      throw AppException("Network error. Check connection.");
    }
  }

  Future<http.Response> _sendRequest(
    String method,
    String endpoint,
    dynamic body,
    String? token,
  ) async {
    final uri = Uri.parse('${Env.baseUrl}$endpoint');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (method == 'GET') {
      return _client.get(uri, headers: headers);
    } else {
      return _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _tokenStorage.getToken(); // adjust if separate refresh token

      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('${Env.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _tokenStorage.saveToken(data['accessToken']);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    throw AppException(
        "Error ${response.statusCode}: ${response.body}");
  }
}