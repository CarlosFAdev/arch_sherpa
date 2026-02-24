# Release Operations

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Release Gates

- Changelog version entry exists for tag
- `dart analyze` passes
- `dart test` passes
- `dart pub publish --dry-run` passes

## CI Workflows

- `.github/workflows/ci.yml` for branch and pull request quality checks
- `.github/workflows/release.yml` for tag-based release validation

## Supply Chain and Security

- dependency automation via `.github/dependabot.yml`
- vulnerability handling via `SECURITY.md`
- support policy documented in `SUPPORT.md`
