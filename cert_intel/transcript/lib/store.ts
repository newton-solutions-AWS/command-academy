import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { TranscriptEventSchema, type TranscriptEvent, type TranscriptStatus } from "./schema";

function ensureDir(p: string) {
  fs.mkdirSync(p, { recursive: true });
}

function nowIso() {
  return new Date().toISOString();
}

export function transcriptDirFor(canon: string, version: string) {
  return path.join("cert_intel", "transcript", canon, version);
}

export function transcriptPathFor(studentId: string, canon: string, version: string) {
  const dir = transcriptDirFor(canon, version);
  return path.join(dir, `${studentId}.jsonl`);
}

export function sha256(text: string) {
  return crypto.createHash("sha256").update(text).digest("hex");
}

/**
 * Append-only transcript event log (JSONL).
 * Immutable by convention: never rewrite lines, only append.
 */
export function appendTranscriptEvent(event: Omit<TranscriptEvent, "ts">) {
  const withTs = { ...event, ts: nowIso() };
  const parsed = TranscriptEventSchema.parse(withTs);

  const filePath = transcriptPathFor(parsed.student_id, parsed.canon, parsed.version);
  ensureDir(path.dirname(filePath));
  fs.appendFileSync(filePath, JSON.stringify(parsed) + "\n", "utf8");

  return parsed;
}

/**
 * Read transcript events from JSONL.
 * If file missing -> empty list.
 */
export function readTranscriptEvents(studentId: string, canon: string, version: string): TranscriptEvent[] {
  const filePath = transcriptPathFor(studentId, canon, version);
  if (!fs.existsSync(filePath)) return [];

  const raw = fs.readFileSync(filePath, "utf8");
  const lines = raw.split("\n").map((l) => l.trim()).filter(Boolean);

  const events: TranscriptEvent[] = [];
  for (const line of lines) {
    try {
      const obj = JSON.parse(line);
      const parsed = TranscriptEventSchema.parse(obj);
      events.push(parsed);
    } catch {
      // If a line is corrupted, skip it rather than killing reads.
      // (You can tighten this later with strict mode.)
      continue;
    }
  }
  return events;
}

/**
 * Compute a deterministic status from transcript events.
 * PASS means: last outcome for lesson is PASS.
 * FAIL means: last outcome for lesson is FAIL (and not later passed).
 */
export function computeTranscriptStatus(params: {
  studentId: string;
  canon: string;
  version: string;
  requiredLessonIds?: string[]; // optional; if provided, certificate eligibility requires all PASS
}): TranscriptStatus {
  const { studentId, canon, version, requiredLessonIds } = params;
  const events = readTranscriptEvents(studentId, canon, version);

  const lastByLesson = new Map<string, TranscriptEvent>();
  for (const e of events) {
    lastByLesson.set(e.lesson_id, e);
  }

  const passed: string[] = [];
  const failed: string[] = [];
  for (const [lessonId, e] of lastByLesson.entries()) {
    if (e.outcome === "PASS") passed.push(lessonId);
    else failed.push(lessonId);
  }

  passed.sort();
  failed.sort();

  let eligible = passed.length > 0 && failed.length === 0;
  if (requiredLessonIds && requiredLessonIds.length > 0) {
    const need = new Set(requiredLessonIds);
    for (const id of passed) need.delete(id);
    eligible = eligible && need.size === 0;
  }

  return {
    student_id: studentId,
    canon,
    version,
    passed_lessons: passed,
    failed_lessons: failed,
    total_events: events.length,
    eligible_for_certificate: eligible,
  };
}
