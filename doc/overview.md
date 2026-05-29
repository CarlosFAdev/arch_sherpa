# Overview

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Arch Sherpa is a Dart CLI focused on architecture automation for Flutter projects. It enforces consistent folder conventions, configurable feature scaffolding, and explicit state-management compatibility constraints.

It performs structural validation only. For iOS/macOS projects, Arch Sherpa does not require CocoaPods as a universal dependency-manager model and does not duplicate `dep_sherpa` Swift Package Manager readiness analysis.

## Design Goals

- Opinionated, maintainable architecture defaults
- Declarative configuration through YAML
- Deterministic, non-interactive command behavior
- Safe filesystem operations bounded to project root
- Template-based starter generation with extensible foundations for broader code generation

## Core Value

Arch Sherpa reduces architecture drift by turning agreed conventions into executable automation.
