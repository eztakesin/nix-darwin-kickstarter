#!/usr/bin/env bash
set -euo pipefail

cd /Users/macbook/Workspace/nix-darwin-kickstarter

echo "=== Step 0: git add new files ==="
git add macbook/home/fish.nix macbook/home/kitty.nix macbook/home/bat.nix macbook/home/gh.nix \
       macbook/home/default.nix macbook/dotfiles/ scripts/
echo "done"

echo "=== Step 1: nix flake check ==="
cd macbook
nix flake check 2>&1 | tail -10
echo ""

echo "=== Step 2: darwin-rebuild build ==="
darwin-rebuild build --flake .#macbook 2>&1 | tail -10
echo ""

echo "=== DONE ==="
