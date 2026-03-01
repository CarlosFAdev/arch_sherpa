# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.4] - 2026-03-01

### Changed
- Ignore local IDE metadata and pana output artifacts in `.gitignore`.

## [0.2.3] - 2026-03-01

### Changed
- Maintenance release to republish latest suite standards and CI validations.

## [0.2.2] - 2026-03-01

### Added
- Standardized suite governance files and local contract: `SHERPA_SUITE_GUIDELINES.md`.
- Added local Codex suite skill at `.codex/skills/sherpa_suite.md`.
- Added `docs/pub_score_playbook.md` and docs mirror pages for config reference and troubleshooting.
- Added CI pana gate script at `tool/pana_gate.dart`.

### Changed
- README rewritten to suite template with required badges, cross-links, and support section.
- `pubspec.yaml` metadata and topics aligned with suite standards.
- CI workflow now includes pana full-score gate.
- `analysis_options.yaml` hardened with strict analyzer language settings.

## [0.2.1] - 2026-02-24

### Added
- README support section with Buy Me a Coffee and Patreon links.

## [0.2.0] - 2026-02-24

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
- Expanded Dartdoc comments across public API to improve pub points/documentation coverage.

## [0.1.0] - 2026-02-24

### Added
- Initial release of Arch Sherpa CLI.
