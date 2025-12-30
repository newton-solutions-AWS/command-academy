# Modules (Phoenix v2 content blocks)

Every lesson artifact contains:
- id / canon / version / title
- objectives (>=3)
- mission_brief (situation/mission/execution)
- prerequisites (>=1)
- content:
  - concept (>=200 chars)
  - walkthrough (>=200 chars)
  - checkpoints (>=3 strings)
  - common_mistakes (>=3 strings)
- lab:
  - type (guided-cli for Phoenix v2)
  - setup (string)
  - steps (>=5 strings, must include at least one real command for the archetype)
  - safety (>=3 strings)
  - validate { command, expected, match } (must align with lab command policy)
- elite_competence:
  - scenario_name, role_simulation
  - bug_injection { bug, symptom, fix }
  - success_criteria { pass_conditions, fail_conditions }
  - interrogation_questions (>=3)
- legal_context { allowed, prohibited }
- resume_bullets (>=3)
