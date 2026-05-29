# Architecture Audit

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Use:

```bash
arch_sherpa audit
```

What it does:
- scans feature directories under `features.base_path`
- validates expected section/folder paths from `features.structure`
- reports missing paths as drift
- detects Darwin native dependency-manager metadata structurally

Darwin dependency-manager findings:
- CocoaPods metadata is reported as info when `Podfile`, `Podfile.lock`, or `.podspec` markers exist.
- Swift Package Manager metadata is reported as info when `Package.swift` exists.
- Mixed CocoaPods and Swift Package Manager metadata is accepted structurally and reported as info.
- Flutter plugins with iOS/macOS/darwin platform declarations and no CocoaPods or Swift Package Manager metadata receive a warning.
- Dart-only packages, Flutter packages without Darwin native structure, and normal Flutter app native shells are not warned about missing CocoaPods or Swift Package Manager metadata.

Arch Sherpa does not analyze dependency readiness. Use `dep_sherpa` for Darwin Swift Package Manager readiness and `techdebt_sherpa` to surface readiness gaps as platform migration debt.

Automation mode:

```bash
arch_sherpa --json audit
```

Report files:

```bash
arch_sherpa audit --format both --out reports/arch
```
