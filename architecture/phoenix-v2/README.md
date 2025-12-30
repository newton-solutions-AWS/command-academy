# Phoenix v2 — Canon Architecture (Audit-Safe Lesson Factory)

Phoenix v2 is the reference architecture for all ATILS lesson canons.

Design goals:
- **Executable Reality**: only real tools, real commands, no fake repos/tools.
- **Deterministic validation**: validate execution safely without brittle “magic strings”.
- **Sandbox-safe** by default (read-only unless a canon explicitly opts into write-labs).
- **Contract-driven**: schema + extra Phoenix v2 contract rules prevent bad content from shipping.

What this gives us:
- One engine that can generate high-quality lessons for many domains (AWS, Azure, Linux, Networking, Security)
- Archetype-based prompts so non-AWS lessons don’t get forced into AWS.
