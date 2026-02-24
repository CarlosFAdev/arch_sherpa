# Commands

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## `arch_sherpa init`

Creates base project directories:
- `lib/core/<configured folders>`
- `features.base_path`

## `arch_sherpa add feature <name>`

Creates feature scaffold under `features.base_path/<name>` according to `features.structure`.
Also generates layer starter files aligned to `state_management.type`.
When `tests.enabled` is true, generates `test/features/<name>/<name>_feature_test.dart`.

Feature name constraints:
- Must be non-empty
- Must match `[a-zA-Z0-9_-]`

## `arch_sherpa config`

Prints resolved effective configuration and source.

## `arch_sherpa config validate`

Validates resolved configuration and state-management compatibility.

## `arch_sherpa config check`

Alias for `arch_sherpa config validate`.

## `arch_sherpa check`

Alias for `arch_sherpa config validate`.

## `arch_sherpa config migrate`

Migrates resolved configuration to latest schema version and emits:
- `structure.migrated.yaml` (unless `--dry-run`)
- Use `--write structure.yaml` to migrate in-place.
- Use `--check` to fail when migration is required (CI gate mode).

## `arch_sherpa config deprecations`

Prints deprecated key usage and replacement hints.

## `arch_sherpa doctor`

Runs diagnostics for:
- config source detection
- schema version support
- compatibility status
- migration-required status (fails when migration is required)
- `--strict` profile can enforce explicit config source and deprecation cleanliness

## `arch_sherpa audit`

Detects architecture drift by scanning generated feature directories and
reporting missing configured section/folder paths.

## Global Flags

- `--dry-run`: compute operations without writing
- `--json`: machine-readable output
- `--project-root <path>`: run command against a target project path
- `--write <path>`: output path for `config migrate`
- `--fail-on-deprecated`: fail commands when deprecated config keys are detected
- `--check`: check-only mode for `config migrate`
- `--strict`: strict profile for `doctor`

## Error Behavior

- Exit code `1` for validation, compatibility, command, or filesystem errors
- Clear diagnostics printed to stderr
- No interactive prompts
