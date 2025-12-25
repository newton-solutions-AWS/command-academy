import fetch from "node-fetch";

type OllamaMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

type OllamaChatResponse = {
  message?: {
    content?: string;
  };
};

/**
 * Canonical Ollama Chat Adapter
 * This is the ONLY exported interface used by the engine.
 */
export async function ollamaChat(opts: {
  model: string;
  messages: OllamaMessage[];
}): Promise<string> {
  const res = await fetch("http://localhost:11434/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: opts.model,
      messages: opts.messages,
      stream: false
    })
  });

  if (!res.ok) {
    throw new Error(`Ollama HTTP ${res.status}`);
  }

  const json = (await res.json()) as OllamaChatResponse;

  const content = json?.message?.content;

  if (!content || typeof content !== "string") {
    throw new Error("Ollama returned empty response");
  }

  return content;
}