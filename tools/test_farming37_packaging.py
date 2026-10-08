"""Regression: rejected replacement cannot alter provenance of accepted media."""
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class PackagingTests(unittest.TestCase):
    def testRejectedReplacementRetainsProvenanceAndExcludesQuarantine(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tools/evidence/farming37') as folder:
            root = Path(folder)
            (root / 'tools').mkdir()
            res = root / 'native/Ascended/Resources'
            res.mkdir(parents=True)
            for name in ['integrate_farming32.py', 'integrate_farming37.py']:
                shutil.copy2(ROOT / 'tools' / name, root / 'tools' / name)
            spots = {'spots': [
                {'id': 'accepted', 'map': 'the-island', 'resources': ['Metal'], 'verified': True},
                {'id': 'quarantined', 'map': 'the-island', 'resources': ['Metal'], 'verified': False}
            ], 'coverage': [{'map': 'the-island', 'resource': 'Metal', 'spotIDs': ['accepted', 'quarantined']}]}
            guides = {'guides': [
                {'spotID': 'accepted', 'map': 'the-island', 'sourceCapture': {'original': True}},
                {'spotID': 'quarantined', 'map': 'the-island'}
            ], 'coverage': [{'map': 'the-island', 'verifiedRegions': 2}]}
            for name, data in [('verified-resource-spots.json', spots), ('resource-guides.json', guides)]:
                (res / name).write_text(json.dumps(data))
            manifest = root / 'rejected.json'
            manifest.write_text(json.dumps({'entries': [{
                'id': 'accepted', 'map': 'the-island', 'moviePath': str(root / 'missing.mp4'),
                'visualReviewStatus': 'verified', 'captureStartSeconds': 999,
                'mountRecommendations': [{'names': ['Wrong mount']}]
            }]}))
            output = subprocess.check_output([sys.executable, str(root / 'tools/integrate_farming37.py'), str(manifest)], text=True)
            self.assertEqual(json.loads(output)['accepted'], [])
            result = json.loads((res / 'resource-guides.json').read_text())
            self.assertEqual(result['guides'][0]['sourceCapture'], {'original': True})
            self.assertEqual(result['coverage'][0]['verifiedRegions'], 1)
            result = json.loads((res / 'verified-resource-spots.json').read_text())
            self.assertNotIn('mountRecommendations', result['spots'][0])
            self.assertEqual(result['coverage'][0]['spotIDs'], ['accepted'])

if __name__ == '__main__':
    unittest.main()
