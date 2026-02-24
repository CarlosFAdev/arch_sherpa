# Arch Sherpa

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Arch Sherpa is an opinionated, automation-first Dart CLI for disciplined Flutter architecture scaffolding. It standardizes project structure, feature layout, template-based starter file generation, and state-management compatibility checks so teams can move faster with fewer architectural regressions.

## Installation

### Activate from pub.dev

```bash
dart pub global activate arch_sherpa
```

### Run locally in this repository

```bash
dart pub get
dart run bin/arch_sherpa.dart --help
```

## Commands

```bash
arch_sherpa init
arch_sherpa add feature <name>
arch_sherpa config
arch_sherpa config validate
arch_sherpa config check
arch_sherpa config migrate
arch_sherpa config deprecations
arch_sherpa check
arch_sherpa doctor
arch_sherpa audit
```

Command behavior:
- Non-interactive and fail-fast
- Exit code `1` on errors
- Never writes outside project root
- Never overwrites existing files/directories
- Supports `--dry-run`, `--json`, `--project-root <path>`, `--write <path>`, `--fail-on-deprecated`, `--check`, and `--strict`

## Configuration Precedence

Arch Sherpa resolves configuration in this order:
1. `structure.yaml`
2. `pubspec.yaml` at `flutter_sherpa.arch_sherpa`
3. Internal defaults

## Default Configuration

When no configuration is present, Arch Sherpa uses:
- `project.core`: `theme`, `widgets`, `utils`, `constants`, `routes`
- `features.base_path`: `lib/features`
- `state_management.type`: `riverpod`
- `tests.enabled`: `false`

Default feature structure:
- `domain/entities`, `domain/repositories`, `domain/usecases`
- `presentation/controllers`, `presentation/pages`, `presentation/widgets`
- `data/repositories`, `data/models`, `data/datasources`
- `application`

When you run `add feature`, Arch Sherpa generates folder scaffolds and starter template files per layer. If `tests.enabled: true`, it also creates a feature test scaffold under `test/features/<feature_name>/`.

## Configuration Example (`structure.yaml`)

```yaml
schema_version: 1

project:
  core:
    - theme
    - widgets
    - utils
    - constants
    - routes

features:
  base_path: lib/features
  structure:
    domain:
      - entities
      - repositories
      - usecases
    presentation:
      - controllers
      - pages
      - widgets
    data:
      - repositories
      - models
      - datasources
    application: []

state_management:
  type: riverpod

tests:
  enabled: false

deprecations:
  policy: warn
```

## Additional Operational Commands

- `arch_sherpa config validate`: validates resolved config plus compatibility rules
- `arch_sherpa config migrate`: emits a migrated config file (`structure.migrated.yaml`)
  - in-place mode: `arch_sherpa config migrate --write structure.yaml`
  - CI gate mode: `arch_sherpa config migrate --check`
  - check mode now also detects diffs between `structure.yaml` and normalized migration output
- `arch_sherpa config deprecations`: explicit report of deprecated keys and replacement hints
- `deprecations.policy: error` can enforce the same behavior as `--fail-on-deprecated` in CI
- `arch_sherpa doctor`: runs diagnostics suitable for CI and local checks
- `arch_sherpa doctor` fails if migration is required, enabling single-command CI gating
- `arch_sherpa doctor --strict` enforces stricter CI profile checks (including explicit config source)
- `arch_sherpa audit`: detects drift between existing feature folders and configured structure

## State Management Compatibility

Capabilities are inferred from presentation folders:
- `presentationControllers`
- `presentationProviders`
- `presentationBlocs`

Rules:
- `riverpod` requires `controllers` or `providers`
- `bloc` and `cubit` require `blocs`
- `none` requires none of the above

On incompatibility, Arch Sherpa returns detected capabilities, required capabilities, and a suggested remediation.

Deprecated config aliases from older drafts are accepted with warnings and normalized during load/migration.

## Integration with `semver_sherpa`

Use Arch Sherpa for architecture scaffolding and `semver_sherpa` for disciplined release/version workflows. Together they provide structure-first development with semver-driven delivery in the Flutter Sherpa Suite.

## Docs

- [Pub.dev Example](example/README.md)
- [Overview](doc/overview.md)
- [Configuration](doc/configuration.md)
- [Configuration Examples](doc/configuration-examples.md)
- [Commands](doc/commands.md)
- [Architecture](doc/architecture.md)
- [Roadmap](doc/roadmap.md)
- [Contributing](doc/contributing.md)
- [Release Operations](doc/release-operations.md)
