# Phoenix v2 Validation Rules

Phoenix v2 uses **Behavior-Based Validation**:
- Validate that a real command executes successfully.
- Avoid requiring the existence of specific resources (buckets, instance IDs, etc.)
- Prefer read-only inspection commands unless a canon explicitly opts into creation labs.

Rule set:
1) **No fictional tools**. Only standard tools for the archetype.
2) **No dead repos/URLs** unless verified and vendored.
3) **Validation must align with the lab**:
   - validate.command must match the primary command used in lab steps (or the specific command stated as “validation command”).
4) **Deterministic output**:
   - use --query and --output text for AWS CLI where possible.
   - expected may be "__EMPTY__" in transcripts to represent empty string.
5) **Sandbox safe**:
   - default to read-only commands (list/describe/get) unless the canon is a write-lab canon.
