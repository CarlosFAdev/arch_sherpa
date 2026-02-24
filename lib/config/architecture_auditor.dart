import 'dart:io';

import 'package:path/path.dart' as p;

import 'config_model.dart';

class AuditResult {
  AuditResult({
    required this.ok,
    required this.checkedFeatures,
    required this.missingPaths,
  });

  final bool ok;
  final int checkedFeatures;
  final List<String> missingPaths;
}

class ArchitectureAuditor {
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
