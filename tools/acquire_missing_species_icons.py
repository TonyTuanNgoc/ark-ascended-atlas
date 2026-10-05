"""Acquire exact named dossier icons, preserving source alpha for white UI rendering."""
import concurrent.futures, hashlib, io, json, re, subprocess, time, threading
from pathlib import Path
from urllib.parse import quote, unquote
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'native/Ascended/Assets.xcassets'
CACHE = Path('/Volumes/TONY SSD/ASCENDED_MEDIA/species-icon-review')
CACHE.mkdir(parents=True, exist_ok=True)
SOURCE_PAUSED = threading.Event()
ALIASES = json.loads((ROOT / 'native/Ascended/Resources/creature-silhouette-aliases.json').read_text())['aliases']
VARIANTS = set('aberrant alpha corrupted tek x r spirit brute skeletal zombie malfunctioned polar summoned'.split())
records = {}
for path in (ROOT / 'native/Ascended/Resources').glob('*-creatures.json'):
    data = json.loads(path.read_text())
    for creature in data['creatures']:
        cid = creature['id']
        base = '-'.join(part for part in cid.split('-') if part not in VARIANTS)
        names = ['Dino-' + cid, ALIASES.get(cid, ''), 'Dino-' + base]
        if not any(name and (ASSETS / (name + '.imageset')).exists() for name in names):
            records[cid] = creature['name']

def fetch(url, path):
    if not path.exists():
        if SOURCE_PAUSED.is_set():
            raise ValueError('Deferred after source rate limit or transport refusal')
        result = subprocess.run(['curl', '-fLs', '--max-time', '25', '-w', '%{http_code}', url, '-o', str(path)], capture_output=True)
        if result.returncode:
            path.unlink(missing_ok=True)
            status = result.stdout.decode().strip()
            if status == '429' or result.returncode == 56:
                SOURCE_PAUSED.set()
            raise ValueError('Public source unavailable: HTTP ' + status + ', curl ' + str(result.returncode))
    return path.read_bytes()

def acquire(pair):
    cid, name = pair
    page_name = {'light-bug': 'Glowbug', 'titanomyrma-drone': 'Titanomyrma', 'titanomyrma-soldier': 'Titanomyrma'}.get(cid, name.replace(' ', '_'))
    page = 'https://ark.wiki.gg/wiki/' + quote(page_name, safe='_')
    result = {'id': cid, 'name': name, 'page': page}
    try:
        html = fetch(page, CACHE / (cid + '.html')).decode()
        # Exact creature icon filename only: no gallery photo, render, egg, saddle or map.
        filename = page_name + '.png'
        match = next((src for src in re.findall(r'<img[^>]+src="([^"]+)"', html)
                      if unquote(src.split('/thumb/')[-1].split('/')[0].split('?')[0]) == filename), None)
        if not match:
            raise ValueError('No exact named dossier icon on source page')
        url = 'https://ark.wiki.gg/images/' + quote(filename, safe='_')
        raw = fetch(url, CACHE / (cid + '.png'))
        image = Image.open(io.BytesIO(raw)).convert('RGBA')
        if min(image.size) < 64 or image.getchannel('A').getextrema()[0] != 0:
            raise ValueError('Not a usable transparent dossier icon')
        folder = ASSETS / ('Dino-' + cid + '.imageset')
        folder.mkdir(exist_ok=True)
        image.save(folder / 'image.png')
        (folder / 'Contents.json').write_text(json.dumps({'images': [{'filename': 'image.png', 'idiom': 'universal'}], 'info': {'author': 'xcode', 'version': 1}}, indent=2) + '\n')
        result.update(status='ready', imageURL=url, pixels=list(image.size), sha256=hashlib.sha256(raw).hexdigest())
    except Exception as error:
        result.update(status='unavailable', reason=str(error))
    return result

with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
    results = []
    for result in pool.map(acquire, records.items()):
        results.append(result)
        print(result['id'], result['status'], flush=True)
        time.sleep(0.8)
report = ROOT / 'docs/codex-reports/2026-10-05-species-icon-sources.json'
previous = json.loads(report.read_text()) if report.exists() else []
updated = {row['id']: row for row in previous}
updated.update({row['id']: row for row in results})
report.write_text(json.dumps(list(updated.values()), indent=2) + '\n')
print('Ready', sum(row['status'] == 'ready' for row in results), '/', len(results))
