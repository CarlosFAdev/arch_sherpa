import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:test/test.dart';

void main() {
  group('CLI integration', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('arch_sherpa_cli_');
    });

    tearDown(() {
      tempRoot.deleteSync(recursive: true);
    });

    test('config command succeeds', () async {
      final result = await _runCli(['config'], projectRoot: tempRoot.path);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Resolved configuration'));
    });

    test('check alias succeeds', () async {
      final result = await _runCli(['check'], projectRoot: tempRoot.path);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Configuration is valid and compatible.'));
    });

    test('config check alias succeeds', () async {
      final result = await _runCli(
        ['config', 'check'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Configuration is valid and compatible.'));
    });

    test('config shows deprecation warnings for legacy keys', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(['config'], projectRoot: tempRoot.path);
      expect(result.exitCode, 0);
      expect(
          result.stdout, contains('Warning: Deprecated key "schemaVersion"'));
      expect(
        result.stdout,
        contains('Warning: Deprecated key "stateManagement"'),
      );
    });

    test('config deprecations reports legacy keys explicitly', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(
        ['config', 'deprecations'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Config deprecations report'));
      expect(result.stdout, contains('Deprecated keys'));
    });

    test('fail-on-deprecated blocks non-report commands', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(
        ['--fail-on-deprecated', 'config'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 1);
      expect(result.stderr, contains('E_DEPRECATED_CONFIG'));
    });

    test('missing command with only option returns structured error', () async {
      final result = await _runCli(
        ['--check'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 1);
      expect(result.stderr, contains('E_MISSING_COMMAND'));
    });

    test('fail-on-deprecated still allows config deprecations command',
        () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(
        ['--fail-on-deprecated', 'config', 'deprecations'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Config deprecations report'));
    });

    test('deprecations.policy=error enforces strict mode without CLI flag',
        () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
deprecations:
  policy: error
stateManagement:
  type: riverpod
''');
      final result = await _runCli(['config'], projectRoot: tempRoot.path);
      expect(result.exitCode, 1);
      expect(result.stderr, contains('E_DEPRECATED_CONFIG'));
    });

    test('init and add feature create directories', () async {
      final init = await _runCli(['init'], projectRoot: tempRoot.path);
      expect(init.exitCode, 0);

      final add = await _runCli(
        ['add', 'feature', 'auth'],
        projectRoot: tempRoot.path,
      );
      expect(add.exitCode, 0);
      expect(
        Directory('${tempRoot.path}/lib/features/auth/application')
            .existsSync(),
        isTrue,
      );
      expect(
        File('${tempRoot.path}/lib/features/auth/application/auth_service.dart')
            .existsSync(),
        isTrue,
      );
    });

    test('doctor json output is machine-readable', () async {
      final result = await _runCli(
        ['--json', 'doctor'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('"command": "doctor"'));
      expect(result.stdout, contains('"migration_required"'));
    });

    test('doctor --strict fails when using internal defaults', () async {
      final result = await _runCli(
        ['doctor', '--strict'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 1);
      expect(result.stdout, contains('Profile: strict'));
      expect(result.stdout, contains('[FAIL] explicit_config_source'));
    });

    test('doctor --strict passes with canonical explicit config', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories, usecases]
    presentation: [controllers, pages, widgets]
    data: [repositories, models, datasources]
    application: []
state_management:
  type: riverpod
tests:
  enabled: false
deprecations:
  policy: warn
''');
      final result = await _runCli(
        ['doctor', '--strict'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Profile: strict'));
      expect(result.stdout, contains('[OK] explicit_config_source'));
    });

    test('doctor fails when migration is required', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(['doctor'], projectRoot: tempRoot.path);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('[FAIL] migration_required'));
    });

    test('config migrate dry-run succeeds', () async {
      final result = await _runCli(
        ['--dry-run', 'config', 'migrate'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Config migration complete'));
    });

    test('config migrate can overwrite structure.yaml via --write', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schema_version: 1
state_management:
  type: riverpod
''');

      final result = await _runCli(
        ['config', 'migrate', '--write', 'structure.yaml'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('Overwrote structure.yaml'));
      final written =
          File('${tempRoot.path}/structure.yaml').readAsStringSync();
      expect(written, contains('schema_version: 1'));
      expect(written, contains('features:'));
    });

    test('config migrate --check fails when migration is required', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schemaVersion: 1
stateManagement:
  type: riverpod
''');
      final result = await _runCli(
        ['config', 'migrate', '--check'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 1);
      expect(result.stdout, contains('Migration required.'));
    });

    test('config migrate --check passes when config is canonical', () async {
      final migrate = await _runCli(
        ['config', 'migrate', '--write', 'structure.yaml'],
        projectRoot: tempRoot.path,
      );
      expect(migrate.exitCode, 0);
      final result = await _runCli(
        ['config', 'migrate', '--check'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, contains('No migration required.'));
    });

    test(
        'config migrate --check fails when structure differs from normalized output',
        () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schema_version: 1
state_management:
  type: riverpod
''');
      final result = await _runCli(
        ['config', 'migrate', '--check'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 1);
      expect(result.stdout, contains('structure.yaml differs'));
    });

    test('audit detects drift for missing feature paths', () async {
      await _runCli(['init'], projectRoot: tempRoot.path);
      Directory('${tempRoot.path}/lib/features/profile')
          .createSync(recursive: true);

      final audit = await _runCli(['audit'], projectRoot: tempRoot.path);
      expect(audit.exitCode, 1);
      expect(audit.stdout, contains('Missing paths'));
      expect(audit.stdout, contains('lib/features/profile/domain'));
    });

    test('generates bloc and tests templates when configured', () async {
      File('${tempRoot.path}/structure.yaml').writeAsStringSync('''
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories, usecases]
    presentation: [blocs, pages, widgets]
    data: [repositories, models, datasources]
    application: []
state_management:
  type: bloc
tests:
  enabled: true
''');

      final add = await _runCli(
        ['add', 'feature', 'checkout'],
        projectRoot: tempRoot.path,
      );
      expect(add.exitCode, 0);
      expect(
        File(
          '${tempRoot.path}/lib/features/checkout/presentation/blocs/checkout_bloc.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${tempRoot.path}/test/features/checkout/checkout_feature_test.dart')
            .existsSync(),
        isTrue,
      );
    });

    test('does not overwrite existing generated files', () async {
      final first = await _runCli(
        ['add', 'feature', 'payments'],
        projectRoot: tempRoot.path,
      );
      expect(first.exitCode, 0);

      final target = File(
          '${tempRoot.path}/lib/features/payments/application/payments_service.dart');
      target.writeAsStringSync('// custom');

      final second = await _runCli(
        ['add', 'feature', 'payments'],
        projectRoot: tempRoot.path,
      );
      expect(second.exitCode, 0);
      expect(target.readAsStringSync(), '// custom');
      expect(second.stdout, contains('Skipped'));
    });

    test('numeric-leading feature names generate valid Dart type identifiers',
        () async {
      final result = await _runCli(
        ['add', 'feature', '2fa'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);

      final service = File(
        '${tempRoot.path}/lib/features/2fa/application/2fa_service.dart',
      ).readAsStringSync();
      final controller = File(
        '${tempRoot.path}/lib/features/2fa/presentation/controllers/2fa_controller.dart',
      ).readAsStringSync();
      expect(service, contains('class F2faService {}'));
      expect(controller, contains('class F2faController {}'));
    });

    test('generated templates match snapshots for default auth feature',
        () async {
      final result = await _runCli(
        ['add', 'feature', 'auth'],
        projectRoot: tempRoot.path,
      );
      expect(result.exitCode, 0);

      _expectFileMatchesSnapshot(
        generatedPath:
            '${tempRoot.path}/lib/features/auth/application/auth_service.dart',
        snapshotPath: 'test/snapshots/auth_service.snap',
      );
      _expectFileMatchesSnapshot(
        generatedPath:
            '${tempRoot.path}/lib/features/auth/presentation/controllers/auth_controller.dart',
        snapshotPath: 'test/snapshots/auth_controller.snap',
      );
      _expectFileMatchesSnapshot(
        generatedPath:
            '${tempRoot.path}/lib/features/auth/domain/entities/auth_entity.dart',
        snapshotPath: 'test/snapshots/auth_entity.snap',
      );
    });
  });
}

Future<ProcessResult> _runCli(
  List<String> args, {
  required String projectRoot,
}) {
  final repoRoot = Directory.current.path;
  return Process.run(
    Platform.resolvedExecutable,
    ['run', 'bin/arch_sherpa.dart', '--project-root', projectRoot, ...args],
    workingDirectory: repoRoot,
  );
}

void _expectFileMatchesSnapshot({
  required String generatedPath,
  required String snapshotPath,
}) {
  final repoRoot = Directory.current.path;
  final generated = File(generatedPath).readAsStringSync().trim();
  final snapshot =
      File(p.join(repoRoot, snapshotPath)).readAsStringSync().trim();
  expect(generated, snapshot);
}
