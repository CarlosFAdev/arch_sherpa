# arch_sherpa

**Flutter Sherpa Suite — Professional Engineering Toolkit for Flutter Teams**

The Flutter Sherpa Suite is a collection of focused, production-grade engineering tools for Dart and Flutter projects. Each Sherpa solves a distinct problem in the software lifecycle — from architecture and versioning to technical debt, migrations, and risk analysis.

`arch_sherpa` provides architecture scaffolding and structure validation for Flutter teams.

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

## Documentation

- [Configuration Reference](docs/config-reference.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Pub Score Playbook](docs/pub_score_playbook.md)
- [Legacy Architecture Docs](doc/architecture.md)

## Part of the Flutter Sherpa Suite

- [arch_sherpa](https://github.com/CarlosFAdev/arch_sherpa) - Architectural validation and structure enforcement
- [semver_sherpa](https://github.com/CarlosFAdev/semver_sherpa) - Semantic versioning and changelog automation
- [techdebt_sherpa](https://github.com/CarlosFAdev/techdebt_sherpa) - Technical debt observatory and hotspot detection

## Support the Project

- Buy Me a Coffee: https://buymeacoffee.com/carlosfdev
- Patreon: https://patreon.com/CarlosF_dev

## License

MIT. See [LICENSE](LICENSE).
