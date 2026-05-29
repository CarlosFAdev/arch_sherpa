# Release Operations

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Release Gates

- Changelog version entry exists for tag
- `dart analyze` passes
- `dart test` passes
- `dart pub publish --dry-run` passes
- `dart pub global run pana -j . > pana_report.json` produces max points
- `dart run tool/pana_gate.dart pana_report.json` passes

Publishing and pushing tags require explicit release-owner approval. A local release tag can be created before push approval, but pub.dev publishing must remain a separate explicit step.

## CI Workflows

- `.github/workflows/ci.yml` for branch and pull request quality checks
- `.github/workflows/release.yml` for tag-based release validation

## Supply Chain and Security

- dependency automation via `.github/dependabot.yml`
- vulnerability handling via `SECURITY.md`
- support policy documented in `SUPPORT.md`
