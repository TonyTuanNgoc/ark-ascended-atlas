"""Validate Island-only changes, packaged media and honest coverage counts."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / 'native/Ascended/Resources'
read = lambda p: json.loads(p.read_text())
spots = read(RES / 'verified-resource-spots.json')
guides = read(RES / 'resource-guides.json')
for name, data, key in [('verified-resource-spots.json', spots, 'spots'), ('resource-guides.json', guides, 'guides')]:
    old = json.loads(subprocess.check_output(['git', 'show', 'HEAD:native/Ascended/Resources/' + name], cwd=ROOT))
    assert [r for r in old[key] if r['map'] != 'the-island'] == [r for r in data[key] if r['map'] != 'the-island'], name
active = {s['id']: s for s in spots['spots'] if s['verified']}
assert 'island-cave-black-pearls' not in active
assert 'island-redwood-paste' not in active
for row in spots['coverage']:
    expected = [s['id'] for s in spots['spots'] if s['verified'] and s['map'] == row['map'] and row['resource'] in s['resources']]
    assert row['spotIDs'] == expected, (row['map'], row['resource'])
for row in guides['coverage']:
    assert row['verifiedRegions'] == sum(g['map'] == row['map'] and g['spotID'] in active for g in guides['guides']), row['map']
baseline = json.loads(subprocess.check_output(['git', 'show', 'HEAD:native/Ascended/Resources/resource-guides.json'], cwd=ROOT))
old_ids = {g['spotID'] for g in baseline['guides']}
movies = []
for guide in guides['guides']:
    if guide['spotID'] in old_ids:
        continue
    assert guide['spotID'] in active and guide['map'] == 'the-island'
    assert guide['rightsBasis'] == 'licensed'
    for step in guide['steps']:
        movie = RES / 'ResourceClips' / (step['loop'] + '.mp4')
        poster = RES / 'ResourceClips' / (step['poster'] + '.jpg')
        probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error', '-show_streams', '-show_format', '-of', 'json', str(movie)]))
        duration = float(probe['format']['duration'])
        assert 3 <= duration <= 10.05
        assert duration >= 6 or guide.get('shortClipReason')
        assert all(s['codec_type'] != 'audio' for s in probe['streams'])
        assert probe['streams'][0]['codec_name'] == 'h264'
        assert hashlib.sha256(movie.read_bytes()).hexdigest() == step['sha256']
        assert poster.is_file()
        assert step['mapOverlayVisible'] is False and step['inventoryOverlayVisible'] is False
        subprocess.run(['ffmpeg', '-v', 'error', '-xerror', '-i', str(movie), '-f', 'null', '-'], check=True, capture_output=True)
        movies.append({'spotID': guide['spotID'], 'seconds': duration})
resources = ['Black Pearls', 'Cementing Paste', 'Chitin', 'Crystal', 'Giant Bee Honey', 'Metal', 'Obsidian', 'Oil', 'Organic Polymer', 'Rare Flowers', 'Rare Mushrooms', 'Rich Metal', 'Sap', 'Silica Pearls']
counts = {r: sum(s['map'] == 'the-island' and r in s['resources'] for s in active.values()) for r in resources}
for r in ['Metal', 'Oil', 'Obsidian', 'Organic Polymer', 'Cementing Paste']:
    assert counts[r] >= 5, (r, counts[r])
print(json.dumps({'status': 'passed', 'islandCounts': counts, 'newMovies': movies, 'islandVerifiedRegions': sum(s['map'] == 'the-island' for s in active.values()), 'otherMapEntriesUnchanged': True}, indent=2))
