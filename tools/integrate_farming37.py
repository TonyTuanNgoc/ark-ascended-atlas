"""Package reviewed Island clips and retain browser capture clock provenance.

Calls the existing media validator; enriches only accepted reviewed regions.
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / 'native/Ascended/Resources'
manifest = Path(sys.argv[1])
data = json.loads(manifest.read_text())
rows = data if isinstance(data, list) else data['entries']
result = subprocess.run([sys.executable, str(ROOT / 'tools/integrate_farming32.py'), str(manifest)], check=True, capture_output=True, text=True)
print(result.stdout, end='')
accepted = set(json.loads(result.stdout)['accepted'])
spots_path = RES / 'verified-resource-spots.json'
guides_path = RES / 'resource-guides.json'
spots = json.loads(spots_path.read_text())
guides = json.loads(guides_path.read_text())
by_spot = {s['id']: s for s in spots['spots']}
by_guide = {g['spotID']: g for g in guides['guides']}
for row in rows:
    if row['id'] not in accepted:
        continue
    assert row['map'] == 'the-island'
    assert row.get('visualReviewStatus') == 'verified'
    capture = {k: row[k] for k in ['captureStartSeconds', 'captureEndSeconds', 'sourceClockPrecision', 'sourcePlaybackRate', 'captureFile'] if k in row}
    if capture:
        by_guide[row['id']]['sourceCapture'] = capture
    for key in ['shortClipReason', 'sourceTimestampMeaning', 'sourceChapterStartSeconds', 'sourceChapterEndSeconds', 'recoveredSource']:
        if key in row:
            by_guide[row['id']][key] = row[key]
    if row.get('mountRecommendations'):
        by_spot[row['id']]['mountRecommendations'] = row['mountRecommendations']
spots_path.write_text(json.dumps(spots, indent=2) + '\n')
guides_path.write_text(json.dumps(guides, indent=2) + '\n')
