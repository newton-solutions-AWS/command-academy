# Phoenix Protocol v2 — Validation Rules

These rules are NON-NEGOTIABLE.

## Rule 1 — Read-Only Operations
Only read-only AWS CLI commands are permitted.
No create, update, delete, or mutate operations.

## Rule 2 — Deterministic Validation
Validation must NOT depend on:
- Specific resource names
- Account IDs
- Region-specific assets

Use empty-string containment validation where appropriate.

## Rule 3 — Command Equality
The validation command MUST exactly match the lab aws command.

## Rule 4 — Empty Environment Safety
Lessons must PASS even when the environment contains no resources.

## Rule 5 — Audit Readiness
Lessons must be runnable in:
- Sandbox accounts
- Training environments
- Production read-only contexts
