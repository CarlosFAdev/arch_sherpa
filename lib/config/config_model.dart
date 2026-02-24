class ArchSherpaConfig {
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

  static const int latestSchemaVersion = 1;

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

class ProjectConfig {
  ProjectConfig({required this.core});

  final List<String> core;
}

class FeaturesConfig {
  FeaturesConfig({required this.basePath, required this.structure});

  final String basePath;
  final Map<String, List<String>> structure;
}

class StateManagementConfig {
  StateManagementConfig({required this.type});

  final String type;
}

class TestsConfig {
  TestsConfig({required this.enabled});

  final bool enabled;
}

class DeprecationsConfig {
  DeprecationsConfig({required this.policy});

  final String policy;
}
