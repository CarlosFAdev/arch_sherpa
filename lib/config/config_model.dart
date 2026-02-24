/// Canonical Arch Sherpa configuration model.
class ArchSherpaConfig {
  /// Creates a full configuration object.
  ArchSherpaConfig({
    required this.schemaVersion,
    required this.project,
    required this.features,
    required this.stateManagement,
    required this.tests,
    required this.deprecations,
  });

  final int schemaVersion;
  final ProjectConfig project;
  final FeaturesConfig features;
  final StateManagementConfig stateManagement;
  final TestsConfig tests;
  final DeprecationsConfig deprecations;

  /// Latest schema version supported by this tool build.
  static const int latestSchemaVersion = 1;

  /// Default configuration used when no external config is provided.
  factory ArchSherpaConfig.defaults() {
    return ArchSherpaConfig(
      schemaVersion: latestSchemaVersion,
      project: ProjectConfig(
        core: const ['theme', 'widgets', 'utils', 'constants', 'routes'],
      ),
      features: FeaturesConfig(
        basePath: 'lib/features',
        structure: const {
          'domain': ['entities', 'repositories', 'usecases'],
          'presentation': ['controllers', 'pages', 'widgets'],
          'data': ['repositories', 'models', 'datasources'],
          'application': [],
        },
      ),
      stateManagement: StateManagementConfig(type: 'riverpod'),
      tests: TestsConfig(enabled: false),
      deprecations: DeprecationsConfig(policy: 'warn'),
    );
  }

  /// Returns a copy with selected fields replaced.
  ArchSherpaConfig copyWith({
    int? schemaVersion,
    ProjectConfig? project,
    FeaturesConfig? features,
    StateManagementConfig? stateManagement,
    TestsConfig? tests,
    DeprecationsConfig? deprecations,
  }) {
    return ArchSherpaConfig(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      project: project ?? this.project,
      features: features ?? this.features,
      stateManagement: stateManagement ?? this.stateManagement,
      tests: tests ?? this.tests,
      deprecations: deprecations ?? this.deprecations,
    );
  }

  /// Creates configuration from a dynamic map (YAML-decoded data).
  static ArchSherpaConfig fromDynamicMap(Map<dynamic, dynamic> map) {
    final rawSchemaVersion = map['schema_version'];
    final schemaVersion = rawSchemaVersion is int
        ? rawSchemaVersion
        : int.tryParse(rawSchemaVersion?.toString() ?? '') ??
            latestSchemaVersion;

    final projectMap = _asMap(map['project']);
    final featuresMap = _asMap(map['features']);
    final stateMap = _asMap(map['state_management']);
    final testsMap = _asMap(map['tests']);
    final deprecationsMap = _asMap(map['deprecations']);

    final project = ProjectConfig(core: _stringList(projectMap['core']));

    final structure = <String, List<String>>{};
    final rawStructure = _asMap(featuresMap['structure']);
    for (final entry in rawStructure.entries) {
      structure[entry.key.toString()] = _stringList(entry.value);
    }

    final features = FeaturesConfig(
      basePath: (featuresMap['base_path'] ?? '').toString(),
      structure: structure,
    );

    final stateManagement = StateManagementConfig(
      type: (stateMap['type'] ?? '').toString(),
    );

    final tests = TestsConfig(enabled: _asBool(testsMap['enabled']));
    final deprecations = DeprecationsConfig(
      policy: (deprecationsMap['policy'] ?? 'warn').toString(),
    );

    return ArchSherpaConfig(
      schemaVersion: schemaVersion,
      project: project,
      features: features,
      stateManagement: stateManagement,
      tests: tests,
      deprecations: deprecations,
    );
  }

  /// Serializes configuration to a plain map for output/migration.
  static Map<String, dynamic> toMap(ArchSherpaConfig config) {
    return {
      'schema_version': config.schemaVersion,
      'project': {'core': config.project.core},
      'features': {
        'base_path': config.features.basePath,
        'structure': config.features.structure,
      },
      'state_management': {'type': config.stateManagement.type},
      'tests': {'enabled': config.tests.enabled},
      'deprecations': {'policy': config.deprecations.policy},
    };
  }

  static Map<dynamic, dynamic> _asMap(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value;
    }
    return {};
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }
    return value.map((item) => item.toString()).toList();
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
}

/// Project-level scaffold configuration.
class ProjectConfig {
  /// Creates project config.
  ProjectConfig({required this.core});

  /// Core folder names to scaffold under `lib/core`.
  final List<String> core;
}

/// Feature-level scaffold configuration.
class FeaturesConfig {
  /// Creates features config.
  FeaturesConfig({required this.basePath, required this.structure});

  /// Base path for all generated features.
  final String basePath;

  /// Section-to-folder structure map for each feature.
  final Map<String, List<String>> structure;
}

/// Selected state management strategy.
class StateManagementConfig {
  /// Creates state management config.
  StateManagementConfig({required this.type});

  /// State management type (`riverpod`, `bloc`, `cubit`, `none`).
  final String type;
}

/// Test generation settings.
class TestsConfig {
  /// Creates tests config.
  TestsConfig({required this.enabled});

  /// Whether feature test stubs are generated.
  final bool enabled;
}

/// Policy for deprecated-key handling behavior.
class DeprecationsConfig {
  /// Creates deprecations policy config.
  DeprecationsConfig({required this.policy});

  /// Policy value (`warn` or `error`).
  final String policy;
}
