# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New CLI capabilities:
  - `doctor`
  - `audit`
  - `config validate`
  - `config migrate`
- Global flags:
  - `--dry-run`
  - `--json`
  - `--project-root <path>`
- Structured machine-readable error payload support with command exit code consistency.
- Configuration schema version support via `schema_version` with migration helper output.
- In-place config migration support via `config migrate --write structure.yaml`.
- Template-based feature file generation for domain/data/presentation/application layers.
- State-management-aware starter templates for riverpod and bloc/cubit structures.
- `tests.enabled` support for optional feature test scaffold generation.
- Test suite:
  - unit tests for config loading, validation, compatibility, and safe path handling
  - integration tests for CLI command behavior
- CI and release workflows in GitHub Actions.
- Dependency update automation (`Dependabot`), security policy, and support policy docs.
- Release operations documentation.
- Snapshot-style integration tests for generated template outputs.
- Backward-compatible deprecated key alias support with explicit load-time warnings.
- Configuration examples for common team topologies.
- New command: `config deprecations`.
- New strict mode: `--fail-on-deprecated`.
- New config-level deprecation policy: `deprecations.policy` (`warn` or `error`).
- New migration gate mode: `config migrate --check`.
- `doctor` now checks migration-required state and fails when migration is needed.
- CI now enforces minimum 80% line coverage for `lib/`.
- Added template snapshot matrix tests across state modes and test-scaffold toggles.
- Added `doctor --strict` profile and CI fixture check for strict diagnostics.
- Added `check` and `config check` aliases for validation command flow.
- Improved missing-command handling to return structured CLI error instead of unknown command.
- `config migrate --check` now detects normalized output drift against existing `structure.yaml`.
- Added `.pubignore` to optimize published package contents.

## [0.1.0] - 2026-02-24

### Added
- Initial release of Arch Sherpa CLI.
- Commands: `init`, `add feature <name>`, `config`.
- Configuration loading with precedence:
  - `structure.yaml`
  - `pubspec.yaml` (`flutter_sherpa.arch_sherpa`)
  - internal defaults
- Strict configuration validation with human-readable diagnostics.
- Capability-based compatibility checker for state management.
- Safe path normalization and traversal prevention for all writes.
- Initial project and feature generators with non-overwriting behavior.
- Product and platform documentation for "Arch Sherpa — Part of the Flutter Sherpa Suite".
