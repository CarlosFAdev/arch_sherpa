import 'dart:io';

import 'package:arch_sherpa/config/config_loader.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigLoader', () {
    test('uses defaults when no structure.yaml or pubspec config exists', () {
      final root = Directory.systemTemp.createTempSync('arch_sherpa_loader_');
      addTearDown(() => root.deleteSync(recursive: true));

      final result = ConfigLoader().load(projectRoot: root);
      expect(result.source, ConfigSource.defaults);
      expect(result.config.features.basePath, 'lib/features');
      expect(result.config.schemaVersion, 1);
      expect(result.config.deprecations.policy, 'warn');
      expect(result.warnings, isEmpty);
    });

    test('uses pubspec.yaml config when structure.yaml is absent', () {
      final root = Directory.systemTemp.createTempSync('arch_sherpa_loader_');
      addTearDown(() => root.deleteSync(recursive: true));

      File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: sample
flutter_sherpa:
  arch_sherpa:
    state_management:
      type: bloc
''');

      final result = ConfigLoader().load(projectRoot: root);
      expect(result.source, ConfigSource.pubspecYaml);
      expect(result.config.stateManagement.type, 'bloc');
      expect(result.warnings, isEmpty);
    });

    test('structure.yaml overrides pubspec.yaml', () {
      final root = Directory.systemTemp.createTempSync('arch_sherpa_loader_');
      addTearDown(() => root.deleteSync(recursive: true));

      File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: sample
flutter_sherpa:
  arch_sherpa:
    state_management:
      type: bloc
''');
      File('${root.path}/structure.yaml').writeAsStringSync('''
state_management:
  type: riverpod
''');

      final result = ConfigLoader().load(projectRoot: root);
      expect(result.source, ConfigSource.structureYaml);
      expect(result.config.stateManagement.type, 'riverpod');
    });

    test('supports deprecated aliases and reports warnings', () {
      final root = Directory.systemTemp.createTempSync('arch_sherpa_loader_');
      addTearDown(() => root.deleteSync(recursive: true));

      File('${root.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
project:
  coreFolders: [theme, widgets]
features:
  basePath: lib/features
  structure:
    domain: [entities]
    presentation: [controllers]
stateManagement:
  type: riverpod
tests:
  enable: false
''');

      final result = ConfigLoader().load(projectRoot: root);
      expect(result.source, ConfigSource.structureYaml);
      expect(result.config.schemaVersion, 1);
      expect(result.config.project.core, ['theme', 'widgets']);
      expect(result.config.features.basePath, 'lib/features');
      expect(result.config.stateManagement.type, 'riverpod');
      expect(result.warnings, isNotEmpty);
    });
  });
}
