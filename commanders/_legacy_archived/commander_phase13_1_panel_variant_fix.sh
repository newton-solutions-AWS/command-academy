#!/usr/bin/env bash
set -euo pipefail

echo "🛠 PHASE 13.1 — PANEL VARIANT COMPAT FIX"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Patch Panel.tsx to accept variant safely
# ------------------------------------------------------------
cat > components/ui/Panel.tsx <<'TSX'
type Props = {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  variant?: "active" | "neutral" | "muted";
};

export default function Panel({
  title,
  subtitle,
  children,
  variant = "neutral",
}: Props) {
  const variantStyles = {
    active: "border-blue-400/40 bg-black/60",
    neutral: "border-white/10 bg-black/40",
    muted: "border-white/5 bg-black/30",
  }[variant];

  return (
    <section
      className={`rounded-2xl backdrop-blur-xl shadow-lg border ${variantStyles}`}
    >
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
# 2) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 13.1 COMPLETE — VARIANT SAFE, UI INTACT"
echo "🚀 Run: npm run dev"
