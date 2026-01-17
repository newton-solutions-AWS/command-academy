#!/usr/bin/env bash
echo "📡 Deploying System Status..."

cat << 'EOF' > components/deck/SystemStatusDeck.tsx
import Panel from "@/components/ui/Panel";

export default function SystemStatusDeck() {
  return (
    <Panel title="SYSTEM STATUS">
      <ul className="text-xs text-neutral-400 space-y-1">
        <li>Division: VANGUARD</li>
        <li>Layout: TACTICAL</li>
        <li>Learning: GAMIFIED</li>
        <li>Noise Reduction: OFF</li>
      </ul>
    </Panel>
  );
}
EOF

echo "✅ System Status deployed"