import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

class FileWatcherService {
  final Map<String, DirectoryWatcher> _watchers = <String, DirectoryWatcher>{};
  final Map<String, StreamSubscription<WatchEvent>> _subscriptions =
      <String, StreamSubscription<WatchEvent>>{};
  final Map<String, StreamController<WatchEvent>> _controllers =
      <String, StreamController<WatchEvent>>{};

  Stream<WatchEvent> watch(String directoryPath) {
    final String key = p.normalize(directoryPath);
    final StreamController<WatchEvent>? existing = _controllers[key];
    if (existing != null) {
      return existing.stream;
    }

    final DirectoryWatcher watcher = DirectoryWatcher(key);
    final StreamController<WatchEvent> controller =
        StreamController<WatchEvent>.broadcast();

    _watchers[key] = watcher;
    _controllers[key] = controller;
    _subscriptions[key] = watcher.events.listen(
      controller.add,
      onError: controller.addError,
    );

    return controller.stream;
  }

  Future<void> stopWatching([String? directoryPath]) async {
    if (directoryPath == null) {
      final List<String> keys = _watchers.keys.toList(growable: false);
      for (final String key in keys) {
        await _stop(key);
      }
      return;
    }

    await _stop(p.normalize(directoryPath));
  }

  Future<void> dispose() async {
    await stopWatching();
  }

  Future<void> _stop(String key) async {
    final StreamSubscription<WatchEvent>? sub = _subscriptions.remove(key);
    await sub?.cancel();

    _watchers.remove(key);
    final StreamController<WatchEvent>? controller = _controllers.remove(key);
    await controller?.close();
  }
}
