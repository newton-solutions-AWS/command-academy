import fetch from "node-fetch";

export function createOllamaChat() {
  return async function ollamaChat(args: {
    model: string;
    messages: { role: "system" | "user"; content: string }[];
  }) {
    const res = await fetch("http://localhost:11434/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: args.model,
        messages: args.messages,
        stream: false
      })
    });

    const data: any = await res.json();

    if (!data?.message?.content) {
      throw new Error("Ollama returned no message content");
    }

    return {
      message: {
        content: data.message.content
      }
    };
  };
}