#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"
# Windows bind mounts can have a different owner inside Docker. Trust only this
# explicitly opened workspace, only in the container user's configuration.
if [ -f /.dockerenv ]; then
  if ! git config --global --get-all safe.directory 2>/dev/null | grep -Fxq "$root"; then
    git config --global --add safe.directory "$root"
  fi
fi
current=$(git config --local --get core.hooksPath 2>/dev/null || true)
if [ -n "$current" ] && [ "$current" != ".course-monitor/hooks" ]; then
  echo "Existing core.hooksPath=$current; integrate the course hook manually." >&2
  exit 2
fi
if [ -z "$current" ] && [ -f "$(git rev-parse --git-path hooks)/pre-commit" ]; then
  echo 'Existing pre-commit hook; integrate the course hook manually.' >&2
  exit 2
fi
git config --local core.hooksPath .course-monitor/hooks
mkdir -p .ai/events .ai/submissions
chmod 700 .ai/events .ai/submissions
chmod 755 .course-monitor/hooks/pre-commit
echo 'Course monitor hooks installed.'
