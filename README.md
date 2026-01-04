# Command Academy

Command Academy is a deterministic, audit-safe cloud and cybersecurity training platform built under the **Executable Reality doctrine**.

This repository is the **source-of-truth engine** powering Phoenix Protocol v2 and future Command Academy tracks.

---

## 🔥 What Makes This Different

Command Academy is not a traditional course platform.

It enforces:

- Deterministic lesson generation
- Empty-sandbox safe labs
- Read-only cloud execution
- Behavior-based validation
- Immutable audit trails

Every lesson must execute successfully in:
- Brand new cloud accounts
- Empty sandboxes
- Enterprise environments

No assumptions. No hallucinations. No brittle checks.

---

## 🧠 Core Doctrine (Non-Negotiable)

All content must obey:

- ❌ No hardcoded resource names (no `s3://my-bucket`)
- ❌ No quantity assumptions (`count > 0`)
- ❌ No hardcoded account IDs
- ✅ Read-only AWS CLI only
- ✅ Success = command execution, not resource presence
- ✅ Validation logic must match executed command

Violations fail generation.

---

## 🛡️ Phoenix Protocol v2 — Status

| Component | Status |
|---------|--------|
| Generator | Hardened |
| Schema | Locked |
| Contract | Enforced |
| Lessons (L001–L008) | Audited |
| Empty Sandbox Safe | ✅ |
| Deterministic | ✅ |

**Audit Tag:** `PHOENIX_V2_AUDITED`

---

## 📁 Repository Structure

```text
app/academy/        → Frontend academy runtime
cert_intel/         → Canon, schemas, generator, validation
engine/output/      → Rendered artifacts (derived)
audit/              → Executable Reality audit evidence
architecture/       → Doctrine and system architecture

## Governance Note

This repository is governed by organization-level branch protection.
Administrator bypass is disabled by policy.

All changes to Phoenix Protocol v2 require pull requests and review.
