#!/usr/bin/env bash
set -e

echo "== BOOTSTRAP: Newton Command Academy =="

rm -rf .next
rm -rf node_modules/.cache

npm install

echo "Bootstrap complete."
