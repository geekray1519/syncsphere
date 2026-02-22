import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class WebAssetExtractor {
  static const List<String> _assets = <String>[
    'index.html',
    'app.js',
    'style.css',
  ];

  static String? _cachedExtractionPath;

  Future<String> extractAssets() async {
    final String? cachedPath = _cachedExtractionPath;
    if (cachedPath != null && await _assetsExist(cachedPath)) {
      return cachedPath;
    }

    final Directory targetDirectory = Directory(
      p.join(Directory.systemTemp.path, 'syncsphere_web_assets'),
    );
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    for (final String assetFile in _assets) {
      final String assetPath = 'assets/web/$assetFile';
      final ByteData byteData = await rootBundle.load(assetPath);
      final Uint8List bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      final File outputFile = File(p.join(targetDirectory.path, assetFile));
      await outputFile.writeAsBytes(bytes, flush: true);
    }

    _cachedExtractionPath = targetDirectory.path;
    return targetDirectory.path;
  }

  Future<bool> _assetsExist(String directoryPath) async {
    for (final String assetFile in _assets) {
      final File file = File(p.join(directoryPath, assetFile));
      if (!await file.exists()) {
        return false;
      }
    }
    return true;
  }
}
