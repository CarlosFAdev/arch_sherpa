# Contributing

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Standards

- Keep behavior deterministic and non-interactive
- Preserve strict validation and fail-fast diagnostics
- Maintain backward-compatible config schema where possible
- Keep command output concise and automation-friendly

## Development Workflow

```bash
dart pub get
dart format .
dart analyze
dart test
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
dart run bin/arch_sherpa.dart --help
```

## Release Workflow

- Use Semantic Versioning
- Maintain `CHANGELOG.md` in Keep a Changelog format
- Follow feature commit + version bump commit strategy
- Ensure CI passes:
  - format check
  - static analysis
  - tests
  - minimum 80% line coverage over `lib/`
