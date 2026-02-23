import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:syncsphere/core/server/sync_server.dart';
import 'package:syncsphere/core/server/web_asset_extractor.dart';

/// Provides server state and controls for the SyncSphere HTTP + WebSocket
/// server. Used by the Server Screen to manage the browser-based file sync.
class ServerProvider extends ChangeNotifier {
  ServerProvider();

  static const String serverCrashedMessageJa = 'サーバーが予期せず停止しました';
  static const String serverCrashedMessageEn = 'Server stopped unexpectedly';

  final WebAssetExtractor _assetExtractor = WebAssetExtractor();

  SyncServer? _server;

  bool _isRunning = false;
  String? _serverUrl;
  String? _ipAddress;
  final int _port = 8384;
  int _connectedClients = 0;
  String _syncDir = '';
  String? _lastError;
  bool _isRestarting = false;

  bool get isRunning => _isRunning;
  String? get serverUrl => _serverUrl;
  String? get ipAddress => _ipAddress;
  int get port => _port;
  int get connectedClients => _connectedClients;
  String get syncDir => _syncDir;
  String? get lastError => _lastError;
  set syncDir(String value) {
    if (_syncDir != value) {
      _syncDir = value;
      notifyListeners();
    }
  }

  /// Starts the server, serving web UI and handling WebSocket connections.
  ///
  /// [syncDir] is the directory on the device used for file sync.
  /// If empty, uses the default SyncSphere directory on external storage.
  Future<void> startServer(String syncDir) async {
    if (_isRunning) {
      return;
    }

    final bool hadError = _lastError != null;
    _lastError = null;
    if (hadError) {
      notifyListeners();
    }

    try {
      // Resolve sync directory
      if (syncDir.isEmpty) {
        syncDir = await _getDefaultSyncDir();
      }
      _syncDir = syncDir;

      // Ensure sync directory exists
      final Directory dir = Directory(_syncDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Extract web assets
      final String webRoot = await _assetExtractor.extractAssets();

      // Create SyncServer with resolved paths
      _server = SyncServer(
        webRoot: webRoot,
        syncDir: _syncDir,
        port: _port,
        onClientCountChanged: (int count) {
          _connectedClients = count;
          notifyListeners();
        },
      );

      // Get local IP before starting
      _ipAddress = await _server!.getLocalIpAddress();

      // Start the server
      await _server!.start();

      _isRunning = true;
      if (_ipAddress != null) {
        _serverUrl = 'http://$_ipAddress:$_port';
      }
      _monitorServerUnexpectedStop(_server!);
      notifyListeners();
    } on Exception catch (error) {
      _isRunning = false;
      _isRestarting = false;
      _serverUrl = null;
      _ipAddress = null;
      _connectedClients = 0;
      _server = null;

      final String errorText = error.toString();
      final String normalizedErrorText = errorText.toLowerCase();
      final bool isPortInUse =
          (error is SocketException && error.osError?.errorCode == 98) ||
          normalizedErrorText.contains('address already in use');

      if (isPortInUse) {
        _lastError = 'ポート$_portは使用中です';
      } else {
        _lastError = errorText;
      }

      notifyListeners();
    }
  }

  /// Stops the server and disconnects all clients.
  Future<void> stopServer() async {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    _isRestarting = false;
    final SyncServer? server = _server;
    _server = null;

    await server?.stop();

    _serverUrl = null;
    _ipAddress = null;
    _connectedClients = 0;
    notifyListeners();
  }

  /// Toggles the server on or off.
  Future<void> toggleServer(String syncDir) async {
    if (_isRunning) {
      await stopServer();
    } else {
      await startServer(syncDir);
    }
  }

  void clearError() {
    if (_lastError == null) {
      return;
    }
    _lastError = null;
    notifyListeners();
  }

  Future<String> _getDefaultSyncDir() async {
    try {
      // Try external storage first (Android)
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return p.join(externalDir.path, 'SyncSphere');
      }
    } on Exception {
      // External storage not available
    }

    // Fallback to app documents directory
    final Directory docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, 'SyncSphere');
  }

  @override
  void dispose() {
    if (_isRunning) {
      _isRunning = false;
      _isRestarting = false;
      _server?.stop();
    }
    super.dispose();
  }

  void _monitorServerUnexpectedStop(SyncServer server) {
    final Future<void>? done = server.done;
    if (done == null) {
      return;
    }

    unawaited(
      done.then((_) async {
        if (!_isRunning || _isRestarting || !identical(_server, server)) {
          return;
        }
        await _attemptAutoRestart(server);
      }).catchError((Object _) async {
        if (!_isRunning || _isRestarting || !identical(_server, server)) {
          return;
        }
        await _attemptAutoRestart(server);
      }),
    );
  }

  Future<void> _attemptAutoRestart(SyncServer server) async {
    if (!_isRunning || _isRestarting || !identical(_server, server)) {
      return;
    }

    _isRestarting = true;
    notifyListeners();

    try {
      await server.stop();
      await server.start();

      if (!identical(_server, server)) {
        return;
      }

      _ipAddress = await server.getLocalIpAddress();
      _serverUrl = _ipAddress == null ? null : 'http://$_ipAddress:$_port';
      _connectedClients = server.connectedClients;
      _lastError = null;
      _isRunning = true;
      _monitorServerUnexpectedStop(server);
    } on Exception {
      _lastError = serverCrashedMessageJa;
      _isRunning = false;
      _serverUrl = null;
      _ipAddress = null;
      _connectedClients = 0;
      _server = null;
    } finally {
      _isRestarting = false;
      notifyListeners();
    }
  }
}
