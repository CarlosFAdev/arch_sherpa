import 'dart:io';

import 'package:yaml/yaml.dart';

import 'config_model.dart';

enum ConfigSource { structureYaml, pubspecYaml, defaults }

class ConfigLoadResult {
  ConfigLoadResult({
    required this.config,
    required this.source,
    required this.warnings,
  });

  final ArchSherpaConfig config;
  final ConfigSource source;
  final List<String> warnings;
}

class ConfigLoader {
  ConfigLoadResult load({required Directory projectRoot}) {
    final defaultsMap = ArchSherpaConfig.toMap(ArchSherpaConfig.defaults());

    final structureFile = File('${projectRoot.path}/structure.yaml');
    if (structureFile.existsSync()) {
      final structureMap = _parseYamlFile(structureFile);
      final warnings = _detectDeprecations(structureMap);
      final normalized = _normalizeAliases(structureMap);
      final merged = _deepMerge(defaultsMap, normalized);
      return ConfigLoadResult(
        config: ArchSherpaConfig.fromDynamicMap(merged),
        source: ConfigSource.structureYaml,
        warnings: warnings,
      );
    }

    final pubspecFile = File('${projectRoot.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final pubspecMap = _parseYamlFile(pubspecFile);
      final flutterSherpa = _asMap(pubspecMap['flutter_sherpa']);
      final archSherpa = _asMap(flutterSherpa['arch_sherpa']);
      if (archSherpa.isNotEmpty) {
        final warnings = _detectDeprecations(archSherpa);
        final normalized = _normalizeAliases(archSherpa);
        final merged = _deepMerge(defaultsMap, normalized);
        return ConfigLoadResult(
          config: ArchSherpaConfig.fromDynamicMap(merged),
          source: ConfigSource.pubspecYaml,
          warnings: warnings,
        );
      }
    }

    return ConfigLoadResult(
      config: ArchSherpaConfig.defaults(),
      source: ConfigSource.defaults,
      warnings: const [],
    );
  }

  Map<dynamic, dynamic> _parseYamlFile(File file) {
    final contents = file.readAsStringSync();
    final parsed = loadYaml(contents);
    if (parsed is YamlMap) {
      return _toDynamicMap(parsed);
    }
    if (parsed is Map<dynamic, dynamic>) {
      return parsed;
    }
    return {};
  }

  Map<dynamic, dynamic> _toDynamicMap(YamlMap map) {
    final result = <dynamic, dynamic>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is YamlMap) {
        result[entry.key] = _toDynamicMap(value);
      } else if (value is YamlList) {
        result[entry.key] = value.map((item) {
          if (item is YamlMap) {
            return _toDynamicMap(item);
          }
          return item;
        }).toList();
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  Map<dynamic, dynamic> _deepMerge(
    Map<dynamic, dynamic> base,
    Map<dynamic, dynamic> override,
  ) {
    final result = <dynamic, dynamic>{}..addAll(base);
    for (final entry in override.entries) {
      final key = entry.key;
      final value = entry.value;
      if (result[key] is Map<dynamic, dynamic> &&
          value is Map<dynamic, dynamic>) {
        result[key] = _deepMerge((result[key] as Map<dynamic, dynamic>), value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  Map<dynamic, dynamic> _asMap(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value;
    }
    return {};
  }

  List<String> _detectDeprecations(Map<dynamic, dynamic> map) {
    final warnings = <String>[];
    if (map.containsKey('schemaVersion')) {
      warnings.add('Deprecated key "schemaVersion". Use "schema_version".');
    }
    if (map.containsKey('stateManagement')) {
      warnings.add(
        'Deprecated key "stateManagement". Use "state_management".',
      );
    }

    final features = _asMap(map['features']);
    if (features.containsKey('basePath')) {
      warnings
          .add('Deprecated key "features.basePath". Use "features.base_path".');
    }

    final project = _asMap(map['project']);
    if (project.containsKey('coreFolders')) {
      warnings.add('Deprecated key "project.coreFolders". Use "project.core".');
    }

    final tests = _asMap(map['tests']);
    if (tests.containsKey('enable')) {
      warnings.add('Deprecated key "tests.enable". Use "tests.enabled".');
    }
    return warnings;
  }

  Map<dynamic, dynamic> _normalizeAliases(Map<dynamic, dynamic> input) {
    final map = <dynamic, dynamic>{}..addAll(input);

    if (!map.containsKey('schema_version') &&
        map.containsKey('schemaVersion')) {
      map['schema_version'] = map['schemaVersion'];
    }
    if (!map.containsKey('state_management') &&
        map.containsKey('stateManagement')) {
      map['state_management'] = map['stateManagement'];
    }

    final features = _asMap(map['features']);
    if (features.isNotEmpty) {
      final normalizedFeatures = <dynamic, dynamic>{}..addAll(features);
      if (!normalizedFeatures.containsKey('base_path') &&
          normalizedFeatures.containsKey('basePath')) {
        normalizedFeatures['base_path'] = normalizedFeatures['basePath'];
      }
      map['features'] = normalizedFeatures;
    }

    final project = _asMap(map['project']);
    if (project.isNotEmpty) {
      final normalizedProject = <dynamic, dynamic>{}..addAll(project);
      if (!normalizedProject.containsKey('core') &&
          normalizedProject.containsKey('coreFolders')) {
        normalizedProject['core'] = normalizedProject['coreFolders'];
      }
      map['project'] = normalizedProject;
    }

    final tests = _asMap(map['tests']);
    if (tests.isNotEmpty) {
      final normalizedTests = <dynamic, dynamic>{}..addAll(tests);
      if (!normalizedTests.containsKey('enabled') &&
          normalizedTests.containsKey('enable')) {
        normalizedTests['enabled'] = normalizedTests['enable'];
      }
      map['tests'] = normalizedTests;
    }

    return map;
  }
}
