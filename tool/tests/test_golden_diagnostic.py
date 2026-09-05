import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from golden_diagnostic import compare, summarize


class GoldenProtocolTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        image = self.root / 'manyui/test/widget/failures/widget_testImage.png'
        image.parent.mkdir(parents=True)
        image.write_bytes(b'fresh PNG fixture')
        self.events = [
            {'type': 'testStart', 'test': {'id': 1, 'name': 'widget golden'}},
            {'type': 'testDone', 'testID': 1, 'result': 'failure', 'skipped': False},
            {'type': 'done', 'success': False},
        ]

    def result(self, events=None, code=1):
        return summarize('\n'.join(json.dumps(e) for e in (self.events if events is None else events)), code, self.root)

    def test_matching_failures_remain_explicit(self):
        result = self.result()
        self.assertEqual(compare(result, copy.deepcopy(result)), 'KNOWN_BASELINE_FAILURE')

    def test_aborted_protocol_rejected(self):
        with self.assertRaises(ValueError):
            self.result(self.events[:-1])
        with self.assertRaises(ValueError):
            self.result(code=137)

    def test_no_tests_rejected(self):
        with self.assertRaises(ValueError):
            self.result([{'type': 'done', 'success': True}], code=0)

    def test_inconsistent_exit_rejected(self):
        with self.assertRaises(ValueError):
            self.result(code=0)

    def test_missing_fresh_images_rejected(self):
        for path in self.root.rglob('*.png'):
            path.unlink()
        with self.assertRaises(ValueError):
            self.result()

    def test_failed_name_count_or_pixels_drift_rejected(self):
        original = self.result()
        for key, value in [('counts', {'total': 2}), ('failed_test_names', ['other']),
                           ('failure_images_sha256', {'changed.png': 'bad'})]:
            changed = copy.deepcopy(original)
            changed[key] = value
            with self.assertRaises(ValueError):
                compare(original, changed)

    def test_improvement_requires_review(self):
        original = self.result()
        improved = {**original, 'exit_status': 0, 'failed_test_names': []}
        with self.assertRaises(ValueError):
            compare(original, improved)


if __name__ == '__main__':
    unittest.main()
