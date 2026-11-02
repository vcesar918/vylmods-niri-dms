#!/usr/bin/env python3
"""Edit only a uniquely identifiable, simple top-level Niri layout setting."""
import re
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text()
lines = source.splitlines(keepends=True)
# Refuse complex or ambiguous layouts instead of guessing at KDL structure.
starts = [i for i, line in enumerate(lines) if re.fullmatch(r'\s*layout\s*\{\s*(?://[^\n]*)?\n?', line)]
settings = [i for i, line in enumerate(lines) if re.fullmatch(r'\s*center-focused-column\s+"(?:never|always|on-overflow)"\s*;?\s*(?://[^\n]*)?\n?', line)]
if len(starts) != 1 or len(settings) != 1 or settings[0] <= starts[0]:
    sys.exit(1)
# Require the setting before any nested block or closing brace in the layout.
if any(re.search(r'[{}]', line.split('//', 1)[0]) for line in lines[starts[0] + 1:settings[0]]):
    sys.exit(1)
lines[settings[0]] = re.sub(r'"(?:never|on-overflow)"', '"always"', lines[settings[0]], count=1)
Path(sys.argv[2]).write_text(''.join(lines))
