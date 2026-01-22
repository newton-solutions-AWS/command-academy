import type { Transcript, TranscriptEntry } from "./transcriptCanon";

const KEY = "nca:transcript";

function load(): Transcript {
  if (typeof window === "undefined") {
    return { learnerId: "local", generatedAt: "", entries: [] };
  }

  const raw = localStorage.getItem(KEY);
  if (!raw) {
    return {
      learnerId: "local",
      generatedAt: new Date().toISOString(),
      entries: [],
    };
  }

  try {
    return JSON.parse(raw);
  } catch {
    return {
      learnerId: "local",
      generatedAt: new Date().toISOString(),
      entries: [],
    };
  }
}

function save(t: Transcript) {
  localStorage.setItem(KEY, JSON.stringify(t));
}

export function recordLesson(entry: TranscriptEntry) {
  const t = load();

  // Prevent duplicates
  if (t.entries.find(e => e.lessonId === entry.lessonId)) return;

  t.entries.push(entry);
  save(t);
}

export function getTranscript(): Transcript {
  return load();
}
