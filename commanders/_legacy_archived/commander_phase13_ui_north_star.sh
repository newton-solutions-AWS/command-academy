#!/usr/bin/env bash
set -euo pipefail

echo "🎛 PHASE 13 — OPERATOR NORTH STAR UI"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Global UI Tokens (no logic touched)
# ------------------------------------------------------------
cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --bg-void: #050505;
  --panel: rgba(255,255,255,0.04);
  --panel-strong: rgba(255,255,255,0.08);
  --border: rgba(255,255,255,0.12);
  --text-soft: rgba(255,255,255,0.65);
  --text-hard: rgba(255,255,255,0.92);
}

body {
  background: radial-gradient(1200px 600px at 50% -20%, rgba(59,130,246,0.06), transparent),
              var(--bg-void);
  color: var(--text-hard);
}
CSS

# ------------------------------------------------------------
# 2) Shell polish (HQ feel)
# ------------------------------------------------------------
cat > components/ui/Shell.tsx <<'TSX'
export default function Shell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen px-6 py-6">
      <div className="max-w-[1400px] mx-auto space-y-6">
        {children}
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 3) Panel hierarchy upgrade
# ------------------------------------------------------------
cat > components/ui/Panel.tsx <<'TSX'
type Props = {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
};

export default function Panel({ title, subtitle, children }: Props) {
  return (
    <section className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl shadow-lg">
      <header className="px-5 py-4 border-b border-white/10">
        <h2 className="text-sm tracking-wider">{title}</h2>
        {subtitle && (
          <p className="text-xs text-white/50 mt-1">{subtitle}</p>
        )}
      </header>
      <div className="p-5">{children}</div>
    </section>
  );
}
TSX

# ------------------------------------------------------------
# 4) Command Header — true HQ presence
# ------------------------------------------------------------
cat > components/ui/CommandHeader.tsx <<'TSX'
type Props = {
  title: string;
  subtitle: string;
  division: string;
};

export default function CommandHeader({ title, subtitle, division }: Props) {
  return (
    <header className="rounded-2xl border border-white/10 bg-black/50 backdrop-blur-xl px-6 py-6">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-xs tracking-[0.3em] text-white/50">
            NEWTON COMMAND ACADEMY
          </div>
          <h1 className="text-2xl font-semibold mt-2">{title}</h1>
          <p className="text-sm text-white/60 mt-1 max-w-2xl">
            {subtitle}
          </p>
        </div>
        <div className="text-xs text-white/60 tracking-widest uppercase">
          {division}
        </div>
      </div>
    </header>
  );
}
TSX

# ------------------------------------------------------------
# 5) Subtle motion utility (no deps)
# ------------------------------------------------------------
cat > components/ui/Motion.tsx <<'TSX'
export function Motion({ children }: { children: React.ReactNode }) {
  return (
    <div className="transition-all duration-300 ease-out hover:translate-y-[-2px] hover:shadow-xl">
      {children}
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 6) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 13 COMPLETE — OPERATOR NORTH STAR UI LIVE"
echo "🚀 Run: npm run dev"
