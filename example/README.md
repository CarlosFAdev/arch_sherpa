# Example

**Arch Sherpa — Part of the Flutter Sherpa Suite**

This example shows a complete local flow.

## 1) Create config

Create `structure.yaml` in your Flutter project root:

```yaml
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories, usecases]
    presentation: [controllers, pages, widgets]
    data: [repositories, models, datasources]
    application: []
state_management:
  type: riverpod
tests:
  enabled: true
deprecations:
  policy: warn
```

## 2) Initialize architecture folders

```bash
arch_sherpa init
```

## 3) Add a feature

```bash
arch_sherpa add feature auth
```

## 4) Validate architecture and config

```bash
arch_sherpa config validate
arch_sherpa doctor
```

## 5) CI checks

```bash
arch_sherpa config migrate --check
arch_sherpa doctor --strict
```
