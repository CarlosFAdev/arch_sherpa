# Configuration Examples

**Arch Sherpa — Part of the Flutter Sherpa Suite**

## Riverpod (Default Layering)

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

## Bloc Team (Bloc-Centric Presentation)

```yaml
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories, usecases]
    presentation: [blocs, pages, widgets]
    data: [repositories, models, datasources]
    application: []
state_management:
  type: bloc
tests:
  enabled: true
deprecations:
  policy: error
```

## Minimal Team (No State Layer)

```yaml
schema_version: 1
project:
  core: [theme, widgets, utils, constants, routes]
features:
  base_path: lib/features
  structure:
    domain: [entities, repositories]
    presentation: [pages, widgets]
    data: [repositories, models]
    application: []
state_management:
  type: none
tests:
  enabled: false
deprecations:
  policy: warn
```
