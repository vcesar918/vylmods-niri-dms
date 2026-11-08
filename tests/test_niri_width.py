import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('width', Path(__file__).resolve().parents[1] / 'features/niri_width.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class WidthTest(unittest.TestCase):
    def test_capture_and_restore(self):
        calls, writes = [], []
        memory = module.WidthMemory({}, lambda *x: calls.append(x), lambda x: writes.append(dict(x)), {'screen': {'logical': {'width': 1920, 'height': 1080}}})
        window = {'id': 1, 'app_id': 'zen', 'is_focused': True, 'is_floating': False, 'workspace_id': 1, 'layout': {'tile_size': [500, 1000]}}
        memory.event({'WorkspacesChanged': {'workspaces': [{'id': 1, 'output': 'screen'}]}})
        memory.event({'WindowsChanged': {'windows': [window]}})
        self.assertEqual(calls, [])
        memory.event({'WindowLayoutsChanged': {'changes': [[1, {'tile_size': [780, 900]}]]}})
        self.assertEqual(writes[-1], {'zen': 780})
        memory.event({'WindowClosed': {'id': 1}})
        memory.event({'WindowOpenedOrChanged': {'window': dict(window, id=2)}})
        self.assertEqual(calls, [(2, 780)])

    def test_fullscreen_is_not_saved_or_restored(self):
        calls, writes = [], []
        memory = module.WidthMemory({'zen': 700}, lambda *x: calls.append(x), lambda x: writes.append(dict(x)), {'screen': {'logical': {'width': 1920, 'height': 1080}}})
        memory.event({'WorkspacesChanged': {'workspaces': [{'id': 1, 'output': 'screen'}]}})
        memory.event({'WindowsChanged': {'windows': []}})
        w = {'id': 3, 'app_id': 'zen', 'workspace_id': 1, 'is_focused': True, 'is_floating': False, 'layout': {'tile_size': [1920, 1080]}}
        memory.event({'WindowOpenedOrChanged': {'window': w}})
        memory.event({'WindowLayoutsChanged': {'changes': [[3, {'tile_size': [1920, 1080]}]]}})
        self.assertEqual(calls, [])
        self.assertEqual(writes, [])

    def test_ignores_unfocused_and_floating(self):
        calls, writes = [], []
        memory = module.WidthMemory({}, lambda *x: calls.append(x), lambda x: writes.append(dict(x)), {'screen': {'logical': {'width': 1920, 'height': 1080}}})
        memory.event({'WorkspacesChanged': {'workspaces': [{'id': 1, 'output': 'screen'}]}})
        memory.event({'WindowsChanged': {'windows': [{'id': 1, 'app_id': 'x', 'is_focused': False, 'workspace_id': 1}, {'id': 2, 'app_id': 'y', 'is_focused': True, 'is_floating': True, 'workspace_id': 1}]}})
        memory.event({'WindowLayoutsChanged': {'changes': [[1, {'tile_size': [500, 900]}], [2, {'tile_size': [600, 900]}]]}})
        self.assertEqual(writes, [])

if __name__ == '__main__':
    unittest.main()
