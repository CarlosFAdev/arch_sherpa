# FAQ

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Does Arch Sherpa generate Dart files?

Yes. `add feature` generates starter Dart template files across configured layers.
It also generates feature test stubs when `tests.enabled: true`.

## Why strict validation?

To prevent architecture drift and avoid invalid layouts propagating across teams.

## Can I use it with existing projects?

Yes. Existing directories are never overwritten; they are reported as skipped.

## Does Arch Sherpa require CocoaPods for iOS or macOS projects?

No. Arch Sherpa accepts CocoaPods, Swift Package Manager, mixed, no Darwin dependency-manager metadata, or unknown structural states depending on project type.

`arch_sherpa audit` performs structural checks only. Dependency readiness and Swift Package Manager migration risk belong to `dep_sherpa`; migration debt reporting belongs to `techdebt_sherpa`.
