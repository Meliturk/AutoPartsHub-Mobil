import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await _client
        .get(_buildUri(path, query), headers: _headers(token))
        .timeout(AppConfig.apiTimeout);
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await _client
        .get(_buildUri(path, query), headers: _headers(token))
        .timeout(AppConfig.apiTimeout);
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postMap(
    String path,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await _client
        .post(
          _buildUri(path, query),
          headers: _headers(token),
          body: jsonEncode(payload),
        )
        .timeout(AppConfig.apiTimeout);
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> putMap(
    String path,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await _client
        .put(
          _buildUri(path, query),
          headers: _headers(token),
          body: jsonEncode(payload),
        )
        .timeout(AppConfig.apiTimeout);
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await _client
        .post(
          _buildUri(path, query),
          headers: _headers(token, contentType: 'application/x-www-form-urlencoded'),
          body: payload.map((key, value) => MapEntry(key, value?.toString() ?? '')),
        )
        .timeout(AppConfig.apiTimeout);
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    Map<String, dynamic> fields, {
    List<http.MultipartFile>? files,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final uri = _buildUri(path, query);
    final request = http.MultipartRequest('POST', uri);
    
    // Headers
    final headers = _headers(token, contentType: null);
    headers.remove(HttpHeaders.contentTypeHeader); // multipart sets its own content-type
    request.headers.addAll(headers);
    
    // Fields
    fields.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          for (final item in value) {
            request.fields[key] = item.toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Files
    if (files != null) {
      request.files.addAll(files);
    }
    
    final streamedResponse = await _client.send(request).timeout(AppConfig.apiTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> putMultipart(
    String path,
    Map<String, dynamic> fields, {
    List<http.MultipartFile>? files,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final uri = _buildUri(path, query);
    final request = http.MultipartRequest('PUT', uri);
    
    // Headers
    final headers = _headers(token, contentType: null);
    headers.remove(HttpHeaders.contentTypeHeader);
    request.headers.addAll(headers);
    
    // Fields
    fields.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          for (final item in value) {
            request.fields[key] = item.toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Files
    if (files != null) {
      request.files.addAll(files);
    }
    
    final streamedResponse = await _client.send(request).timeout(AppConfig.apiTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeMap(response);
  }

  Map<String, String> _headers(String? token, {String? contentType}) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: contentType ?? 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final base = Uri.parse(_baseUrl);
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final mergedPath = base.path.endsWith('/')
        ? '${base.path.substring(0, base.path.length - 1)}$cleanPath'
        : '${base.path}$cleanPath';

    final params = <String, List<String>>{};
    if (query != null) {
      for (final entry in query.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value == null) continue;
        if (value is Iterable) {
          final items = value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
          if (items.isNotEmpty) {
            params[key] = items;
          }
        } else {
          final text = value.toString();
          if (text.isNotEmpty) {
            params[key] = [text];
          }
        }
      }
    }

    final baseUri = base.replace(path: mergedPath, query: null);
    if (params.isEmpty) return baseUri;

    final queryString = params.entries
        .expand((entry) => entry.value.map((v) => MapEntry(entry.key, v)))
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');

    return baseUri.replace(query: queryString);
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractMessage(response), statusCode: response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException('Unexpected response format.', statusCode: response.statusCode);
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractMessage(response), statusCode: response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw ApiException('Unexpected response format.', statusCode: response.statusCode);
  }

  String _extractMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message != null) return message.toString();
      }
    } catch (_) {}
    return response.body.isNotEmpty ? response.body : 'Request failed.';
  }
}
