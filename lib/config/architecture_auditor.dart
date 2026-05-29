import 'dart:io';

import 'package:path/path.dart' as p;

import 'config_model.dart';
import 'darwin_dependency_manager.dart';

/// Severity for an architecture audit finding.
enum AuditFindingSeverity {
  /// Informational structural context.
  info,

  /// Potential issue that does not fail architecture drift checks.
  warning,
}

/// Non-fatal architecture audit finding.
class AuditFinding {
  /// Creates an audit finding.
  AuditFinding({
    required this.ruleId,
    required this.severity,
    required this.message,
    this.details = const [],
  });

  /// Stable rule identifier.
  final String ruleId;

  /// Finding severity.
  final AuditFindingSeverity severity;

  /// Human-readable finding message.
  final String message;

  /// Optional relative-path details.
  final List<String> details;
}

/// Result of an architecture drift audit.
class AuditResult {
  /// Creates a new audit result.
  AuditResult({
    required this.ok,
    required this.checkedFeatures,
    required this.missingPaths,
    required this.findings,
  });

  /// Whether the audited feature structure is fully aligned with configuration.
  final bool ok;

  /// Number of feature directories that were checked.
  final int checkedFeatures;

  /// Missing paths required by the configured feature structure.
  final List<String> missingPaths;

  /// Non-fatal structural findings.
  final List<AuditFinding> findings;
}

/// Audits existing feature folders for drift from configured structure.
class ArchitectureAuditor {
  /// Scans feature directories and reports missing configured paths.
  AuditResult audit({
    required Directory projectRoot,
    required ArchSherpaConfig config,
  }) {
    final missing = <String>[];
    final darwinFinding = _darwinDependencyManagerFinding(
      DarwinDependencyManagerDetector().detect(projectRoot: projectRoot),
    );
    final findings = <AuditFinding>[
      if (darwinFinding != null) darwinFinding,
    ];
    final featuresBase =
        Directory(p.join(projectRoot.path, config.features.basePath));
    if (!featuresBase.existsSync()) {
      return AuditResult(
        ok: true,
        checkedFeatures: 0,
        missingPaths: missing,
        findings: findings,
      );
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
      findings: findings,
    );
  }

  AuditFinding? _darwinDependencyManagerFinding(
    DarwinDependencyManagerDetection detection,
  ) {
    switch (detection.manager) {
      case DarwinDependencyManager.none:
        return null;
      case DarwinDependencyManager.cocoapods:
        return AuditFinding(
          ruleId: 'darwin.dependency_manager.detected',
          severity: AuditFindingSeverity.info,
          message: 'Darwin native dependency manager detected: CocoaPods.',
          details: detection.cocoaPodsSignals,
        );
      case DarwinDependencyManager.swiftPackageManager:
        return AuditFinding(
          ruleId: 'darwin.dependency_manager.detected',
          severity: AuditFindingSeverity.info,
          message:
              'Darwin native dependency manager detected: Swift Package Manager.',
          details: detection.swiftPackageManagerSignals,
        );
      case DarwinDependencyManager.mixed:
        return AuditFinding(
          ruleId: 'darwin.dependency_manager.detected',
          severity: AuditFindingSeverity.info,
          message:
              'Darwin native dependency manager detected: mixed CocoaPods and Swift Package Manager.',
          details: [
            ...detection.cocoaPodsSignals,
            ...detection.swiftPackageManagerSignals,
          ]..sort(),
        );
      case DarwinDependencyManager.unknown:
        return AuditFinding(
          ruleId: 'darwin.dependency_manager.missing_metadata',
          severity: AuditFindingSeverity.warning,
          message:
              'iOS/macOS native structure detected, but no CocoaPods or Swift Package Manager metadata was found.',
        );
    }
  }
}
