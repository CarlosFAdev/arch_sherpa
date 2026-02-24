import 'dart:io';

import 'package:path/path.dart' as p;

/// Exception thrown when a filesystem operation violates safety constraints.
class FileUtilsException implements Exception {
  /// Creates a file utility exception with a human-readable [message].
  FileUtilsException(this.message);

  /// Error description suitable for CLI diagnostics.
  final String message;

  @override
  String toString() => message;
}

/// Filesystem helpers with path traversal protection.
class FileUtils {
  /// Resolves [relativePath] against [projectRootPath] and enforces root bounds.
  ///
  /// Throws [FileUtilsException] if the resolved path escapes the project root.
  String resolveSafePath({
    required String projectRootPath,
    required String relativePath,
  }) {
    final normalizedRoot = p.normalize(p.absolute(projectRootPath));
    final candidate = p.normalize(p.join(normalizedRoot, relativePath));

    if (!_isWithinRoot(normalizedRoot, candidate)) {
      throw FileUtilsException(
        'Path traversal detected: "$relativePath" resolves outside project root.',
      );
    }
    return candidate;
  }

  /// Creates [directoryPath] recursively if it does not exist.
  ///
  /// Returns `true` when created, `false` when already present.
  bool createDirectoryIfMissing(String directoryPath) {
    final dir = Directory(directoryPath);
    if (dir.existsSync()) {
      return false;
    }
    dir.createSync(recursive: true);
    return true;
  }

  /// Writes [contents] to [filePath] only when the file does not exist.
  ///
  /// Returns `true` when written, `false` when skipped.
  bool writeFileIfMissing({
    required String filePath,
    required String contents,
  }) {
    final file = File(filePath);
    if (file.existsSync()) {
      return false;
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
    return true;
  }

  bool _isWithinRoot(String root, String candidate) {
    final rootWithSep =
        root.endsWith(p.separator) ? root : '$root${p.separator}';
    return candidate == root || candidate.startsWith(rootWithSep);
  }
}
