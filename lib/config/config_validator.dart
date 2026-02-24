import 'config_model.dart';

/// Thrown when configuration validation fails.
class ConfigValidationException implements Exception {
  /// Creates a validation exception with a human-readable message.
  ConfigValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validates user configuration and feature names.
class ConfigValidator {
  static final RegExp _folderNamePattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  /// Validates the complete effective configuration.
  void validate(ArchSherpaConfig config) {
    _validateSchemaVersion(config.schemaVersion);
    _validateCore(config.project.core);
    _validateFeaturesBasePath(config.features.basePath);
    _validateFeatureStructure(config.features.structure);
    _validateStateManagement(config.stateManagement.type);
    _validateDeprecationPolicy(config.deprecations.policy);
  }

  void _validateSchemaVersion(int version) {
    if (version <= 0 || version > ArchSherpaConfig.latestSchemaVersion) {
      final expected = ArchSherpaConfig.latestSchemaVersion;
      final requirement =
          expected == 1 ? 'must be 1' : 'must be between 1 and $expected';
      throw ConfigValidationException(
        'Invalid config: schema_version $requirement.',
      );
    }
  }

  void _validateCore(List<String> core) {
    if (core.isEmpty) {
      throw ConfigValidationException(
        'Invalid config: project.core must be a non-empty list of folder names.',
      );
    }
    for (final folder in core) {
      _validateFolderName(folder, field: 'project.core');
    }
  }

  void _validateFeaturesBasePath(String basePath) {
    if (basePath.trim().isEmpty) {
      throw ConfigValidationException(
        'Invalid config: features.base_path must be a non-empty string.',
      );
    }
    _validatePathSegmentString(basePath, field: 'features.base_path');
  }

  void _validateFeatureStructure(Map<String, List<String>> structure) {
    if (structure.isEmpty) {
      throw ConfigValidationException(
        'Invalid config: features.structure must be a non-empty map<String, List<String>>.',
      );
    }

    for (final entry in structure.entries) {
      final section = entry.key.trim();
      if (section.isEmpty) {
        throw ConfigValidationException(
          'Invalid config: features.structure contains an empty section key.',
        );
      }
      _validateFolderName(section, field: 'features.structure key "$section"');
      for (final folder in entry.value) {
        _validateFolderName(folder, field: 'features.structure["$section"]');
      }
    }
  }

  void _validateStateManagement(String value) {
    const allowed = {'riverpod', 'bloc', 'cubit', 'none'};
    if (!allowed.contains(value)) {
      throw ConfigValidationException(
        'Invalid config: state_management.type must be one of riverpod, bloc, cubit, none.',
      );
    }
  }

  void _validateDeprecationPolicy(String value) {
    const allowed = {'warn', 'error'};
    if (!allowed.contains(value)) {
      throw ConfigValidationException(
        'Invalid config: deprecations.policy must be one of warn, error.',
      );
    }
  }

  /// Validates a CLI feature name argument.
  void validateFeatureName(String featureName) {
    if (featureName.trim().isEmpty) {
      throw ConfigValidationException(
        'Invalid feature name: value must be non-empty.',
      );
    }
    _validateFolderName(featureName, field: 'feature name');
  }

  void _validateFolderName(String value, {required String field}) {
    if (value.trim().isEmpty) {
      throw ConfigValidationException(
        'Invalid $field: folder name cannot be empty.',
      );
    }
    if (!_folderNamePattern.hasMatch(value)) {
      throw ConfigValidationException(
        'Invalid $field: "$value" must match [a-zA-Z0-9_-] only.',
      );
    }
    _validateForbiddenFragments(value, field: field);
  }

  void _validatePathSegmentString(String value, {required String field}) {
    final raw = value.trim();
    if (raw.isEmpty) {
      throw ConfigValidationException('Invalid $field: value cannot be empty.');
    }
    if (raw.contains('..') || raw.contains(r'\')) {
      throw ConfigValidationException(
        'Invalid $field: "$raw" cannot contain ".." or "\\".',
      );
    }
    final segments = raw.split('/').where((segment) => segment.isNotEmpty);
    if (segments.isEmpty) {
      throw ConfigValidationException('Invalid $field: value cannot be empty.');
    }
    for (final segment in segments) {
      if (!_folderNamePattern.hasMatch(segment)) {
        throw ConfigValidationException(
          'Invalid $field: path segment "$segment" must match [a-zA-Z0-9_-] only.',
        );
      }
    }
  }

  void _validateForbiddenFragments(String value, {required String field}) {
    if (value.contains('..') || value.contains('/') || value.contains(r'\')) {
      throw ConfigValidationException(
        'Invalid $field: "$value" cannot contain "..", "/" or "\\".',
      );
    }
  }
}
