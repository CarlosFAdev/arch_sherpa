import 'dart:io';

import 'package:path/path.dart' as p;

class FileUtilsException implements Exception {
  FileUtilsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FileUtils {
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

  bool createDirectoryIfMissing(String directoryPath) {
    final dir = Directory(directoryPath);
    if (dir.existsSync()) {
      return false;
    }
    dir.createSync(recursive: true);
    return true;
  }

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
