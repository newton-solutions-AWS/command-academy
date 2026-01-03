# Phoenix Protocol v2 — Validation Rules (Canonical Law)

This document defines the **non-negotiable rules** governing all Phoenix Protocol v2 lesson generation, validation, and audit approval.

Any lesson that violates these rules is **invalid by definition** and must not be generated, stored, or deployed.

---

## 1. Core Principle: Executable Reality

Phoenix v2 lessons must succeed in **any clean, empty AWS sandbox** with:
- No pre-created resources
- No assumed infrastructure
- No prior student actions

Success is defined as **command execution without error**, not the presence of resources.

---

## 2. Tooling Constraints (HARD RULES)

### ✅ Allowed
- Standard AWS CLI only (`aws`)
- Read-only commands only:
  - `list-*`
  - `describe-*`
  - `get-*`
  - `aws s3 ls`
  - `aws sts get-caller-identity`

### ❌ Forbidden
- Fictional tools (e.g. `psco`, `pscop`)
- External CLIs
- GitHub repositories unless explicitly verified and vendored
- SDKs, scripts, or binaries outside AWS CLI

---

## 3. Resource Targeting Rules

### ❌ Never Allowed
Lessons MUST NOT:
- Reference named resources (e.g. `s3://my-bucket`)
- Reference ARNs with hardcoded Account IDs
- Assume roles, buckets, VPCs, instances, or alarms exist

These patterns **cause fatal errors** in empty sandboxes.

### ✅ Required Pattern
Lessons MUST:
- Use **account-level discovery**
- Prefer global list/describe commands
- Accept empty output as a valid success state

Example:
```bash
aws s3 ls
