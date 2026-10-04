#!/usr/bin/env python3
"""Validate native expansion membership, independent map planes and farm provenance."""
import hashlib,json
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]; R=ROOT/'native/Ascended/Resources'; A=ROOT/'native/Ascended/Assets.xcassets'
c=json.loads((R/'expansion-catalog.json').read_text())
assert len({m['id'] for m in c['maps']})==len(c['maps'])
available=[m for m in c['maps'] if m['status']=='available'];assert len(available)==10
assert next(m for m in c['maps'] if m['id']=='dragontopia')['status']=='upcoming'
assert any(b.startswith('Nunatak') for b in next(m for m in c['maps'] if m['id']=='ragnarok')['bosses'])
assert next(m for m in c['maps'] if m['id']=='genesis-part-1')['included']
planes=[m['id'] for m in available]+['genesis-part-1-ocean']
for mid in planes:
    creatures=json.loads((R/(mid+'-creatures.json')).read_text()); assert len({d['id'] for d in creatures['creatures']})==len(creatures['creatures'])
    exploration=json.loads((R/(mid+'-exploration.json')).read_text());assert all(k in exploration for k in ['reviewedAt','artifacts','routes','obelisks'])
    nodes=json.loads((R/(mid+'-resources.json')).read_text());assert all(0<=n['lat']<=100 and 0<=n['lon']<=100 for n in nodes)
f=json.loads((R/'verified-resource-spots.json').read_text()); assert len({s['id'] for s in f['spots']})==len(f['spots'])
counts={m:0 for m in ['ragnarok','the-island','the-center']}
for s in f['spots']:
    assert s['verified'] and s['resources'] and s['coordinateEvidence'] and s['inventoryEvidence']
    assert 0<=s['lat']<=100 and 0<=s['lon']<=100 and s['seconds']>=0
    assert s['sourceURL']=='https://www.youtube.com/watch?v='+s['videoID']
    folder=A/(s['imageAsset']+'.imageset');meta=json.loads((folder/'Contents.json').read_text());path=folder/next(i['filename'] for i in meta['images'] if 'filename' in i)
    assert hashlib.sha256(path.read_bytes()).hexdigest()==s['photoSHA256']
    im=Image.open(path);assert im.width>=1280 and im.height>=600
    counts[s['map']]+=1
for row in f.get('coverage', []):
    assert row['status'] != 'pending', (row['map'], row['resource'])
    assert all(any(s['id'] == ref and s['map'] == row['map'] for s in f['spots']) for ref in row['spotIDs'])
    if row['status'] == 'creature':
        assert row.get('imageAsset') and row.get('videoID') and row.get('coordinateEvidence')
        assert 'lat' not in row and 'lon' not in row
        folder=A/(row['imageAsset']+'.imageset');meta=json.loads((folder/'Contents.json').read_text());path=folder/next(i['filename'] for i in meta['images'] if 'filename' in i)
        assert hashlib.sha256(path.read_bytes()).hexdigest()==row['photoSHA256']
assert all(counts.values()),counts
print(json.dumps({'availableMaps':10,'mapPlanes':11,'DLCs':len(c['dlcs']),'verifiedFarmSpots':counts,'coverage':f.get('coverage',[])},ensure_ascii=False))
