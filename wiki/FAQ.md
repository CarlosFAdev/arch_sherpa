# FAQ

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Does Arch Sherpa generate Dart files?

Yes. `add feature` generates starter Dart template files across configured layers.
It also generates feature test stubs when `tests.enabled: true`.

## Why strict validation?

To prevent architecture drift and avoid invalid layouts propagating across teams.

## Can I use it with existing projects?

Yes. Existing directories are never overwritten; they are reported as skipped.
