import 'dart:io';

import '../config/config_model.dart';
import '../utils/file_utils.dart';

/// Result summary for project structure generation.
class ProjectGenerationResult {
  /// Creates a project generation result.
  ProjectGenerationResult({
    required this.createdPaths,
    required this.skippedPaths,
  });

  /// Paths created during generation.
  final List<String> createdPaths;

  /// Paths skipped because they already existed.
  final List<String> skippedPaths;
}

/// Generates project-level scaffold directories.
class ProjectGenerator {
  /// Creates a project generator.
  ProjectGenerator({FileUtils? fileUtils})
      : _fileUtils = fileUtils ?? FileUtils();

  final FileUtils _fileUtils;

  /// Creates configured core and features base directories.
  ProjectGenerationResult generate({
    required Directory projectRoot,
    required ArchSherpaConfig config,
    bool dryRun = false,
  }) {
    final created = <String>[];
    final skipped = <String>[];
    final rootPath = projectRoot.path;

    for (final coreFolder in config.project.core) {
      final relative = 'lib/core/$coreFolder';
      final absolute = _fileUtils.resolveSafePath(
        projectRootPath: rootPath,
        relativePath: relative,
      );
      final exists = Directory(absolute).existsSync();
      final isCreated =
          dryRun ? !exists : _fileUtils.createDirectoryIfMissing(absolute);
      (isCreated ? created : skipped).add(relative);
    }

    final featuresBaseAbsolute = _fileUtils.resolveSafePath(
      projectRootPath: rootPath,
      relativePath: config.features.basePath,
    );
    final featuresBaseExists = Directory(featuresBaseAbsolute).existsSync();
    final featuresBaseCreated = dryRun
        ? !featuresBaseExists
        : _fileUtils.createDirectoryIfMissing(featuresBaseAbsolute);
    (featuresBaseCreated ? created : skipped).add(config.features.basePath);

    return ProjectGenerationResult(
      createdPaths: created,
      skippedPaths: skipped,
    );
  }
}
