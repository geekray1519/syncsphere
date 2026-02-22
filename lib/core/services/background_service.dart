import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:syncsphere/providers/run_conditions_provider.dart';

typedef BackgroundSyncCallback = Future<void> Function();

class BackgroundService {
  BackgroundService({
    required RunConditionsProvider runConditionsProvider,
    required BackgroundSyncCallback onTick,
  })  : _runConditionsProvider = runConditionsProvider,
        _onTick = onTick;

  final RunConditionsProvider _runConditionsProvider;
  final BackgroundSyncCallback _onTick;

  Timer? _timer;
  bool _tickInProgress = false;

  bool get isRunning => _timer?.isActive ?? false;

  void start(Duration interval) {
    stop();
    _timer = Timer.periodic(interval, (_) async {
      if (_tickInProgress) {
        return;
      }

      _tickInProgress = true;
      try {
        await _runConditionsProvider.refreshCanSync();
        if (!_runConditionsProvider.canSync) {
          return;
        }
        await _onTick();
      } catch (error, stackTrace) {
        debugPrint('[BackgroundService] Sync tick failed: $error');
        debugPrint(stackTrace.toString());
      } finally {
        _tickInProgress = false;
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
