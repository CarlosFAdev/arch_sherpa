import 'dart:io';

import 'package:path/path.dart' as p;

import 'config_model.dart';

/// Result of an architecture drift audit.
class AuditResult {
  /// Creates a new audit result.
  AuditResult({
    required this.ok,
    required this.checkedFeatures,
    required this.missingPaths,
  });

  /// Whether the audited feature structure is fully aligned with configuration.
  final bool ok;

  /// Number of feature directories that were checked.
  final int checkedFeatures;

  /// Missing paths required by the configured feature structure.
  final List<String> missingPaths;
}

/// Audits existing feature folders for drift from configured structure.
class ArchitectureAuditor {
  /// Scans feature directories and reports missing configured paths.
  AuditResult audit({
    required Directory projectRoot,
    required ArchSherpaConfig config,
  }) {
    final missing = <String>[];
    final featuresBase =
        Directory(p.join(projectRoot.path, config.features.basePath));
    if (!featuresBase.existsSync()) {
      return AuditResult(ok: true, checkedFeatures: 0, missingPaths: missing);
    }

    final features = featuresBase
        .listSync()
        .whereType<Directory>()
        .where((dir) => p.basename(dir.path).isNotEmpty)
        .toList();

    for (final featureDir in features) {
      final featureName = p.basename(featureDir.path);
      for (final entry in config.features.structure.entries) {
        final sectionPath = p.join(
          config.features.basePath,
          featureName,
          entry.key,
        );
        if (!Directory(p.join(projectRoot.path, sectionPath)).existsSync()) {
          missing.add(sectionPath);
        }

        for (final folder in entry.value) {
          final folderPath = p.join(sectionPath, folder);
          if (!Directory(p.join(projectRoot.path, folderPath)).existsSync()) {
            missing.add(folderPath);
          }
        }
      }
    }

    return AuditResult(
      ok: missing.isEmpty,
      checkedFeatures: features.length,
      missingPaths: missing,
    );
  }
}
