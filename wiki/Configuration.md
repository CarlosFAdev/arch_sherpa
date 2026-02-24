# Configuration

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Configuration precedence:
1. `structure.yaml`
2. `pubspec.yaml` > `flutter_sherpa.arch_sherpa`
3. Internal defaults

Required sections:
- `schema_version`
- `project`
- `features`
- `state_management`
- `tests`

Use `arch_sherpa config` to view the fully resolved configuration.
Use `arch_sherpa config migrate` to emit a migrated config file.
Use `arch_sherpa config deprecations` for a focused deprecated-key report.
Set `deprecations.policy: error` to enforce deprecated-key failures in CI.
See repository docs for team topology examples in `docs/configuration-examples.md`.
