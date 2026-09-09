#!/usr/bin/env bash
#
# Install the nanoPRD skills for both Claude Code and OpenCode.
#
# Both tools read ~/.claude/skills, so one link serves both. Claude Code resolves
# a skill entry that is a symlink to a directory elsewhere on disk, and OpenCode
# reads ~/.claude/skills as a compatibility source.
#
#   ./install.sh                    install to ~/.claude/skills
#   ./install.sh /path/to/skills    install somewhere else
#   ./install.sh --copy             copy instead of symlink
#   ./install.sh --uninstall        remove what this script installed
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/skills"
DEST="$HOME/.claude/skills"
MODE="link"

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)      MODE="copy" ;;
    --uninstall) MODE="uninstall" ;;
    -h|--help)   sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          echo "unknown option: $1" >&2; exit 2 ;;
    *)           DEST="$1" ;;
  esac
  shift
done

[ -d "$SRC" ] || { echo "error: $SRC not found - run this from the repo" >&2; exit 1; }

if [ "$MODE" = "uninstall" ]; then
  for dir in "$SRC"/*/; do
    name="$(basename "$dir")"
    target="$DEST/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
      echo "removed  $target"
    fi
  done
  echo
  echo "Uninstalled. Restart your Claude Code session."
  exit 0
fi

mkdir -p "$DEST"

for dir in "$SRC"/*/; do
  name="$(basename "$dir")"
  target="$DEST/$name"

  [ -f "$dir/SKILL.md" ] || { echo "skipped  $name (no SKILL.md)"; continue; }

  rm -rf "$target"

  if [ "$MODE" = "link" ] && ln -sfn "${dir%/}" "$target" 2>/dev/null && [ -L "$target" ]; then
    echo "linked   $name -> $target"
  else
    # Windows without Developer Mode, and some filesystems, cannot create
    # symlinks. Copying works, but an update needs this script run again.
    cp -R "${dir%/}" "$target"
    echo "copied   $name -> $target   (re-run this script after updating the repo)"
  fi
done

echo
echo "Done."
echo "  Claude Code: restart your session, then ask it to plan a project."
echo "  OpenCode:    skills load from ~/.claude/skills with no further config."
