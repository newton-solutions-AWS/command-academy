#!/usr/bin/env bash
set -e

echo "📋 AUDITING CHANGESET"
echo ""

echo "=== MODIFIED FILES ==="
git status --short | grep "^ M" || echo "None"

echo ""
echo "=== DELETED FILES ==="
git status --short | grep "^ D" || echo "None"

echo ""
echo "=== UNTRACKED FILES ==="
git status --short | grep "^??" || echo "None"

echo ""
echo "📌 AUDIT COMPLETE — NO CHANGES MADE"
