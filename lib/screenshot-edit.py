#!/usr/bin/env python3
"""Prepare a screenshot binding only when included configs contain no conflict."""
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
output = Path(sys.argv[2])
seen = set()
key = re.compile(r'(?i)(?<![\w+])(?:mod|super|logo)\s*\+\s*s\s*(?:\{|[a-z_-]+\s*=)')
include = re.compile(r'^\s*include\s+"([^"\n]+)"\s*;?\s*(?://.*)?$')

def check(path):
    path = path.resolve(strict=True)
    if path in seen:
        return
    seen.add(path)
    content = path.read_text()
    if key.search(content):
        raise ValueError(f'Potential Super+S binding in {path}')
    for line in content.splitlines():
        if re.match(r'^\s*include\b', line):
            match = include.fullmatch(line)
            if not match:
                raise ValueError(f'Cannot safely inspect include in {path}')
            check(path.parent / match.group(1))

try:
    check(root)
    source = root.read_text()
    output.write_text(source + ('' if source.endswith('\n') or not source else '\n') + '\n// vylmods: Super+S screenshot\nbinds {\n    Mod+S { screenshot; }\n}\n')
except (OSError, UnicodeError, ValueError) as exc:
    print(str(exc), file=sys.stderr)
    sys.exit(1)
