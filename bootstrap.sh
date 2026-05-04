#!/bin/bash
# SF Demo Scout — Bootstrap
# One-liner installer: bash -c "$(curl -fsSL <raw-url>/bootstrap.sh)"
#
# Flow: prereq check → clone (or update) → install.sh → exec claude "/setup-demo-scout"

set -e

REPO_URL="https://github.com/seb-schi/sf-demo-scout"
PROJECTS_DIR="$HOME/claude-projects"
REPO_DIR="$PROJECTS_DIR/sf-demo-scout"

echo ""
echo "🤖 SF Demo Scout — Bootstrap"
echo "================================"
echo ""

# --- 1. Prereq check: git + claude ---
MISSING=()
command -v git >/dev/null 2>&1 || MISSING+=("git")
command -v claude >/dev/null 2>&1 || MISSING+=("claude")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "❌ Missing prerequisites: ${MISSING[*]}"
  echo ""
  if [[ " ${MISSING[*]} " == *" claude "* ]]; then
    echo "   Install Claude Code first using the 'Installing Claude Code for Solutions' canvas:"
    echo "     curl -fsSL https://plugins.codegen.salesforceresearch.ai/claude/install.sh | bash"
    echo ""
  fi
  if [[ " ${MISSING[*]} " == *" git "* ]]; then
    echo "   Install git via Xcode Command Line Tools:"
    echo "     xcode-select --install"
    echo ""
  fi
  echo "   Then re-run the bootstrap one-liner."
  exit 1
fi

# --- 2. Existing install? Route to update.sh ---
if [ -d "$REPO_DIR" ]; then
  echo "📂 Existing install found at $REPO_DIR"
  echo "   Running update.sh instead..."
  echo ""
  cd "$REPO_DIR"
  exec bash update.sh
fi

# --- 3. Fresh clone ---
mkdir -p "$PROJECTS_DIR"
echo "📥 Cloning sf-demo-scout..."
git clone "$REPO_URL" "$REPO_DIR" 2>&1 | tail -1
cd "$REPO_DIR"
echo "   ✅ Cloned to $REPO_DIR"
echo ""

# --- 4. Run install.sh ---
echo "⚙️  Running install.sh..."
bash install.sh

# --- 5. Hand off to Claude Code with /setup-demo-scout queued ---
echo ""
echo "🚀 Launching Claude Code with /setup-demo-scout..."
echo ""
exec claude "/setup-demo-scout"
