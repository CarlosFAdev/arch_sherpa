import 'dart:convert';
import 'dart:io';

import '../utils/file_utils.dart';
import 'config_model.dart';

/// Result of running a config migration operation.
class ConfigMigrationResult {
  /// Creates a migration result.
  ConfigMigrationResult({
    required this.beforeVersion,
    required this.afterVersion,
    required this.written,
    required this.outputPath,
    required this.yaml,
    required this.overwroteExisting,
  });

  /// Schema version before migration.
  final int beforeVersion;

  /// Schema version after migration.
  final int afterVersion;

  /// Whether output was written to disk.
  final bool written;

  /// Relative output file path used by migration.
  final String outputPath;

  /// Migrated configuration serialized as YAML.
  final String yaml;

  /// Whether migration overwrote an existing output file.
  final bool overwroteExisting;
}

/// Produces migrated/normalized structure config output.
class ConfigMigrator {
  /// Creates a migrator with optional file utility overrides.
  ConfigMigrator({FileUtils? fileUtils})
      : _fileUtils = fileUtils ?? FileUtils();

  final FileUtils _fileUtils;

  /// Migrates the provided config and optionally writes the result to disk.
  ConfigMigrationResult migrate({
    required Directory projectRoot,
    required ArchSherpaConfig config,
    bool writeToFile = true,
    String outputPath = 'structure.migrated.yaml',
    bool overwriteExisting = false,
  }) {
    final migrated = config.copyWith(
      schemaVersion: ArchSherpaConfig.latestSchemaVersion,
    );
    final yaml = _toYaml(ArchSherpaConfig.toMap(migrated));
    final absoluteOutputPath = _fileUtils.resolveSafePath(
      projectRootPath: projectRoot.path,
      relativePath: outputPath,
    );

    var written = false;
    var overwroteExisting = false;
    if (writeToFile) {
      final outFile = File(absoluteOutputPath);
      final exists = outFile.existsSync();
      if (!exists || overwriteExisting) {
        outFile.writeAsStringSync(yaml);
        written = true;
        overwroteExisting = exists;
      }
    }

    return ConfigMigrationResult(
      beforeVersion: config.schemaVersion,
      afterVersion: migrated.schemaVersion,
      written: written,
      outputPath: outputPath,
      yaml: yaml,
      overwroteExisting: overwroteExisting,
    );
  }

  String _toYaml(Map<String, dynamic> data, {int indent = 0}) {
    final buffer = StringBuffer();
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in entries) {
      final key = entry.key;
      final value = entry.value;
      final padding = '  ' * indent;

      if (value is Map) {
        buffer.writeln('$padding$key:');
        buffer.write(
            _toYaml(Map<String, dynamic>.from(value), indent: indent + 1));
      } else if (value is List) {
        if (value.isEmpty) {
          buffer.writeln('$padding$key: []');
        } else {
          buffer.writeln('$padding$key:');
          for (final item in value) {
            if (item is Map) {
              buffer.writeln('${'  ' * (indent + 1)}-');
              final child = _toYaml(
                Map<String, dynamic>.from(item.cast<String, dynamic>()),
                indent: indent + 2,
              );
              buffer.write(child);
            } else {
              buffer.writeln('${'  ' * (indent + 1)}- ${_scalar(item)}');
            }
          }
        }
      } else {
        buffer.writeln('$padding$key: ${_scalar(value)}');
      }
    }
    return buffer.toString();
  }

  String _scalar(dynamic value) {
    if (value is num || value is bool) {
      return value.toString();
    }
    final text = value?.toString() ?? '';
    if (text.isEmpty ||
        text.contains(':') ||
        text.contains('#') ||
        text.contains('"')) {
      return jsonEncode(text);
    }
    return text;
  }
}
