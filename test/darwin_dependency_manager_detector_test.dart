import 'dart:io';

import 'package:arch_sherpa/config/darwin_dependency_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DarwinDependencyManagerDetector', () {
    late Directory tempRoot;

    void writeFile(String relativePath, String contents) {
      final file = File(p.join(tempRoot.path, relativePath));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);
    }

    setUp(() {
      tempRoot =
          Directory.systemTemp.createTempSync('arch_sherpa_darwin_detector_');
    });

    tearDown(() {
      tempRoot.deleteSync(recursive: true);
    });

    test('returns none when no ios or macos structure exists', () {
      writeFile('pubspec.yaml', 'name: sample\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.none);
      expect(result.hasDarwinStructure, isFalse);
    });

    test('returns cocoapods when only Podfile exists', () {
      writeFile('ios/Podfile', '# CocoaPods\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.cocoapods);
      expect(result.cocoaPodsSignals, contains('ios/Podfile'));
    });

    test('returns cocoapods when only podspec exists', () {
      writeFile('ios/sample.podspec', 'Pod::Spec.new\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.cocoapods);
      expect(result.cocoaPodsSignals, contains('ios/sample.podspec'));
    });

    test('returns swiftPackageManager when only Package.swift exists', () {
      writeFile('ios/Package.swift', '// swift-tools-version: 6.0\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.swiftPackageManager);
      expect(result.swiftPackageManagerSignals, contains('ios/Package.swift'));
    });

    test('returns mixed when Podfile and Package.swift both exist', () {
      writeFile('ios/Podfile', '# CocoaPods\n');
      writeFile('ios/Package.swift', '// swift-tools-version: 6.0\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.mixed);
    });

    test('returns none when Flutter app native structure has no metadata', () {
      writeFile('ios/Runner/AppDelegate.swift', 'class AppDelegate {}\n');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.none);
      expect(result.hasDarwinStructure, isTrue);
    });

    test('returns unknown when plugin native structure has no metadata', () {
      writeFile('ios/Classes/SamplePlugin.swift', 'class SamplePlugin {}\n');
      writeFile('pubspec.yaml', '''
name: sample_plugin
dependencies:
  flutter:
    sdk: flutter
flutter:
  plugin:
    platforms:
      ios:
        pluginClass: SamplePlugin
''');

      final result =
          DarwinDependencyManagerDetector().detect(projectRoot: tempRoot);

      expect(result.manager, DarwinDependencyManager.unknown);
      expect(result.hasDarwinStructure, isTrue);
    });

    test('classifies minimal Darwin fixtures', () {
      final fixtureRoot = Directory(
        p.join(
            Directory.current.path, 'test/fixtures/darwin_dependency_manager'),
      );
      final expectedManagers = {
        'dart_cli_no_darwin': DarwinDependencyManager.none,
        'flutter_package_no_plugin': DarwinDependencyManager.none,
        'flutter_app_cocoapods': DarwinDependencyManager.cocoapods,
        'flutter_app_spm': DarwinDependencyManager.swiftPackageManager,
        'flutter_app_mixed': DarwinDependencyManager.mixed,
        'flutter_app_ios_no_dependency_manager_metadata':
            DarwinDependencyManager.none,
        'flutter_plugin_ios_cocoapods': DarwinDependencyManager.cocoapods,
        'flutter_plugin_ios_spm': DarwinDependencyManager.swiftPackageManager,
        'flutter_plugin_ios_mixed': DarwinDependencyManager.mixed,
      };

      for (final entry in expectedManagers.entries) {
        final result = DarwinDependencyManagerDetector().detect(
          projectRoot: Directory(p.join(fixtureRoot.path, entry.key)),
        );

        expect(result.manager, entry.value, reason: entry.key);
      }
    });
  });
}
