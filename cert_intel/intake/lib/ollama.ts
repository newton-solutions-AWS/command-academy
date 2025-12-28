// cert_intel/intake/lib/ollama.ts
import fetch from "node-fetch";

type OllamaResponse = {
  response: string;
};

export async function ollamaChat(prompt: string): Promise<string> {
  const res = await fetch("http://localhost:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: process.env.MODEL || "llama3.1:latest",
      prompt,
      stream: false,
    }),
  });

  if (!res.ok) {
    throw new Error(`Ollama HTTP error ${res.status}`);
  }

  const data = (await res.json()) as OllamaResponse;

  if (!data?.response || typeof data.response !== "string") {
    throw new Error("Invalid Ollama response shape");
  }

  return data.response.trim();
}