# ATILS Gemini Audit Context — Phoenix Protocol v2 (Batch)

You are auditing 8 generated lesson artifacts.

Constraints:
- No fictional tools or repositories
- Standard AWS CLI only
- Read-only commands
- Empty-sandbox safe (no named buckets, no resource count requirements)
- No hardcoded AWS Account IDs (12-digit) or ARNs tied to specific accounts
- Deterministic validation:
  - validate.command must equal the lab AWS command
  - expected = "" and match = contains is acceptable for behavior-based validation

Goal:
Confirm deployability in a real learning environment and identify any violations of the constraints above.
