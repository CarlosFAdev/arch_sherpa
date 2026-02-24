import 'dart:io';

import '../config/config_model.dart';
import '../utils/file_utils.dart';

class ProjectGenerationResult {
  ProjectGenerationResult({
    required this.createdPaths,
    required this.skippedPaths,
  });

  final List<String> createdPaths;
  final List<String> skippedPaths;
}

class ProjectGenerator {
  ProjectGenerator({FileUtils? fileUtils})
      : _fileUtils = fileUtils ?? FileUtils();

  final FileUtils _fileUtils;

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
