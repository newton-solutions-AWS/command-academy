# COMMAND ACADEMY
**Newton Solutions // From Service to Cyber**
A doctrine-driven training runtime that generates **audit-safe**, **empty-sandbox safe**, **read-only** cloud labs — and proves them before they ship.

---

## What This Is
Command Academy is not “a course site”.

It is a **canon factory + runtime**:
- **Canon** = immutable, versioned lesson artifacts (JSON)
- **Engine** = deterministic generator + validators
- **Academy UI** = lightweight front-end that renders canon like an operating system for learning

This repo exists to do one thing exceptionally well:

> **Generate lessons that can be executed in the real world.**  
> No hallucinated tools. No magic strings. No “assume the bucket exists.”  
> **If it passes audit, it ships.**

---

## Phoenix Protocol v2 (AUDITED CANON)
Phoenix Protocol v2 is the first fully hardened doctrine inside this repo.

### Status
✅ **PASSED full static audit** (Parts 1 & 2)  
✅ **Empty-sandbox safe**  
✅ **Read-only AWS CLI only**  
✅ **No named resources** (no `s3://my-bucket`)  
✅ **No quantity assumptions** (no “must find 5 buckets”)  
✅ **No hardcoded account IDs**  
✅ **Behavior-based validation** (verifies execution, not state)

### Canon Location
`cert_intel/canon/atils/phoenix-protocol-secure-cloud-operator/v2/labs`

### Doctrine
Phoenix v2 is governed by the **Executable Reality doctrine**:

- **Reality > Narrative**
- **Determinism > Luck**
- **Behavior-based validation > State-based validation**
- **Empty sandboxes must still pass**
- **Audits are mandatory**
- **Canon is immutable once locked**

---

## Canon Immutability
Phoenix Protocol v2 is treated as **immutable canon**.

- **Do not modify v2 artifacts** after audit.
- Any change requires a **new protocol version** (e.g., `v3`).
- Changes must flow through PR review (repository rules enforce this).

See: `architecture/phoenix-v2/LOCKED.md`

---

## Quickstart (Local)
### Install
```bash
npm install
