#!/bin/bash
# SF Demo Scout — Bootstrap
# One-liner installer: bash -c "$(curl -fsSL <raw-url>/bootstrap.sh)"
#
# Flow: prereq check → clone (or update) → install.sh → exec claude "/setup-demo-scout"

set -eo pipefail

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
# Only treat the directory as a valid install if it looks like a real Scout
# clone. A bare directory (or a partial one left over from a failed clone)
# must NOT be routed to update.sh — update.sh won't exist there.
if [ -d "$REPO_DIR/.git" ] && [ -f "$REPO_DIR/update.sh" ]; then
  echo "📂 Existing install found at $REPO_DIR"
  echo "   Running update.sh instead..."
  echo ""
  cd "$REPO_DIR"
  exec bash update.sh
elif [ -d "$REPO_DIR" ]; then
  echo "⚠️  Found $REPO_DIR but it doesn't look like a valid Scout install."
  echo "   (Missing .git/ or update.sh — likely a partial clone from an earlier failed update.)"
  echo ""
  echo "   This directory will be removed and replaced with a fresh clone."
  if [ -d "$PROJECTS_DIR/.sf-demo-scout-backup/orgs" ]; then
    echo "   Your backed-up org data at $PROJECTS_DIR/.sf-demo-scout-backup/orgs will be restored."
  fi
  echo ""
  printf "Continue? [y/N] "
  read -r CONFIRM
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled. Nothing changed."
    exit 0
  fi
  rm -rf "$REPO_DIR"
  echo "   ✅ Removed $REPO_DIR"
  echo ""
  # Fall through to fresh-clone block below.
fi

# --- 3. Fresh clone ---
mkdir -p "$PROJECTS_DIR"
echo "📥 Cloning sf-demo-scout..."
git clone "$REPO_URL" "$REPO_DIR" 2>&1 | tail -1
cd "$REPO_DIR"
echo "   ✅ Cloned to $REPO_DIR"
echo ""

# --- 4. Restore backup from a prior failed update (if present) ---
if [ -d "$PROJECTS_DIR/.sf-demo-scout-backup/orgs" ]; then
  echo "📂 Restoring orgs/ from backup..."
  cp -R "$PROJECTS_DIR/.sf-demo-scout-backup/orgs" "$REPO_DIR/orgs"
  echo "   ✅ orgs/ restored"
  echo ""
fi

# --- 5. Run install.sh ---
# install.sh auto-launches `claude "/setup-demo-scout"` at its tail when
# SF_SCOUT_CHAINED is unset, so bootstrap doesn't need its own exec line.
echo "⚙️  Running install.sh..."
exec bash install.sh
