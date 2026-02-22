import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'syncthing_api_client.dart';
import 'syncthing_config.dart';

class SyncthingManager extends ChangeNotifier {
  SyncthingManager({SyncthingConfig? config}) : _config = config ?? SyncthingConfig();

  Process? _process;
  bool _isRunning = false;
  SyncthingApiClient? _apiClient;
  final SyncthingConfig _config;

  bool get isRunning => _isRunning;
  SyncthingApiClient? get apiClient => _apiClient;

  Future<void> start({String? binaryPath}) async {
    if (_isRunning) {
      await ensureApiReady();
      return;
    }

    final String resolvedBinaryPath = binaryPath ?? await getSyncthingBinaryPath();
    final File binary = File(resolvedBinaryPath);
    if (!await binary.exists()) {
      throw FileSystemException('Syncthing binary not found.', resolvedBinaryPath);
    }

    final String configPath = await _config.getConfigPath();
    final Directory configDirectory = File(configPath).parent;
    await configDirectory.create(recursive: true);

    try {
      final Process process = await Process.start(
        resolvedBinaryPath,
        <String>[
          'serve',
          '--no-browser',
          '--home',
          configDirectory.path,
        ],
        workingDirectory: configDirectory.path,
      );

      process.stdout.drain<void>();
      process.stderr.drain<void>();

      _process = process;
      _setRunning(true);

      unawaited(
        process.exitCode.then((_) {
          if (identical(_process, process)) {
            _process = null;
            _apiClient?.close();
            _apiClient = null;
            _setRunning(false);
          }
        }),
      );

      final String apiKey = await _waitForApiKey();
      _apiClient = SyncthingApiClient(apiKey);
      await ensureApiReady();
    } catch (error) {
      _process?.kill();
      _process = null;
      _apiClient?.close();
      _apiClient = null;
      _setRunning(false);
      rethrow;
    }
  }

  Future<void> stop() async {
    final SyncthingApiClient? client = _apiClient;
    if (client != null) {
      try {
        await client.shutdown();
      } catch (_) {
        // Fallback to direct process termination.
      }
    }

    final Process? process = _process;
    _apiClient?.close();
    _apiClient = null;
    _process = null;

    if (process != null) {
      try {
        await process.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        process.kill(ProcessSignal.sigterm);
        try {
          await process.exitCode.timeout(const Duration(seconds: 3));
        } on TimeoutException {
          process.kill(ProcessSignal.sigkill);
        }
      }
    }

    _setRunning(false);
  }

  Future<bool> isInstalled() async {
    final String binaryPath = await getSyncthingBinaryPath();
    return File(binaryPath).exists();
  }

  Future<String> getSyncthingBinaryPath() async {
    if (Platform.isWindows) {
      final String executableDir = _directoryName(Platform.resolvedExecutable);
      final List<String> candidates = <String>[
        '$executableDir${Platform.pathSeparator}syncthing.exe',
        '${Directory.current.path}${Platform.pathSeparator}syncthing.exe',
        '${Directory.current.path}${Platform.pathSeparator}bin${Platform.pathSeparator}syncthing.exe',
      ];

      for (final String candidate in candidates) {
        if (await File(candidate).exists()) {
          return candidate;
        }
      }

      return candidates.first;
    }

    if (Platform.isAndroid) {
      final Directory appSupportDirectory = await getApplicationSupportDirectory();
      final List<String> candidates = <String>[
        '${appSupportDirectory.path}${Platform.pathSeparator}syncthing',
        '${appSupportDirectory.path}${Platform.pathSeparator}bin${Platform.pathSeparator}syncthing',
      ];
      for (final String candidate in candidates) {
        if (await File(candidate).exists()) {
          return candidate;
        }
      }
      return candidates.first;
    }

    return 'syncthing';
  }

  Future<void> ensureApiReady({
    int maxRetries = 30,
    Duration retryInterval = const Duration(seconds: 1),
  }) async {
    final SyncthingApiClient? client = _apiClient;
    if (client == null) {
      throw StateError('Syncthing API client is not initialized.');
    }

    Object? lastError;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await client.getSystemStatus();
        return;
      } catch (error) {
        lastError = error;
      }

      await Future<void>.delayed(retryInterval);
    }

    throw TimeoutException(
      'Syncthing API did not become ready after $maxRetries retries. Last error: $lastError',
    );
  }

  Future<String> _waitForApiKey({
    int maxRetries = 15,
    Duration retryInterval = const Duration(seconds: 1),
  }) async {
    String apiKey = '';
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      apiKey = await _config.getApiKey();
      if (apiKey.isNotEmpty) {
        return apiKey;
      }
      await Future<void>.delayed(retryInterval);
    }

    throw StateError('Syncthing API key is not available in config.xml.');
  }

  String _directoryName(String path) {
    final int index = path.lastIndexOf(Platform.pathSeparator);
    if (index == -1) {
      return '.';
    }
    return path.substring(0, index);
  }

  void _setRunning(bool value) {
    if (_isRunning == value) {
      return;
    }
    _isRunning = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
