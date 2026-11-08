#!/usr/bin/env python3
"""Add a single managed Niri startup command without changing other settings."""
import json
import sys
from pathlib import Path

source, output, helper = map(Path, sys.argv[1:])
marker = '// vylmods: start Niri width memory'
text = source.read_text()
path = str(helper)
if any(ord(c) < 32 for c in path):
    sys.exit('Unsupported control character in helper path')
line = f'spawn-at-startup "python3" {json.dumps(path, ensure_ascii=False)}'
count = text.count(marker)
if count:
    lines = text.splitlines()
    positions = [i for i, item in enumerate(lines) if item == marker]
    if count != 1 or len(positions) != 1 or positions[0] + 1 >= len(lines) or lines[positions[0] + 1] != line:
        sys.exit('Existing managed startup entry differs; inspect it before updating')
    output.write_text(text)
else:
    output.write_text(text + ('' if not text or text.endswith('\n') else '\n') + '\n' + marker + '\n' + line + '\n')
