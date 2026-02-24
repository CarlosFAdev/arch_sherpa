import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/config_model.dart';
import '../utils/file_utils.dart';

class FeatureGenerationResult {
  FeatureGenerationResult({
    required this.createdPaths,
    required this.skippedPaths,
  });

  final List<String> createdPaths;
  final List<String> skippedPaths;
}

class FeatureGenerator {
  FeatureGenerator({FileUtils? fileUtils})
      : _fileUtils = fileUtils ?? FileUtils();

  final FileUtils _fileUtils;

  FeatureGenerationResult generate({
    required Directory projectRoot,
    required ArchSherpaConfig config,
    required String featureName,
    bool dryRun = false,
  }) {
    final created = <String>[];
    final skipped = <String>[];
    final rootPath = projectRoot.path;

    final featureRoot = p.join(config.features.basePath, featureName);
    final featureRootAbsolute = _fileUtils.resolveSafePath(
      projectRootPath: rootPath,
      relativePath: featureRoot,
    );
    final featureRootExists = Directory(featureRootAbsolute).existsSync();
    final featureRootCreated = dryRun
        ? !featureRootExists
        : _fileUtils.createDirectoryIfMissing(featureRootAbsolute);
    (featureRootCreated ? created : skipped).add(featureRoot);

    for (final entry in config.features.structure.entries) {
      final section = entry.key;
      final folders = entry.value;

      final sectionPath = p.join(featureRoot, section);
      final sectionAbsolute = _fileUtils.resolveSafePath(
        projectRootPath: rootPath,
        relativePath: sectionPath,
      );
      final sectionExists = Directory(sectionAbsolute).existsSync();
      final sectionCreated = dryRun
          ? !sectionExists
          : _fileUtils.createDirectoryIfMissing(sectionAbsolute);
      (sectionCreated ? created : skipped).add(sectionPath);

      for (final folder in folders) {
        final folderPath = p.join(sectionPath, folder);
        final folderAbsolute = _fileUtils.resolveSafePath(
          projectRootPath: rootPath,
          relativePath: folderPath,
        );
        final folderExists = Directory(folderAbsolute).existsSync();
        final folderCreated = dryRun
            ? !folderExists
            : _fileUtils.createDirectoryIfMissing(folderAbsolute);
        (folderCreated ? created : skipped).add(folderPath);
      }
    }

    final templates = _featureTemplates(
      featureName: featureName,
      stateType: config.stateManagement.type,
      testsEnabled: config.tests.enabled,
      structure: config.features.structure,
    );
    for (final entry in templates.entries) {
      final relative = entry.key;
      final absolute = _fileUtils.resolveSafePath(
        projectRootPath: rootPath,
        relativePath: relative,
      );
      final exists = File(absolute).existsSync();
      final wrote = dryRun
          ? !exists
          : _fileUtils.writeFileIfMissing(
              filePath: absolute, contents: entry.value);
      (wrote ? created : skipped).add(relative);
    }

    return FeatureGenerationResult(
      createdPaths: created,
      skippedPaths: skipped,
    );
  }

  Map<String, String> _featureTemplates({
    required String featureName,
    required String stateType,
    required bool testsEnabled,
    required Map<String, List<String>> structure,
  }) {
    final snake = _toSnakeCase(featureName);
    final pascal = _toValidTypeName(_toPascalCase(featureName));
    final root = 'lib/features/$featureName';
    final templates = <String, String>{
      '$root/domain/entities/${snake}_entity.dart': '''
class ${pascal}Entity {}
''',
      '$root/domain/repositories/${snake}_repository.dart': '''
abstract class ${pascal}Repository {}
''',
      '$root/domain/usecases/get_$snake.dart': '''
class Get$pascal {}
''',
      '$root/data/models/${snake}_model.dart': '''
class ${pascal}Model {}
''',
      '$root/data/repositories/${snake}_repository_impl.dart': '''
import '../../domain/repositories/${snake}_repository.dart';

class ${pascal}RepositoryImpl implements ${pascal}Repository {}
''',
      '$root/data/datasources/${snake}_datasource.dart': '''
abstract class ${pascal}Datasource {}
''',
      '$root/presentation/pages/${snake}_page.dart': '''
class ${pascal}Page {}
''',
      '$root/presentation/widgets/${snake}_view.dart': '''
class ${pascal}View {}
''',
      '$root/application/${snake}_service.dart': '''
class ${pascal}Service {}
''',
    };

    switch (stateType) {
      case 'riverpod':
        final stateFolder = _preferredRiverpodFolder(structure);
        templates['$root/presentation/$stateFolder/${snake}_controller.dart'] =
            '''
class ${pascal}Controller {}
''';
        break;
      case 'bloc':
      case 'cubit':
        final stateFolder = _preferredBlocFolder(structure);
        templates['$root/presentation/$stateFolder/${snake}_$stateType.dart'] =
            '''
class $pascal${_toPascalCase(stateType)} {}
''';
        break;
      case 'none':
        break;
    }

    if (testsEnabled) {
      templates['test/features/$featureName/${snake}_feature_test.dart'] = '''
void main() {
  // TODO: implement $pascal feature tests.
}
''';
    }

    return templates;
  }

  String _toSnakeCase(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (isUpper && i > 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString().replaceAll('-', '_');
  }

  String _toPascalCase(String input) {
    final words = input
        .replaceAll('-', '_')
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}');
    return words.join();
  }

  String _toValidTypeName(String candidate) {
    if (candidate.isEmpty) {
      return 'Feature';
    }
    final normalized = candidate.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
    if (normalized.isEmpty) {
      return 'Feature';
    }
    final startsWithDigit = RegExp(r'^[0-9]').hasMatch(normalized);
    return startsWithDigit ? 'F$normalized' : normalized;
  }

  String _preferredRiverpodFolder(Map<String, List<String>> structure) {
    final presentation = structure['presentation'] ?? const <String>[];
    if (presentation.contains('controllers')) {
      return 'controllers';
    }
    if (presentation.contains('providers')) {
      return 'providers';
    }
    return 'controllers';
  }

  String _preferredBlocFolder(Map<String, List<String>> structure) {
    final presentation = structure['presentation'] ?? const <String>[];
    if (presentation.contains('blocs')) {
      return 'blocs';
    }
    if (presentation.contains('bloc')) {
      return 'bloc';
    }
    return 'blocs';
  }
}
