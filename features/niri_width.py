#!/usr/bin/env python3
"""Experimental Niri width memory; see docs/niri-width.md before use."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

class WidthMemory:
    def __init__(self, saved, apply, persist, outputs):
        self.saved, self.apply, self.persist = saved, apply, persist
        self.windows = {}
        self.workspaces = {}
        self.outputs = outputs
        self.initialized = False
        self.restoring = {}

    def eligible(self, window):
        return bool(window.get('app_id')) and not window.get('is_floating', False)

    def ordinary_size(self, window, layout):
        # Niri 26.04 does not expose fullscreen state. Conservatively skip
        # windows that nearly cover the output, and skip unknown outputs.
        output = self.outputs.get(self.workspaces.get(window.get('workspace_id')), {})
        logical = output.get('logical') or {}
        size = layout.get('tile_size') or []
        if len(size) != 2 or not logical.get('width') or not logical.get('height'):
            return False
        width, height = size
        if not isinstance(width, (int, float)) or not isinstance(height, (int, float)):
            return False
        return not (width >= logical['width'] * 0.9 and height >= logical['height'] * 0.9)

    def event(self, event):
        if 'WorkspacesChanged' in event:
            self.workspaces = {w['id']: w.get('output') for w in event['WorkspacesChanged']['workspaces']}
        elif 'WindowsChanged' in event:
            self.windows = {w['id']: w for w in event['WindowsChanged']['windows']}
            self.initialized = True
        elif 'WindowOpenedOrChanged' in event:
            w = event['WindowOpenedOrChanged']['window']
            previous = self.windows.get(w['id'])
            self.windows[w['id']] = w
            # Never resize windows that existed when the service started.
            if self.initialized and (previous is None or not previous.get('app_id')) and self.eligible(w) and self.ordinary_size(w, w.get('layout') or {}):
                width = self.saved.get(w['app_id'])
                if width is not None:
                    self.restoring[w['id']] = time.monotonic() + 1.5
                    self.apply(w['id'], width)
        elif 'WindowLayoutsChanged' in event:
            for window_id, layout in event['WindowLayoutsChanged']['changes']:
                window = self.windows.get(window_id)
                if not window:
                    continue
                window['layout'] = layout
                # Record focused tiled windows only. Fullscreen or layout-driven
                # changes are indistinguishable from manual resize via this IPC.
                if time.monotonic() < self.restoring.get(window_id, 0):
                    continue
                self.restoring.pop(window_id, None)
                if self.eligible(window) and window.get('is_focused') and self.ordinary_size(window, layout):
                    width = layout.get('tile_size', [None])[0]
                    if isinstance(width, (int, float)) and 100 <= width <= 10000:
                        self.saved[window['app_id']] = round(width)
                        self.persist(self.saved)
        elif 'WindowFocusChanged' in event:
            focused = event['WindowFocusChanged']['id']
            for w in self.windows.values():
                w['is_focused'] = w['id'] == focused
        elif 'WindowClosed' in event:
            self.windows.pop(event['WindowClosed']['id'], None)
            self.restoring.pop(event['WindowClosed']['id'], None)


def main():
    state = Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'vylmods-niri-dms' / 'widths.json'
    try:
        saved = json.loads(state.read_text()) if state.exists() else {}
        if not isinstance(saved, dict) or any(not isinstance(k, str) or not isinstance(v, int) or isinstance(v, bool) or not 100 <= v <= 10000 for k, v in saved.items()):
            raise ValueError('invalid width data')
    except (OSError, ValueError) as exc:
        print(f'Cannot read {state}: {exc}', file=sys.stderr)
        return 1

    def persist(data):
        state.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        fd, name = tempfile.mkstemp(dir=state.parent, prefix='.widths-')
        try:
            with os.fdopen(fd, 'w') as f:
                json.dump(data, f, sort_keys=True)
                f.write('\n')
            os.replace(name, state)
        finally:
            if os.path.exists(name):
                os.unlink(name)

    def apply(window_id, width):
        subprocess.run(['niri', 'msg', 'action', 'set-window-width', '--id', str(window_id), str(width)], check=True)

    try:
        outputs = json.loads(subprocess.check_output(['niri', 'msg', '-j', 'outputs'], text=True))
        memory = WidthMemory(saved, apply, persist, outputs)
        with subprocess.Popen(['niri', 'msg', '-j', 'event-stream'], stdout=subprocess.PIPE, text=True) as proc:
            for line in proc.stdout:
                memory.event(json.loads(line))
            return proc.wait() or 1
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f'Width memory stopped: {exc}', file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
