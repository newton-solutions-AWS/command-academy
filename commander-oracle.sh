#!/usr/bin/env bash
echo "🔮 Deploying ORACLE..."

cat << 'EOF' > components/ui/Oracle.tsx
"use client";

export default function Oracle() {
  return (
    <button className="fixed bottom-6 right-6 px-4 py-2 rounded-full border border-green-500 text-green-400 text-xs tracking-widest hover:bg-green-500/10">
      ORACLE
    </button>
  );
}
EOF

echo "✅ Oracle ready"