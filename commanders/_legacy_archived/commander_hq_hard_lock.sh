#!/usr/bin/env bash
set -e

echo "🧭 COMMANDER 14 — HQ HARD LOCK"
echo "📍 Enforcing HQ as sole global command authority"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Assert HQ exists
# ------------------------------------------------------------
if [ ! -d "app/hq" ]; then
  echo "❌ ERROR: /app/hq does not exist"
  exit 1
fi

echo "✅ HQ route confirmed"

# ------------------------------------------------------------
# 2) Create global Command Context
# ------------------------------------------------------------
mkdir -p lib/command

cat > lib/command/CommandContext.tsx <<'TSX'
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
TSX

echo "✅ CommandContext written"

# ------------------------------------------------------------
# 3) Wrap root layout
# ------------------------------------------------------------
ROOT_LAYOUT="app/layout.tsx"

if ! grep -q "CommandProvider" "$ROOT_LAYOUT"; then
  sed -i '' '1i\
import { CommandProvider } from "@/lib/command/CommandContext";
' "$ROOT_LAYOUT"

  sed -i '' 's/<body>/<body><CommandProvider>/' "$ROOT_LAYOUT"
  sed -i '' 's/<\/body>/<\/CommandProvider><\/body>/' "$ROOT_LAYOUT"
fi

echo "✅ Root layout wrapped"

# ------------------------------------------------------------
# 4) Enforce HQ-only mutation
# ------------------------------------------------------------
if grep -R "useCommandControl" app | grep -v "app/hq"; then
  echo "❌ ERROR: useCommandControl used outside HQ"
  exit 1
fi

echo "✅ Command mutation restricted to HQ"

# ------------------------------------------------------------
# 5) Build check
# ------------------------------------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ COMMANDER 14 COMPLETE — HQ IS THE NORTH STAR"
echo "🚀 Run: npm run dev"
