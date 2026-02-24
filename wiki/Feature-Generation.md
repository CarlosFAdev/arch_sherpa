# Feature Generation

**Arch Sherpa — Part of the Flutter Sherpa Suite**

`arch_sherpa add feature <name>` creates a feature root and section folders based on `features.structure`.

Example default output for `auth`:
- `lib/features/auth/domain/entities`
- `lib/features/auth/domain/repositories`
- `lib/features/auth/domain/usecases`
- `lib/features/auth/presentation/controllers`
- `lib/features/auth/presentation/pages`
- `lib/features/auth/presentation/widgets`
- `lib/features/auth/data/repositories`
- `lib/features/auth/data/models`
- `lib/features/auth/data/datasources`
- `lib/features/auth/application`

Rules:
- Existing directories are skipped
- Invalid names fail fast
- Paths outside project root are blocked
