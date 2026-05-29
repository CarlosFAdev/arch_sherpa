import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Lightweight Darwin native dependency-manager categories.
enum DarwinDependencyManager {
  /// No iOS/macOS structure was found.
  none,

  /// CocoaPods metadata was found without Swift Package Manager metadata.
  cocoapods,

  /// Swift Package Manager metadata was found without CocoaPods metadata.
  swiftPackageManager,

  /// CocoaPods and Swift Package Manager metadata were both found.
  mixed,

  /// iOS/macOS structure exists but no dependency-manager metadata was found.
  unknown,
}

/// Result of a Darwin dependency-manager structure scan.
class DarwinDependencyManagerDetection {
  /// Creates a detection result.
  const DarwinDependencyManagerDetection({
    required this.manager,
    required this.hasDarwinStructure,
    required this.cocoaPodsSignals,
    required this.swiftPackageManagerSignals,
  });

  /// Detected dependency-manager category.
  final DarwinDependencyManager manager;

  /// Whether any iOS/macOS project structure exists.
  final bool hasDarwinStructure;

  /// Relative paths that indicate CocoaPods metadata.
  final List<String> cocoaPodsSignals;

  /// Relative paths that indicate Swift Package Manager metadata.
  final List<String> swiftPackageManagerSignals;
}

/// Detects only structural Darwin dependency-manager metadata.
///
/// This intentionally does not analyze dependency readiness, plugin support, or
/// migration risk. Those concerns belong to dep_sherpa.
class DarwinDependencyManagerDetector {
  /// Scans [projectRoot] for lightweight CocoaPods and SPM signals.
  DarwinDependencyManagerDetection detect({required Directory projectRoot}) {
    final hasDarwinStructure = _hasDarwinStructure(projectRoot);
    final hasDarwinPluginDeclaration = _hasDarwinPluginDeclaration(projectRoot);
    final cocoaPodsSignals = _findCocoaPodsSignals(projectRoot);
    final swiftPackageManagerSignals =
        _findSwiftPackageManagerSignals(projectRoot);

    final hasCocoaPods = cocoaPodsSignals.isNotEmpty;
    final hasSwiftPackageManager = swiftPackageManagerSignals.isNotEmpty;
    final manager = switch ((
      hasDarwinStructure,
      hasDarwinPluginDeclaration,
      hasCocoaPods,
      hasSwiftPackageManager
    )) {
      (_, _, true, true) => DarwinDependencyManager.mixed,
      (_, _, true, false) => DarwinDependencyManager.cocoapods,
      (_, _, false, true) => DarwinDependencyManager.swiftPackageManager,
      (true, true, false, false) => DarwinDependencyManager.unknown,
      _ => DarwinDependencyManager.none,
    };

    return DarwinDependencyManagerDetection(
      manager: manager,
      hasDarwinStructure: hasDarwinStructure,
      cocoaPodsSignals: cocoaPodsSignals,
      swiftPackageManagerSignals: swiftPackageManagerSignals,
    );
  }

  bool _hasDarwinStructure(Directory projectRoot) {
    return Directory(p.join(projectRoot.path, 'ios')).existsSync() ||
        Directory(p.join(projectRoot.path, 'macos')).existsSync();
  }

  bool _hasDarwinPluginDeclaration(Directory projectRoot) {
    final file = File(p.join(projectRoot.path, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return false;
    }
    final parsed = loadYaml(file.readAsStringSync());
    if (parsed is! YamlMap) {
      return false;
    }
    final flutter = parsed['flutter'];
    if (flutter is! YamlMap) {
      return false;
    }
    final plugin = flutter['plugin'];
    if (plugin is! YamlMap) {
      return false;
    }
    final platforms = plugin['platforms'];
    if (platforms is! YamlMap) {
      return false;
    }
    return platforms.containsKey('ios') ||
        platforms.containsKey('macos') ||
        platforms.containsKey('darwin');
  }

  List<String> _findCocoaPodsSignals(Directory projectRoot) {
    final signals = <String>[];
    for (final platform in const ['ios', 'macos']) {
      final platformDir = Directory(p.join(projectRoot.path, platform));
      if (!platformDir.existsSync()) {
        continue;
      }
      for (final filename in const ['Podfile', 'Podfile.lock']) {
        final file = File(p.join(platformDir.path, filename));
        if (file.existsSync()) {
          signals.add(p.join(platform, filename));
        }
      }
      signals.addAll(_findFilesWithExtension(
        platformDir,
        extension: '.podspec',
        projectRoot: projectRoot,
      ));
    }
    signals.addAll(_findFilesWithExtension(
      projectRoot,
      extension: '.podspec',
      projectRoot: projectRoot,
      maxDepth: 1,
    ));
    signals.sort();
    return signals;
  }

  List<String> _findSwiftPackageManagerSignals(Directory projectRoot) {
    final signals = <String>[];
    for (final directory in [
      projectRoot,
      Directory(p.join(projectRoot.path, 'ios')),
      Directory(p.join(projectRoot.path, 'macos')),
    ]) {
      final file = File(p.join(directory.path, 'Package.swift'));
      if (file.existsSync()) {
        signals.add(p.relative(file.path, from: projectRoot.path));
      }
    }
    signals.sort();
    return signals.toSet().toList();
  }

  List<String> _findFilesWithExtension(
    Directory directory, {
    required String extension,
    required Directory projectRoot,
    int? maxDepth,
  }) {
    if (!directory.existsSync()) {
      return const [];
    }
    final rootSegments = p.split(directory.path).length;
    final signals = <String>[];
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith(extension)) {
        continue;
      }
      if (maxDepth != null &&
          p.split(entity.parent.path).length - rootSegments >= maxDepth) {
        continue;
      }
      signals.add(p.relative(entity.path, from: projectRoot.path));
    }
    return signals;
  }
}
