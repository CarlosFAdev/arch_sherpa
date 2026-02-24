# Architecture

**Arch Sherpa — Part of the Flutter Sherpa Suite**

The CLI uses a modular clean design:

```text
lib/
  config/
    config_model.dart
    config_loader.dart
    config_migrator.dart
    config_validator.dart
    compatibility_checker.dart
    capabilities.dart
  generators/
    project_generator.dart
    feature_generator.dart
  utils/
    file_utils.dart
bin/
  arch_sherpa.dart
```

## Responsibilities

- `config_model.dart`: canonical configuration model + defaults
- `config_loader.dart`: source precedence + merge behavior
- `config_validator.dart`: strict schema/path validation
- `config_migrator.dart`: schema migration output generation
- `capabilities.dart`: capability definitions
- `compatibility_checker.dart`: state management compatibility rules
- `project_generator.dart`: project initialization directories
- `feature_generator.dart`: feature-level scaffolding
- `file_utils.dart`: safe path resolution and root boundary enforcement
- `bin/arch_sherpa.dart`: command parsing and execution flow

## Execution Flow

1. Parse command and flags
2. Load config with precedence
3. Validate config
4. Run compatibility checks
5. Check compatibility where required
6. Execute command in write mode or dry-run mode
7. Report human-readable or JSON output
