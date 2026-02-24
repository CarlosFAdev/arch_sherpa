# Compatibility System

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Arch Sherpa derives capabilities from `presentation` folders:
- `controllers` -> `presentationControllers`
- `providers` -> `presentationProviders`
- `blocs`/`bloc` -> `presentationBlocs`

Compatibility rules:
- `riverpod`: requires controllers or providers
- `bloc` / `cubit`: requires blocs
- `none`: requires none of the above

When invalid, the CLI prints:
- detected capabilities
- required capabilities
- a suggested config fix
