import 'package:flutter/foundation.dart';

class FilterEngine {
  FilterEngine({
    String includePatterns = '',
    String excludePatterns = '',
  })  : _includeRules = _parseRules(includePatterns),
        _excludeRules = _parseRules(excludePatterns),
        _caseSensitive =
            !(!kIsWeb && defaultTargetPlatform == TargetPlatform.windows);

  final List<_FilterRule> _includeRules;
  final List<_FilterRule> _excludeRules;
  final bool _caseSensitive;

  bool shouldIncludePath(String relativePath, {bool isDirectory = false}) {
    final String normalizedPath = _normalizePath(relativePath);

    final bool includeMatched = _includeRules.isEmpty ||
        _includeRules.any(
          (_FilterRule rule) => rule.matches(
            normalizedPath,
            isDirectory: isDirectory,
            caseSensitive: _caseSensitive,
          ),
        );
    if (!includeMatched) {
      return false;
    }

    final bool excludeMatched = _excludeRules.any(
      (_FilterRule rule) => rule.matches(
        normalizedPath,
        isDirectory: isDirectory,
        caseSensitive: _caseSensitive,
      ),
    );
    return !excludeMatched;
  }

  bool shouldInclude(
    String filePath,
    List<String> includePatterns,
    List<String> excludePatterns,
  ) {
    final FilterEngine dynamicFilter = FilterEngine(
      includePatterns: includePatterns.join(' | '),
      excludePatterns: excludePatterns.join(' | '),
    );
    return dynamicFilter.shouldIncludePath(filePath);
  }

  static List<_FilterRule> _parseRules(String patterns) {
    if (patterns.trim().isEmpty) {
      return const <_FilterRule>[];
    }

    return patterns
        .split('|')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .map(_FilterRule.fromPattern)
        .toList(growable: false);
  }

  static String _normalizePath(String path) {
    String normalized = path.replaceAll('\\', '/').trim();
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }
}

class _FilterRule {
  const _FilterRule({required this.pattern, required this.folderOnly});

  final String pattern;
  final bool folderOnly;

  factory _FilterRule.fromPattern(String rawPattern) {
    final bool isFolderOnly =
        rawPattern.endsWith('/') || rawPattern.endsWith('\\');
    String normalized = rawPattern.replaceAll('\\', '/').trim();
    if (isFolderOnly) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return _FilterRule(pattern: normalized, folderOnly: isFolderOnly);
  }

  bool matches(
    String candidate, {
    required bool isDirectory,
    required bool caseSensitive,
  }) {
    if (pattern.isEmpty) {
      return false;
    }

    final String source = caseSensitive ? candidate : candidate.toLowerCase();
    final String expected = caseSensitive ? pattern : pattern.toLowerCase();

    if (folderOnly) {
      if (!isDirectory && !source.startsWith('$expected/')) {
        return false;
      }
      return source == expected || source.startsWith('$expected/');
    }

    final RegExp regex = _globToRegex(expected, caseSensitive: caseSensitive);
    return regex.hasMatch(source);
  }

  RegExp _globToRegex(String input, {required bool caseSensitive}) {
    final StringBuffer buffer = StringBuffer('^');
    for (int i = 0; i < input.length; i++) {
      final String char = input[i];
      switch (char) {
        case '*':
          buffer.write('.*');
          break;
        case '?':
          buffer.write('.');
          break;
        default:
          buffer.write(RegExp.escape(char));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString(), caseSensitive: caseSensitive);
  }
}
