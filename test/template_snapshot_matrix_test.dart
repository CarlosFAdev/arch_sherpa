import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Template snapshot matrix', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('arch_sherpa_matrix_');
    });

    tearDown(() {
      tempRoot.deleteSync(recursive: true);
    });

    test('riverpod generates controller and no feature test when disabled',
        () async {
      _writeStructure(
        tempRoot.path,
        stateType: 'riverpod',
        presentationFolders: ['controllers', 'pages', 'widgets'],
        testsEnabled: false,
      );

      final result =
          await _runCli(['add', 'feature', 'profile'], tempRoot.path);
      expect(result.exitCode, 0);

      _expectSnapshotMatch(
        generatedPath:
            '${tempRoot.path}/lib/features/profile/presentation/controllers/profile_controller.dart',
        snapshotPath: 'test/snapshots/matrix/riverpod_state.snap',
      );
      expect(
        File('${tempRoot.path}/test/features/profile/profile_feature_test.dart')
            .existsSync(),
        isFalse,
      );
    });

    test('bloc generates bloc template and feature test when enabled',
        () async {
      _writeStructure(
        tempRoot.path,
        stateType: 'bloc',
        presentationFolders: ['blocs', 'pages', 'widgets'],
        testsEnabled: true,
      );

      final result =
          await _runCli(['add', 'feature', 'profile'], tempRoot.path);
      expect(result.exitCode, 0);

      _expectSnapshotMatch(
        generatedPath:
            '${tempRoot.path}/lib/features/profile/presentation/blocs/profile_bloc.dart',
        snapshotPath: 'test/snapshots/matrix/bloc_state.snap',
      );
      _expectSnapshotMatch(
        generatedPath:
            '${tempRoot.path}/test/features/profile/profile_feature_test.dart',
        snapshotPath: 'test/snapshots/matrix/feature_test.snap',
      );
    });

    test('cubit generates cubit template and feature test when enabled',
        () async {
      _writeStructure(
        tempRoot.path,
        stateType: 'cubit',
        presentationFolders: ['blocs', 'pages', 'widgets'],
        testsEnabled: true,
      );

      final result =
          await _runCli(['add', 'feature', 'profile'], tempRoot.path);
      expect(result.exitCode, 0);

      _expectSnapshotMatch(
        generatedPath:
            '${tempRoot.path}/lib/features/profile/presentation/blocs/profile_cubit.dart',
        snapshotPath: 'test/snapshots/matrix/cubit_state.snap',
      );
      _expectSnapshotMatch(
        generatedPath:
            '${tempRoot.path}/test/features/profile/profile_feature_test.dart',
        snapshotPath: 'test/snapshots/matrix/feature_test.snap',
      );
    });

    test('none generates no state file', () async {
      _writeStructure(
        tempRoot.path,
        stateType: 'none',
        presentationFolders: ['pages', 'widgets'],
        testsEnabled: false,
      );

      final result =
          await _runCli(['add', 'feature', 'profile'], tempRoot.path);
      expect(result.exitCode, 0);

      expect(
        File(
          '${tempRoot.path}/lib/features/profile/presentation/controllers/profile_controller.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File('${tempRoot.path}/lib/features/profile/presentation/blocs/profile_bloc.dart')
            .existsSync(),
        isFalse,
      );
      expect(
        File('${tempRoot.path}/lib/features/profile/presentation/blocs/profile_cubit.dart')
            .existsSync(),
        isFalse,
      );
    });
  });
}

void _writeStructure(
  String rootPath, {
  required String stateType,
  required List<String> presentationFolders,
  required bool testsEnabled,
}) {
  File('$rootPath/structure.yaml').writeAsStringSync('''
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories, usecases]
    presentation: [${presentationFolders.join(', ')}]
    data: [repositories, models, datasources]
    application: []
state_management:
  type: $stateType
tests:
  enabled: $testsEnabled
deprecations:
  policy: warn
''');
}

Future<ProcessResult> _runCli(List<String> args, String projectRoot) {
  final repoRoot = Directory.current.path;
  return Process.run(
    Platform.resolvedExecutable,
    ['run', 'bin/arch_sherpa.dart', '--project-root', projectRoot, ...args],
    workingDirectory: repoRoot,
  );
}

void _expectSnapshotMatch({
  required String generatedPath,
  required String snapshotPath,
}) {
  final repoRoot = Directory.current.path;
  final generated = File(generatedPath).readAsStringSync().trim();
  final snapshot =
      File(p.join(repoRoot, snapshotPath)).readAsStringSync().trim();
  expect(generated, snapshot);
}
