# arch_sherpa

**Flutter Sherpa Suite — Professional Engineering Toolkit for Flutter Teams**

The Flutter Sherpa Suite is a collection of focused, production-grade engineering tools for Dart and Flutter projects. Each Sherpa solves a distinct problem in the software lifecycle — from architecture and versioning to technical debt, migrations, and risk analysis.

`arch_sherpa` provides architecture scaffolding and structure validation for Flutter teams.
It validates project shape and generated feature structure; it does not enforce
CocoaPods as the only valid iOS/macOS setup.

[![pub package](https://img.shields.io/pub/v/arch_sherpa.svg)](https://pub.dev/packages/arch_sherpa)
[![pub points](https://img.shields.io/pub/points/arch_sherpa)](https://pub.dev/packages/arch_sherpa/score)
[![Dart SDK](https://img.shields.io/badge/dart-%5E3.3.0-blue.svg)](https://dart.dev/get-dart)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-FFDD00?logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/carlosfdev)
[![Patreon](https://img.shields.io/badge/Patreon-support-000000?logo=patreon)](https://patreon.com/CarlosF_dev)

## Installation

```bash
dart pub global activate arch_sherpa
```

## Quick Start

```bash
arch_sherpa init
arch_sherpa add feature auth
arch_sherpa doctor --strict
dart run arch_sherpa audit --format json --out reports/arch --project-root .
```

## Commands

```text
arch_sherpa init
arch_sherpa add feature <name>
arch_sherpa config
arch_sherpa config validate
arch_sherpa config check
arch_sherpa config migrate
arch_sherpa config deprecations
arch_sherpa check
arch_sherpa doctor
arch_sherpa audit
```

Suite report example:

```bash
dart run arch_sherpa audit --format json --out reports/arch --project-root .
```

## Documentation

- [Configuration Reference](doc/config-reference.md)
- [Troubleshooting](doc/troubleshooting.md)
- [Pub Score Playbook](doc/pub_score_playbook.md)
- [Legacy Architecture Docs](doc/architecture.md)

## Darwin dependency managers

Flutter projects may use CocoaPods, Swift Package Manager, a mixed setup, no
Darwin native dependency manager, or an unknown state depending on project type
and Flutter/plugin support.

`arch_sherpa audit` performs lightweight structural detection only. It can report
which Darwin dependency-manager metadata is present, or warn when a Flutter
plugin declares iOS/macOS/darwin support without CocoaPods or Swift Package
Manager metadata. Normal Flutter app native shells are not treated as invalid
just because they lack Podfile or Package.swift metadata.
Dependency readiness and Swift Package Manager migration risk analysis belong to
`dep_sherpa`, not `arch_sherpa`.

Cross-package guidance:

- Use `arch_sherpa` to keep project architecture and structure consistent.
- Use `dep_sherpa` to inspect dependencies and Darwin SPM readiness.
- Use `techdebt_sherpa` to surface readiness gaps as migration debt.

## Part of the Flutter Sherpa Suite

- [arch_sherpa](https://github.com/CarlosFAdev/arch_sherpa) - Architectural validation and structure enforcement
- [dep_sherpa](https://github.com/CarlosFAdev/dep_sherpa) - Dependency risk intelligence and observability
- [semver_sherpa](https://github.com/CarlosFAdev/semver_sherpa) - Semantic versioning and changelog automation
- [techdebt_sherpa](https://github.com/CarlosFAdev/techdebt_sherpa) - Technical debt observatory and hotspot detection

## Support the Project

- Buy Me a Coffee: https://buymeacoffee.com/carlosfdev
- Patreon: https://patreon.com/CarlosF_dev

## License

MIT. See [LICENSE](LICENSE).
