import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:arch_sherpa/config/architecture_auditor.dart';
import 'package:arch_sherpa/config/compatibility_checker.dart';
import 'package:arch_sherpa/config/config_loader.dart';
import 'package:arch_sherpa/config/config_migrator.dart';
import 'package:arch_sherpa/config/config_model.dart';
import 'package:arch_sherpa/config/config_validator.dart';
import 'package:arch_sherpa/generators/feature_generator.dart';
import 'package:arch_sherpa/generators/project_generator.dart';

void main(List<String> arguments) {
  final exitCodeValue = _run(arguments);
  if (exitCodeValue != 0) {
    exitCode = exitCodeValue;
  }
}

class CliContext {
  CliContext({
    required this.jsonOutput,
    required this.dryRun,
    required this.writePath,
    required this.failOnDeprecated,
    required this.checkMode,
    required this.strictMode,
  });

  final bool jsonOutput;
  final bool dryRun;
  final String? writePath;
  final bool failOnDeprecated;
  final bool checkMode;
  final bool strictMode;
}

class CliFailure implements Exception {
  CliFailure({
    required this.code,
    required this.message,
    this.suggestion,
  });

  final String code;
  final String message;
  final String? suggestion;
}

int _run(List<String> arguments) {
  final parser = ArgParser(allowTrailingOptions: true)
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    )
    ..addFlag(
      'json',
      negatable: false,
      help: 'Print machine-readable JSON output.',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Show planned changes without writing to disk.',
    )
    ..addOption(
      'project-root',
      help: 'Run against this project root path instead of current directory.',
    )
    ..addOption(
      'write',
      help: 'Output path for config migration, e.g. --write structure.yaml.',
    )
    ..addFlag(
      'fail-on-deprecated',
      negatable: false,
      help: 'Fail when deprecated config keys are detected.',
    )
    ..addFlag(
      'check',
      negatable: false,
      help:
          'Check mode for config migrate: exit non-zero when migration is required.',
    )
    ..addFlag(
      'strict',
      negatable: false,
      help: 'Strict profile for doctor checks (CI-oriented).',
    );

  late ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    _printUsage(parser);
    return 1;
  }

  final context = CliContext(
    jsonOutput: results['json'] == true,
    dryRun: results['dry-run'] == true,
    writePath: results['write']?.toString().trim().isEmpty == true
        ? null
        : results['write']?.toString().trim(),
    failOnDeprecated: results['fail-on-deprecated'] == true,
    checkMode: results['check'] == true,
    strictMode: results['strict'] == true,
  );

  if (results['help'] == true || arguments.isEmpty) {
    _printUsage(parser);
    return 0;
  }

  final command = results.rest;
  if (command.isEmpty) {
    return _fail(
      context,
      CliFailure(
        code: 'E_MISSING_COMMAND',
        message: 'Missing command.',
        suggestion: 'Run "arch_sherpa --help" for available commands.',
      ),
    );
  }
  final root = Directory(
    results['project-root']?.toString().trim().isNotEmpty == true
        ? results['project-root'].toString()
        : Directory.current.path,
  );

  try {
    final loadResult = ConfigLoader().load(projectRoot: root);
    final config = loadResult.config;
    final validator = ConfigValidator();
    validator.validate(config);

    if (context.writePath != null && !_isConfigMigrate(command)) {
      throw CliFailure(
        code: 'E_INVALID_OPTION',
        message: '--write is only supported for "config migrate".',
      );
    }
    if (context.checkMode && !_isConfigMigrate(command)) {
      throw CliFailure(
        code: 'E_INVALID_OPTION',
        message: '--check is only supported for "config migrate".',
      );
    }
    if (context.strictMode && !_isDoctor(command)) {
      throw CliFailure(
        code: 'E_INVALID_OPTION',
        message: '--strict is only supported for "doctor".',
      );
    }
    final enforceDeprecatedAsError =
        context.failOnDeprecated || config.deprecations.policy == 'error';
    if (enforceDeprecatedAsError &&
        loadResult.warnings.isNotEmpty &&
        !_isConfigDeprecations(command)) {
      throw CliFailure(
        code: 'E_DEPRECATED_CONFIG',
        message: 'Deprecated config keys detected.',
        suggestion: 'Run "arch_sherpa config deprecations" and migrate keys.',
      );
    }

    if (_isInit(command)) {
      _ensureCompatible(config);
      return _handleInit(
        context,
        config,
        root,
        loadResult.source,
        loadResult.warnings,
      );
    }
    if (_isAddFeature(command)) {
      _ensureCompatible(config);
      return _handleAddFeature(
        context,
        config,
        root,
        command[2],
        validator,
        loadResult.warnings,
      );
    }
    if (_isConfig(command)) {
      return _handleConfig(
          context, config, loadResult.source, loadResult.warnings);
    }
    if (_isConfigValidate(command)) {
      _ensureCompatible(config);
      return _handleConfigValidate(
        context,
        config,
        loadResult.source,
        loadResult.warnings,
      );
    }
    if (_isConfigCheckAlias(command) || _isCheck(command)) {
      _ensureCompatible(config);
      return _handleConfigValidate(
        context,
        config,
        loadResult.source,
        loadResult.warnings,
      );
    }
    if (_isConfigMigrate(command)) {
      return _handleConfigMigrate(context, config, root, loadResult.warnings);
    }
    if (_isConfigDeprecations(command)) {
      return _handleConfigDeprecations(
        context,
        loadResult.source,
        loadResult.warnings,
      );
    }
    if (_isDoctor(command)) {
      return _handleDoctor(
          context, config, loadResult.source, loadResult.warnings);
    }
    if (_isAudit(command)) {
      return _handleAudit(context, config, root, loadResult.warnings);
    }

    throw CliFailure(
      code: 'E_UNKNOWN_COMMAND',
      message: 'Unknown command: ${command.join(' ')}',
      suggestion: 'Run "arch_sherpa --help" for available commands.',
    );
  } on ConfigValidationException catch (e) {
    return _fail(
      context,
      CliFailure(code: 'E_CONFIG_VALIDATION', message: e.message),
    );
  } on CliFailure catch (e) {
    return _fail(context, e);
  } on Exception catch (e) {
    return _fail(
      context,
      CliFailure(
        code: 'E_RUNTIME',
        message: e.toString(),
      ),
    );
  }
}

bool _isInit(List<String> command) =>
    command.length == 1 && command[0] == 'init';

bool _isAddFeature(List<String> command) =>
    command.length == 3 && command[0] == 'add' && command[1] == 'feature';

bool _isConfig(List<String> command) =>
    command.length == 1 && command[0] == 'config';

bool _isConfigValidate(List<String> command) =>
    command.length == 2 && command[0] == 'config' && command[1] == 'validate';

bool _isConfigMigrate(List<String> command) =>
    command.length == 2 && command[0] == 'config' && command[1] == 'migrate';

bool _isConfigCheckAlias(List<String> command) =>
    command.length == 2 && command[0] == 'config' && command[1] == 'check';

bool _isConfigDeprecations(List<String> command) =>
    command.length == 2 &&
    command[0] == 'config' &&
    command[1] == 'deprecations';

bool _isCheck(List<String> command) =>
    command.length == 1 && command[0] == 'check';

bool _isDoctor(List<String> command) =>
    command.length == 1 && command[0] == 'doctor';

bool _isAudit(List<String> command) =>
    command.length == 1 && command[0] == 'audit';

void _ensureCompatible(ArchSherpaConfig config) {
  final compatibility = CompatibilityChecker().check(config);
  if (!compatibility.isCompatible) {
    throw CliFailure(
      code: 'E_COMPATIBILITY',
      message: compatibility.message,
      suggestion: compatibility.suggestion,
    );
  }
}

int _handleInit(
  CliContext context,
  ArchSherpaConfig config,
  Directory root,
  ConfigSource source,
  List<String> warnings,
) {
  final result = ProjectGenerator().generate(
    projectRoot: root,
    config: config,
    dryRun: context.dryRun,
  );

  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'init',
      'dry_run': context.dryRun,
      'source': _sourceLabel(source),
      'warnings': warnings,
      'created': result.createdPaths,
      'skipped': result.skippedPaths,
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln(
    context.dryRun
        ? 'Dry run: project structure plan.'
        : 'Initialized project structure.',
  );
  stdout.writeln('Config source: ${_sourceLabel(source)}');
  _printWarnings(warnings);
  stdout.writeln('Created ${result.createdPaths.length} directories.');
  for (final path in result.createdPaths) {
    stdout.writeln('  + $path');
  }
  if (result.skippedPaths.isNotEmpty) {
    stdout
        .writeln('Skipped ${result.skippedPaths.length} existing directories.');
  }
  return 0;
}

int _handleAddFeature(
  CliContext context,
  ArchSherpaConfig config,
  Directory root,
  String featureName,
  ConfigValidator validator,
  List<String> warnings,
) {
  validator.validateFeatureName(featureName);
  final result = FeatureGenerator().generate(
    projectRoot: root,
    config: config,
    featureName: featureName,
    dryRun: context.dryRun,
  );

  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'add feature',
      'feature': featureName,
      'dry_run': context.dryRun,
      'warnings': warnings,
      'created': result.createdPaths,
      'skipped': result.skippedPaths,
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln(
    context.dryRun
        ? 'Dry run: feature "$featureName" scaffold plan.'
        : 'Added feature "$featureName".',
  );
  _printWarnings(warnings);
  stdout.writeln('Created ${result.createdPaths.length} directories.');
  for (final path in result.createdPaths) {
    stdout.writeln('  + $path');
  }
  if (result.skippedPaths.isNotEmpty) {
    stdout
        .writeln('Skipped ${result.skippedPaths.length} existing directories.');
  }
  return 0;
}

int _handleConfig(
  CliContext context,
  ArchSherpaConfig config,
  ConfigSource source,
  List<String> warnings,
) {
  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'config',
      'source': _sourceLabel(source),
      'warnings': warnings,
      'config': ArchSherpaConfig.toMap(config),
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Resolved configuration');
  stdout.writeln('source: ${_sourceLabel(source)}');
  _printWarnings(warnings);
  final map = ArchSherpaConfig.toMap(config);
  _printMap(map, indent: 0);
  return 0;
}

int _handleConfigValidate(
  CliContext context,
  ArchSherpaConfig config,
  ConfigSource source,
  List<String> warnings,
) {
  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'config validate',
      'source': _sourceLabel(source),
      'warnings': warnings,
      'schema_version': config.schemaVersion,
      'message': 'Configuration is valid and compatible.',
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Configuration is valid and compatible.');
  stdout.writeln('source: ${_sourceLabel(source)}');
  _printWarnings(warnings);
  stdout.writeln('schema_version: ${config.schemaVersion}');
  return 0;
}

int _handleConfigMigrate(
  CliContext context,
  ArchSherpaConfig config,
  Directory root,
  List<String> warnings,
) {
  final migrator = ConfigMigrator();
  final planned = migrator.migrate(
    projectRoot: root,
    config: config,
    writeToFile: false,
  );
  final structureFile = File('${root.path}/structure.yaml');
  final structureDiffers = structureFile.existsSync() &&
      _normalizeContent(structureFile.readAsStringSync()) !=
          _normalizeContent(planned.yaml);
  final migrationRequired = warnings.isNotEmpty ||
      config.schemaVersion < ArchSherpaConfig.latestSchemaVersion ||
      structureDiffers;

  if (context.checkMode) {
    if (context.jsonOutput) {
      _printJson({
        'ok': !migrationRequired,
        'command': 'config migrate',
        'check': true,
        'migration_required': migrationRequired,
        'structure_differs': structureDiffers,
        'warnings': warnings,
      });
      return migrationRequired ? 1 : 0;
    }

    stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
    stdout.writeln('Config migration check');
    _printWarnings(warnings);
    if (migrationRequired) {
      stdout.writeln('Migration required.');
      if (structureDiffers) {
        stdout.writeln(
            'Reason: structure.yaml differs from normalized migration output.');
      }
      return 1;
    }
    stdout.writeln('No migration required.');
    return 0;
  }

  final outputPath = context.writePath ?? 'structure.migrated.yaml';
  if (outputPath.startsWith('/')) {
    throw CliFailure(
      code: 'E_INVALID_WRITE_PATH',
      message: 'The --write path must be relative to project root.',
    );
  }

  final result = migrator.migrate(
    projectRoot: root,
    config: config,
    writeToFile: !context.dryRun,
    outputPath: outputPath,
    overwriteExisting: outputPath == 'structure.yaml',
  );

  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'config migrate',
      'dry_run': context.dryRun,
      'warnings': warnings,
      'before_version': result.beforeVersion,
      'after_version': result.afterVersion,
      'written': result.written,
      'output_path': result.outputPath,
      'yaml': result.yaml,
      'overwrote_existing': result.overwroteExisting,
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Config migration complete.');
  _printWarnings(warnings);
  stdout.writeln(
      'schema_version: ${result.beforeVersion} -> ${result.afterVersion}');
  if (context.dryRun) {
    stdout.writeln('Dry run: no files were written.');
  } else if (result.written) {
    if (result.overwroteExisting) {
      stdout.writeln('Overwrote ${result.outputPath}');
    } else {
      stdout.writeln('Wrote ${result.outputPath}');
    }
  } else {
    stdout.writeln('Skipped write: ${result.outputPath} already exists.');
  }
  return 0;
}

int _handleConfigDeprecations(
  CliContext context,
  ConfigSource source,
  List<String> warnings,
) {
  if (context.jsonOutput) {
    _printJson({
      'ok': true,
      'command': 'config deprecations',
      'source': _sourceLabel(source),
      'count': warnings.length,
      'warnings': warnings,
    });
    return 0;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Config deprecations report');
  stdout.writeln('source: ${_sourceLabel(source)}');
  if (warnings.isEmpty) {
    stdout.writeln('No deprecated keys detected.');
    return 0;
  }
  stdout.writeln('Deprecated keys (${warnings.length}):');
  for (final warning in warnings) {
    stdout.writeln('  - $warning');
  }
  return 0;
}

int _handleDoctor(
  CliContext context,
  ArchSherpaConfig config,
  ConfigSource source,
  List<String> warnings,
) {
  final compatibility = CompatibilityChecker().check(config);
  final migrationRequired = warnings.isNotEmpty ||
      config.schemaVersion < ArchSherpaConfig.latestSchemaVersion;
  final checks = [
    {'name': 'config_loaded', 'ok': true, 'details': _sourceLabel(source)},
    {
      'name': 'schema_version_supported',
      'ok': config.schemaVersion <= ArchSherpaConfig.latestSchemaVersion,
      'details':
          '${config.schemaVersion}/${ArchSherpaConfig.latestSchemaVersion}',
    },
    {
      'name': 'compatibility',
      'ok': compatibility.isCompatible,
      'details': compatibility.isCompatible
          ? 'compatible'
          : '${compatibility.message} Suggestion: ${compatibility.suggestion}',
    },
    {
      'name': 'migration_required',
      'ok': !migrationRequired,
      'details': migrationRequired ? 'migration required' : 'up-to-date',
    },
    if (context.strictMode)
      {
        'name': 'deprecated_keys',
        'ok': warnings.isEmpty,
        'details': warnings.isEmpty
            ? 'none'
            : '${warnings.length} deprecated keys detected',
      },
    if (context.strictMode)
      {
        'name': 'explicit_config_source',
        'ok': source != ConfigSource.defaults,
        'details': source == ConfigSource.defaults
            ? 'using internal defaults'
            : _sourceLabel(source),
      },
  ];

  final ok = checks.every((entry) => entry['ok'] == true);

  if (context.jsonOutput) {
    _printJson({
      'ok': ok,
      'command': 'doctor',
      'strict': context.strictMode,
      'warnings': warnings,
      'checks': checks,
    });
    return ok ? 0 : 1;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Doctor checks');
  if (context.strictMode) {
    stdout.writeln('Profile: strict');
  }
  _printWarnings(warnings);
  for (final check in checks) {
    stdout.writeln(
      '  ${check['ok'] == true ? '[OK]' : '[FAIL]'} ${check['name']}: ${check['details']}',
    );
  }
  return ok ? 0 : 1;
}

int _handleAudit(
  CliContext context,
  ArchSherpaConfig config,
  Directory root,
  List<String> warnings,
) {
  final result = ArchitectureAuditor().audit(projectRoot: root, config: config);

  if (context.jsonOutput) {
    _printJson({
      'ok': result.ok,
      'command': 'audit',
      'warnings': warnings,
      'checked_features': result.checkedFeatures,
      'missing_paths': result.missingPaths,
    });
    return result.ok ? 0 : 1;
  }

  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln('Architecture audit');
  _printWarnings(warnings);
  stdout.writeln('Checked features: ${result.checkedFeatures}');
  if (result.ok) {
    stdout.writeln('No drift detected.');
    return 0;
  }
  stdout.writeln('Missing paths (${result.missingPaths.length}):');
  for (final path in result.missingPaths) {
    stdout.writeln('  - $path');
  }
  return 1;
}

int _fail(CliContext context, CliFailure failure) {
  if (context.jsonOutput) {
    _printJson({
      'ok': false,
      'error': {
        'code': failure.code,
        'message': failure.message,
        if (failure.suggestion != null) 'suggestion': failure.suggestion,
      },
    });
  } else {
    stderr.writeln('[${failure.code}] ${failure.message}');
    if (failure.suggestion != null) {
      stderr.writeln('Suggestion: ${failure.suggestion}');
    }
  }
  return 1;
}

void _printUsage(ArgParser parser) {
  stdout.writeln('Arch Sherpa — Part of the Flutter Sherpa Suite');
  stdout.writeln(
    'Usage: arch_sherpa [--json] [--dry-run] [--project-root <path>] [--write <path>] [--fail-on-deprecated] [--check] [--strict] <command>',
  );
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln(
      '  init                      Initialize project folder structure.');
  stdout.writeln('  add feature <name>        Add a feature scaffold.');
  stdout.writeln('  config                    Print resolved config.');
  stdout.writeln(
    '  config validate           Validate resolved config and compatibility.',
  );
  stdout.writeln(
    '  config check              Alias for config validate.',
  );
  stdout.writeln(
    '  config migrate            Migrate config; default output structure.migrated.yaml.',
  );
  stdout.writeln(
    '  config deprecations       Show deprecated config keys and migration hints.',
  );
  stdout.writeln(
    '  check                     Alias for config validate.',
  );
  stdout.writeln('  doctor                    Run project diagnostics.');
  stdout.writeln(
      '  audit                     Detect architecture drift in feature folders.');
  stdout.writeln('');
  stdout.writeln(parser.usage);
}

String _sourceLabel(ConfigSource source) {
  switch (source) {
    case ConfigSource.structureYaml:
      return 'structure.yaml';
    case ConfigSource.pubspecYaml:
      return 'pubspec.yaml:flutter_sherpa.arch_sherpa';
    case ConfigSource.defaults:
      return 'internal defaults';
  }
}

void _printMap(Map<dynamic, dynamic> map, {required int indent}) {
  final padding = '  ' * indent;
  for (final entry in map.entries) {
    final key = entry.key.toString();
    final value = entry.value;
    if (value is Map) {
      stdout.writeln('$padding$key:');
      _printMap(value, indent: indent + 1);
    } else if (value is List) {
      if (value.isEmpty) {
        stdout.writeln('$padding$key: []');
      } else {
        stdout.writeln('$padding$key:');
        for (final item in value) {
          stdout.writeln('${'  ' * (indent + 1)}- $item');
        }
      }
    } else {
      stdout.writeln('$padding$key: $value');
    }
  }
}

void _printJson(Map<String, dynamic> payload) {
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(payload));
}

void _printWarnings(List<String> warnings) {
  for (final warning in warnings) {
    stdout.writeln('Warning: $warning');
  }
}

String _normalizeContent(String value) {
  return value.replaceAll('\r\n', '\n').trim();
}
