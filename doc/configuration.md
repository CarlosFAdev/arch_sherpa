# Configuration

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Resolution Order

1. `structure.yaml`
2. `pubspec.yaml` at `flutter_sherpa.arch_sherpa`
3. Internal defaults

## Schema

```yaml
schema_version: <int, currently 1>

project:
  core: <non-empty list<string>>

features:
  base_path: <non-empty string>
  structure: <map<string, list<string>>>

state_management:
  type: riverpod | bloc | cubit | none

tests:
  enabled: <bool>

deprecations:
  policy: warn | error
```

## Validation Rules

- `project.core` must be a non-empty list of valid folder names
- `features.base_path` must be non-empty
- `features.structure` must be a non-empty map of section to folders
- Folder names must match `[a-zA-Z0-9_-]`
- Reject empty values, `..`, and `\`
- `schema_version` must be between `1` and current supported version
- `state_management.type` must be one of:
  - `riverpod`
  - `bloc`
  - `cubit`
  - `none`
- `deprecations.policy` must be one of:
  - `warn`
  - `error`

## Deprecated Keys (Backward Compatibility)

These aliases are still accepted but emit warnings:
- `schemaVersion` -> `schema_version`
- `stateManagement` -> `state_management`
- `features.basePath` -> `features.base_path`
- `project.coreFolders` -> `project.core`
- `tests.enable` -> `tests.enabled`

## Default Configuration

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
  enabled: false

deprecations:
  policy: warn
```
