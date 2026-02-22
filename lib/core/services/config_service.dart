import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:syncsphere/models/sync_job.dart';

class ConfigService {
  Future<File> exportConfig(
    List<SyncJob> jobs,
    Map<String, dynamic> settings,
  ) async {
    final Directory directory = await _resolveDownloadDirectory();
    final DateTime now = DateTime.now();
    final String filename =
        'syncsphere_config_${now.year}_${now.month}_${now.day}_${now.millisecondsSinceEpoch}.json';
    final File file = File(p.join(directory.path, filename));

    final Map<String, dynamic> payload = <String, dynamic>{
      'exportedAt': now.toIso8601String(),
      'jobs': jobs.map((SyncJob job) => job.toMap()).toList(),
      'settings': settings,
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return file;
  }

  Future<Map<String, dynamic>?> importConfig() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final String? path = result.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    final String raw = await File(path).readAsString();
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<Directory> _resolveDownloadDirectory() async {
    final Directory? external = await getExternalStorageDirectory();
    if (external != null) {
      final Directory downloads = Directory(p.join(external.path, 'Download'));
      if (!await downloads.exists()) {
        await downloads.create(recursive: true);
      }
      return downloads;
    }

    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory downloads = Directory(p.join(documents.path, 'Download'));
    if (!await downloads.exists()) {
      await downloads.create(recursive: true);
    }
    return downloads;
  }
}
