#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
sh .course-monitor/setup.sh
if command -v code >/dev/null 2>&1; then
    code --install-extension .course-monitor/rewind-ide-0.3.0.vsix --force
else
    printf '%s\n' 'VS Code CLI is unavailable inside the container; install .course-monitor/rewind-ide-0.3.0.vsix from the host extension manager.' >&2
fi
