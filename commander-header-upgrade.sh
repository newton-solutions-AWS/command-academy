#!/usr/bin/env bash
echo "🪖 Upgrading Command Header..."

cat << 'EOF' > components/ui/CommandHeader.tsx
export default function CommandHeader() {
  return (
    <header className="flex justify-between items-start">
      <div className="space-y-2">
        <p className="text-xs tracking-widest text-neutral-400">
          NEWTON COMMAND ACADEMY
        </p>
        <h1 className="text-3xl font-semibold tracking-wide">
          COMMAND INTERFACE
        </h1>
        <p className="text-sm text-neutral-400">
          Configure operational posture before deployment.
        </p>
      </div>

      <div className="flex gap-3 text-xs">
        <span className="px-3 py-1 border border-green-500 text-green-400 rounded">
          ATILS ONLINE
        </span>
        <span className="px-3 py-1 border border-neutral-700 rounded">
          STANDARD OPERATOR MODE
        </span>
      </div>
    </header>
  );
}
EOF

echo "✅ Header upgraded"