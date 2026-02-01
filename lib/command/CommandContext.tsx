"use client";

import { createContext, useContext, useState } from "react";

export type Division = "phoenix" | "vanguard" | "sentinel";
export type InterfaceMode = "tactical" | "university" | "government";
export type LearningMode = "guided" | "self-paced" | "socratic";

export interface CommandState {
  division: Division;
  interfaceMode: InterfaceMode;
  learningMode: LearningMode;
}

const DEFAULT_COMMAND_STATE: CommandState = {
  division: "phoenix",
  interfaceMode: "tactical",
  learningMode: "guided",
};

type CommandContextType = {
  state: CommandState;
  setState: (next: CommandState) => void;
};

const CommandContext = createContext<CommandContextType | null>(null);

export function CommandProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<CommandState>(DEFAULT_COMMAND_STATE);

  return (
    <CommandContext.Provider value={{ state, setState }}>
      {children}
    </CommandContext.Provider>
  );
}

export function useCommandState(): CommandState {
  const ctx = useContext(CommandContext);
  if (!ctx) throw new Error("CommandContext missing");
  return ctx.state;
}

export function useCommandControl(): CommandContextType {
  const ctx = useContext(CommandContext);
  if (!ctx) throw new Error("CommandContext missing");
  return ctx;
}
