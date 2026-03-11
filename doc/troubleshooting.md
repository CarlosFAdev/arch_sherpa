# Troubleshooting

## Compatibility check failures

Run:

```bash
arch_sherpa config validate
```

Then align `state_management.type` and presentation folders.

## Migration drift failures

Run:

```bash
arch_sherpa config migrate --check
```

If drift is expected, update config in place:

```bash
arch_sherpa config migrate --write structure.yaml
```

## CI strict doctor failures

Run locally with the same strict profile:

```bash
arch_sherpa doctor --strict
```
