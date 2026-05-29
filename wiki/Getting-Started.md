# Getting Started

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Install

```bash
dart pub global activate arch_sherpa
```

## Initialize Structure

```bash
arch_sherpa init
```

## Add a Feature

```bash
arch_sherpa add feature auth
```

## Inspect Effective Config

```bash
arch_sherpa config
```

## Validate and Diagnose

```bash
arch_sherpa config validate
arch_sherpa doctor
```

## Audit Project Structure

```bash
arch_sherpa audit
arch_sherpa audit --format json --out reports/arch
```

The audit command checks feature-folder drift and reports lightweight Darwin dependency-manager metadata when present. It accepts CocoaPods, Swift Package Manager, mixed, none, and unknown structural states without requiring Xcode, CocoaPods, Swift Package Manager, macOS, or network access.
