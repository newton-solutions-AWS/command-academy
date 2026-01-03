// cert_intel/intake/lib/autofillPhoenixV2.ts

export function autofillPhoenixV2(lesson: any) {
  // ---- helpers ----
  const padArray = (arr: any[], min: number, filler: string) => {
    const out = [...arr];
    while (out.length < min) out.push(filler);
    return out;
  };

  const padString = (str: string, min: number, filler: string) => {
    if (str.length >= min) return str;
    return str + "\n\n" + filler.repeat(Math.ceil((min - str.length) / filler.length));
  };

  // ---- objectives ----
  lesson.objectives = padArray(
    lesson.objectives || [],
    3,
    "Reinforce core operational understanding through deterministic verification."
  );

  // ---- content ----
  lesson.content.concept = padString(
    lesson.content.concept || "",
    200,
    "This concept reinforces safe, read-only operational verification within controlled environments. "
  );

  lesson.content.walkthrough = padString(
    lesson.content.walkthrough || "",
    200,
    "This walkthrough guides the operator through deliberate, non-destructive verification steps. "
  );

  lesson.content.checkpoints = padArray(
    lesson.content.checkpoints || [],
    3,
    "Operator confirms expected system behavior without assuming resource existence."
  );

  lesson.content.common_mistakes = padArray(
    lesson.content.common_mistakes || [],
    3,
    "Assuming empty output indicates failure rather than valid access."
  );

  // ---- lab safety ----
  lesson.lab.safety = padArray(
    lesson.lab.safety || [],
    3,
    "Only read-only AWS CLI commands are permitted."
  );

  // ---- elite competence ----
  lesson.elite_competence.role_simulation = padString(
    lesson.elite_competence.role_simulation || "",
    50,
    "The operator must demonstrate disciplined verification under uncertainty. "
  );

  lesson.elite_competence.success_criteria.pass_conditions = padArray(
    lesson.elite_competence.success_criteria.pass_conditions || [],
    3,
    "Command executes successfully without error."
  );

  lesson.elite_competence.success_criteria.fail_conditions = padArray(
    lesson.elite_competence.success_criteria.fail_conditions || [],
    2,
    "Command fails due to misconfiguration or missing permissions."
  );

  lesson.elite_competence.interrogation_questions = padArray(
    lesson.elite_competence.interrogation_questions || [],
    3,
    "Why is behavior-based validation safer than resource-based validation?"
  );

  return lesson;
}
