#!/usr/bin/env python3
"""Make a single targeted padding edit while preserving the rest of the file."""
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
pattern = re.compile(r'(?m)^[ \t]*window-padding-y[ \t]*=[^\n]*$')
matches = list(pattern.finditer(text))
if len(matches) > 1:
    sys.exit(1)
if matches:
    text = pattern.sub('window-padding-y = 2,20', text, count=1)
else:
    text += ('' if not text or text.endswith('\n') else '\n') + 'window-padding-y = 2,20\n'
Path(sys.argv[2]).write_text(text)
