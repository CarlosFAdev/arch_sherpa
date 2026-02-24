# Architecture Audit

**Arch Sherpa — Part of the Flutter Sherpa Suite**

Use:

```bash
arch_sherpa audit
```

What it does:
- scans feature directories under `features.base_path`
- validates expected section/folder paths from `features.structure`
- reports missing paths as drift

Automation mode:

```bash
arch_sherpa --json audit
```
