# Roadmap

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Goal: deliver a production-level, publish-ready CLI with stable UX, strong validation guarantees, automated quality gates, and clear upgrade paths.

## Progress Update (2026-02-24)

Completed:
- Unit and integration test suites with CI quality gates
- `--dry-run`, `--json`, `doctor`, `audit`, `config validate`, `config migrate`
- Schema versioning and migration output support
- Template-based feature file generation with state-management awareness
- Optional feature test scaffold generation via `tests.enabled`
- Release/security/dependency automation baseline

## Phase 1: Foundation Hardening (target: March 2026)

Deliverables:
- Add automated unit tests for:
  - config loading precedence
  - schema validation failures
  - compatibility checker matrix
  - path traversal protection
- Add integration tests for CLI commands:
  - `init`
  - `add feature <name>`
  - `config`
- Add CI pipeline:
  - `dart format --set-exit-if-changed .`
  - `dart analyze`
  - `dart test`
- Add machine-readable error codes in CLI output (while preserving human-readable diagnostics)

Exit criteria:
- >=90% coverage on `lib/config` and `lib/utils`
- All commands covered by integration tests
- CI required for merge on default branch

## Phase 2: Generation Engine MVP (target: April 2026)

Deliverables:
- Introduce template-driven file generation (not just directory scaffolding)
- Add state-management-aware templates:
  - riverpod
  - bloc/cubit
  - none
- Support `tests.enabled` for optional test scaffold generation
- Add `--dry-run` mode with deterministic output plan
- Add idempotency guarantees for generated outputs

Exit criteria:
- Re-running the same command produces no unintended changes
- Dry-run output matches write-mode plan
- Templates validated by snapshot tests

## Phase 3: Config Evolution and Migration Safety (target: May 2026)

Deliverables:
- Introduce config schema versioning (e.g., `schema_version`)
- Add `arch_sherpa config validate`
- Add `arch_sherpa config migrate` for backward-compatible upgrades
- Add deprecation warnings with clear remediation instructions
- Publish configuration reference examples for common team topologies

Exit criteria:
- Backward compatibility policy documented and enforced
- Migration command tested against previous schema samples
- All deprecations include actionable upgrade path

## Phase 4: Developer Experience and Team Scale (target: June 2026)

Deliverables:
- Add `arch_sherpa doctor` for environment and project diagnostics
- Add structured output option (`--json`) for CI and automation usage
- Add rule packs for organization-specific architecture constraints
- Add audit mode to detect drift from declared architecture
- Improve docs with architecture decision records and real project examples

Exit criteria:
- JSON output stable and documented
- Drift detection validated against fixture projects
- Docs include end-to-end onboarding and CI integration walkthroughs

## Phase 5: Release Operations and Supply Chain (target: July 2026)

Deliverables:
- Enforce release pipeline:
  - changelog gate
  - semver gate
  - tag validation
  - publish dry-run gate
- Add signed release artifacts and provenance notes
- Add security policy and vulnerability reporting process
- Add dependency update automation and lockstep verification

Exit criteria:
- Fully automated release checklist for pub.dev
- Security and support policies published
- No manual steps required besides release approval

## Phase 6: Stable `1.0.0` Readiness (target: August 2026)

Deliverables:
- Freeze CLI contract for core commands
- Finalize compatibility semantics and template extension points
- Publish long-term support policy and version support matrix
- Publish production adoption guide:
  - rollout strategy
  - migration strategy
  - fallback/recovery strategy

Exit criteria for `1.0.0`:
- Zero known P1/P2 defects
- Stable command and config contracts documented
- CI/release/security gates active
- pub.dev score and package quality checks passing

## Ongoing Workstreams

- Performance:
  - keep command startup and generation latency low
- Observability:
  - improve diagnostics quality and consistency
- Interoperability:
  - deepen integration with `semver_sherpa` and broader Flutter Sherpa Suite workflows
