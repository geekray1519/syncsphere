import 'package:path/path.dart' as p;
import 'package:syncsphere/models/sync_enums.dart';
import 'package:syncsphere/models/file_item.dart';

enum ConflictStrategy { keepSource, keepTarget, keepBoth, keepNewer }

class ConflictResolver {
  FileItem resolve(
    FileItem sourceFile,
    FileItem targetFile,
    ConflictStrategy strategy,
  ) {
    switch (strategy) {
      case ConflictStrategy.keepSource:
        return sourceFile.copyWith(syncAction: SyncAction.copyToTarget);
      case ConflictStrategy.keepTarget:
        return targetFile.copyWith(syncAction: SyncAction.copyToSource);
      case ConflictStrategy.keepNewer:
        final bool sourceNewer =
            sourceFile.modifiedAt.millisecondsSinceEpoch >=
            targetFile.modifiedAt.millisecondsSinceEpoch;
        return sourceNewer
            ? sourceFile.copyWith(syncAction: SyncAction.copyToTarget)
            : targetFile.copyWith(syncAction: SyncAction.copyToSource);
      case ConflictStrategy.keepBoth:
        return _keepBoth(sourceFile);
    }
  }

  FileItem _keepBoth(FileItem sourceFile) {
    final String stamp = _timestamp(DateTime.now());
    final String ext = p.extension(sourceFile.name);
    final String stem =
        ext.isEmpty
            ? sourceFile.name
            : sourceFile.name.substring(0, sourceFile.name.length - ext.length);

    final String renamed = '$stem.conflict.$stamp$ext';
    final String dir = p.dirname(sourceFile.path);
    final String relativePath = dir == '.' ? renamed : p.join(dir, renamed);

    return sourceFile.copyWith(
      path: relativePath.replaceAll('\\', '/'),
      name: renamed,
      syncAction: SyncAction.copyToTarget,
    );
  }

  String _timestamp(DateTime time) {
    final String y = time.year.toString().padLeft(4, '0');
    final String m = time.month.toString().padLeft(2, '0');
    final String d = time.day.toString().padLeft(2, '0');
    final String h = time.hour.toString().padLeft(2, '0');
    final String min = time.minute.toString().padLeft(2, '0');
    final String s = time.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }
}
