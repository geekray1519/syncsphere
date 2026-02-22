import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class SyncthingApiClient {
  SyncthingApiClient(
    this.apiKey, {
    this.host = 'localhost',
    this.port = 8384,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String host;
  final int port;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> get _headers => <String, String>{
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> getSystemStatus() {
    return _requestForMap('GET', '/rest/system/status');
  }

  Future<Map<String, dynamic>> getConfig() {
    return _requestForMap('GET', '/rest/config');
  }

  Future<Map<String, dynamic>> setConfig(Map<String, dynamic> config) {
    return _requestForMap('POST', '/rest/config', body: config);
  }

  Future<Map<String, dynamic>> getConnections() {
    return _requestForMap('GET', '/rest/system/connections');
  }

  Future<Map<String, dynamic>> getDbStatus(String folderId) {
    return _requestForMap(
      'GET',
      '/rest/db/status',
      queryParameters: <String, String>{'folder': folderId},
    );
  }

  Future<List<Map<String, dynamic>>> getEvents({
    int sinceId = 0,
    int limit = 100,
  }) {
    return _requestForList(
      'GET',
      '/rest/events',
      queryParameters: <String, String>{
        'since': sinceId.toString(),
        'limit': limit.toString(),
      },
    );
  }

  Future<Map<String, dynamic>> getDeviceStatistics() {
    return _requestForMap('GET', '/rest/stats/device');
  }

  Future<Map<String, dynamic>> getFolderStatistics() {
    return _requestForMap('GET', '/rest/stats/folder');
  }

  Future<Map<String, dynamic>> scanFolder(String folderId) {
    return _requestForMap(
      'POST',
      '/rest/db/scan',
      queryParameters: <String, String>{'folder': folderId},
    );
  }

  Future<Map<String, dynamic>> pauseDevice(String deviceId) {
    return _requestForMap(
      'POST',
      '/rest/system/pause',
      queryParameters: <String, String>{'device': deviceId},
    );
  }

  Future<Map<String, dynamic>> resumeDevice(String deviceId) {
    return _requestForMap(
      'POST',
      '/rest/system/resume',
      queryParameters: <String, String>{'device': deviceId},
    );
  }

  Future<Map<String, dynamic>> getSystemVersion() {
    return _requestForMap('GET', '/rest/system/version');
  }

  Future<Map<String, dynamic>> restart() {
    return _requestForMap('POST', '/rest/system/restart');
  }

  Future<Map<String, dynamic>> shutdown() {
    return _requestForMap('POST', '/rest/system/shutdown');
  }

  Future<Map<String, dynamic>> _requestForMap(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final dynamic json = await _request(
      method,
      path,
      queryParameters: queryParameters,
      body: body,
    );
    if (json is Map) {
      return Map<String, dynamic>.from(json);
    }
    throw SyncthingApiException('Expected JSON object response from $path.');
  }

  Future<List<Map<String, dynamic>>> _requestForList(
    String method,
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final dynamic json = await _request(
      method,
      path,
      queryParameters: queryParameters,
    );
    if (json is! List) {
      throw SyncthingApiException('Expected JSON array response from $path.');
    }

    return json.map((dynamic item) {
      if (item is! Map) {
        throw SyncthingApiException('Invalid JSON array item in $path response.');
      }
      return Map<String, dynamic>.from(item);
    }).toList(growable: false);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final Uri uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: path,
      queryParameters: queryParameters,
    );

    try {
      final http.Response response;
      final String? encodedBody = body == null ? null : jsonEncode(body);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: _headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: _headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: _headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: _headers).timeout(_timeout);
          break;
        default:
          throw SyncthingApiException('Unsupported HTTP method: $method');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SyncthingApiException(
          'Syncthing API request failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      final String responseBody = response.body.trim();
      if (responseBody.isEmpty) {
        return <String, dynamic>{};
      }

      return jsonDecode(responseBody);
    } on TimeoutException catch (error) {
      throw SyncthingApiException('Request to $uri timed out after 30 seconds: $error');
    } on SocketException catch (error) {
      throw SyncthingApiException('Failed to connect to Syncthing at $uri: $error');
    } on HttpException catch (error) {
      throw SyncthingApiException('HTTP error while calling $uri: $error');
    } on FormatException catch (error) {
      throw SyncthingApiException('Invalid JSON from Syncthing at $uri: $error');
    } catch (error) {
      if (error is SyncthingApiException) {
        rethrow;
      }
      throw SyncthingApiException('Unexpected API error for $uri: $error');
    }
  }

  void close() {
    _client.close();
  }
}

class SyncthingApiException implements Exception {
  SyncthingApiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('SyncthingApiException: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write(' response: $responseBody');
    }
    return buffer.toString();
  }
}
