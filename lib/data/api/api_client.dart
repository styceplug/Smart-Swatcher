import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import 'api_checker.dart';

class ApiClient extends GetConnect implements GetxService {
  static int _requestCounter = 0;

  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = appBaseUrl;
    timeout = const Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstants.authToken) ?? "";

    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    sharedPreferences.setString(AppConstants.authToken, token);
    _logLine('[API][AUTH] Header updated with bearer token');
  }

  Future<Response> getData(
    String uri, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) async {
    return _runRequest(
      method: 'GET',
      uri: uri,
      headers: headers ?? _mainHeaders,
      redirectOnUnauthorized: redirectOnUnauthorized,
      action: () => get(uri, headers: headers ?? _mainHeaders),
    );
  }

  Future<Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) async {
    return _runRequest(
      method: 'POST',
      uri: uri,
      headers: headers ?? _mainHeaders,
      body: body,
      redirectOnUnauthorized: redirectOnUnauthorized,
      action: () => post(uri, body, headers: headers ?? _mainHeaders),
    );
  }

  Future<Response> patchData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) async {
    return _runRequest(
      method: 'PATCH',
      uri: uri,
      headers: headers ?? _mainHeaders,
      body: body,
      redirectOnUnauthorized: redirectOnUnauthorized,
      action: () => patch(uri, body, headers: headers ?? _mainHeaders),
    );
  }

  Future<Response> putData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) async {
    return _runRequest(
      method: 'PUT',
      uri: uri,
      headers: headers ?? _mainHeaders,
      body: body,
      redirectOnUnauthorized: redirectOnUnauthorized,
      action: () => put(uri, body, headers: headers ?? _mainHeaders),
    );
  }

  Future<Response> postMultipartData(
    String uri,
    http.MultipartRequest request, {
    bool redirectOnUnauthorized = true,
  }) async {
    final requestId = _nextRequestId();
    final startedAt = DateTime.now();

    try {
      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      headers['Accept'] = 'application/json';
      request.headers.addAll(headers);

      _logRequest(
        requestId: requestId,
        method: 'MULTIPART POST',
        uri: uri,
        headers: request.headers,
        body: {
          'fields': request.fields,
          'files':
              request.files
                  .map(
                    (file) => {
                      'field': file.field,
                      'filename': file.filename,
                      'length': file.length,
                      'contentType': file.contentType.toString(),
                    },
                  )
                  .toList(),
        },
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic body = response.body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {}

      final payload = Response(
        statusCode: response.statusCode,
        body: body,
        statusText: response.reasonPhrase,
      );

      _logResponse(
        requestId: requestId,
        method: 'MULTIPART POST',
        uri: uri,
        startedAt: startedAt,
        response: payload,
      );
      ApiChecker.checkApi(
        payload,
        redirectOnUnauthorized: redirectOnUnauthorized,
      );
      return payload;
    } catch (error, stackTrace) {
      _logFailure(
        requestId: requestId,
        method: 'MULTIPART POST',
        uri: uri,
        startedAt: startedAt,
        error: error,
        stackTrace: stackTrace,
      );
      return Response(statusCode: 1, statusText: error.toString());
    }
  }

  Map<String, String> get mainHeadersForMultipart {
    final h = Map<String, String>.from(_mainHeaders);
    h.remove('Content-Type');
    return h;
  }

  Future<Response> deleteData(
    String uri, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) async {
    return _runRequest(
      method: 'DELETE',
      uri: uri,
      headers: headers ?? _mainHeaders,
      redirectOnUnauthorized: redirectOnUnauthorized,
      action: () => delete(uri, headers: headers ?? _mainHeaders),
    );
  }

  Future<Response> _runRequest({
    required String method,
    required String uri,
    required Map<String, String> headers,
    required bool redirectOnUnauthorized,
    Object? body,
    required Future<Response> Function() action,
  }) async {
    final requestId = _nextRequestId();
    final startedAt = DateTime.now();

    try {
      _logRequest(
        requestId: requestId,
        method: method,
        uri: uri,
        headers: headers,
        body: body,
      );

      final response = await action();

      _logResponse(
        requestId: requestId,
        method: method,
        uri: uri,
        startedAt: startedAt,
        response: response,
      );
      ApiChecker.checkApi(
        response,
        redirectOnUnauthorized: redirectOnUnauthorized,
      );
      return response;
    } catch (error, stackTrace) {
      _logFailure(
        requestId: requestId,
        method: method,
        uri: uri,
        startedAt: startedAt,
        error: error,
        stackTrace: stackTrace,
      );
      return Response(statusCode: 1, statusText: error.toString());
    }
  }

  int _nextRequestId() {
    _requestCounter += 1;
    return _requestCounter;
  }

  String _formatRequestId(int requestId) {
    return requestId.toString().padLeft(4, '0');
  }

  String _resolveUri(String uri) {
    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      return uri;
    }
    return '$baseUrl$uri';
  }

  void _logRequest({
    required int requestId,
    required String method,
    required String uri,
    required Map<String, String> headers,
    Object? body,
  }) {
    final label = _formatRequestId(requestId);
    _logLine('[API][$label][$method] REQUEST ${_resolveUri(uri)}');
    _logLine(
      '[API][$label][$method] HEADERS ${_stringify(_sanitizeForLog(headers))}',
    );
    if (body != null) {
      _logLine(
        '[API][$label][$method] BODY ${_stringify(_sanitizeForLog(body))}',
      );
    }
  }

  void _logResponse({
    required int requestId,
    required String method,
    required String uri,
    required DateTime startedAt,
    required Response response,
  }) {
    final label = _formatRequestId(requestId);
    final duration = DateTime.now().difference(startedAt).inMilliseconds;
    _logLine(
      '[API][$label][$method] RESPONSE ${response.statusCode} ${_resolveUri(uri)} (${duration}ms)',
    );
    if (response.statusText != null && response.statusText!.trim().isNotEmpty) {
      _logLine('[API][$label][$method] STATUS_TEXT ${response.statusText}');
    }
    _logLine(
      '[API][$label][$method] RESPONSE_BODY ${_stringify(_sanitizeForLog(response.body))}',
    );
  }

  void _logFailure({
    required int requestId,
    required String method,
    required String uri,
    required DateTime startedAt,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final label = _formatRequestId(requestId);
    final duration = DateTime.now().difference(startedAt).inMilliseconds;
    _logLine(
      '[API][$label][$method] ERROR ${_resolveUri(uri)} (${duration}ms)',
    );
    _logLine('[API][$label][$method] ERROR_BODY ${error.toString()}');
    _logLine('[API][$label][$method] STACK ${stackTrace.toString()}');
  }

  String _stringify(Object? value) {
    if (value == null) {
      return 'null';
    }

    if (value is String) {
      return value;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static const Set<String> _sensitiveKeys = <String>{
    'authorization',
    'password',
    'otp',
    'token',
  };

  Object? _sanitizeForLog(Object? value, {String? parentKey}) {
    final normalizedKey = parentKey?.toLowerCase().trim();
    if (normalizedKey != null && _sensitiveKeys.contains(normalizedKey)) {
      if (normalizedKey == 'authorization') {
        return 'Bearer [REDACTED]';
      }
      return '[REDACTED]';
    }

    if (value is Map) {
      final sanitized = <String, dynamic>{};
      value.forEach((key, dynamic nestedValue) {
        sanitized[key.toString()] = _sanitizeForLog(
          nestedValue,
          parentKey: key.toString(),
        );
      });
      return sanitized;
    }

    if (value is List) {
      return value
          .map((item) => _sanitizeForLog(item, parentKey: parentKey))
          .toList();
    }

    return value;
  }

  void _logLine(String message) {
    if (!kDebugMode) {
      return;
    }

    const chunkSize = 700;
    if (message.length <= chunkSize) {
      debugPrintSynchronously(message);
      return;
    }

    for (int start = 0; start < message.length; start += chunkSize) {
      final end =
          start + chunkSize < message.length
              ? start + chunkSize
              : message.length;
      debugPrintSynchronously(message.substring(start, end));
    }
  }
}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}
