# Release Process

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Use Semantic Versioning and Keep a Changelog.

## Commit Strategy

1. Feature commit:
   - Include implementation changes
   - Update `Unreleased` in `CHANGELOG.md`
2. Version bump commit:
   - Bump `pubspec.yaml` version
   - Move `Unreleased` notes to a released section
   - Create tag `vX.Y.Z`

## Example for `v0.1.0`

```bash
git commit -m "feat: initial Arch Sherpa CLI MVP"
git commit -m "chore(release): 0.1.0"
git tag v0.1.0
```

## Automated Gates

- CI checks: format, analyze, test
- Tag checks: changelog entry for tagged version
- Publish validation: `dart pub publish --dry-run`
