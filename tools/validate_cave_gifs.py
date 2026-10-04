#!/usr/bin/env python3
"""Check decoded GIF frames, recipe correspondence, and all artifact-route coverage."""
import hashlib, json
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
r=root/'native/Ascended/Resources'
all_assets=set(); summary={}
for map_id in ['ragnarok','the-island','the-center']:
 recipe=json.loads((root/f'docs/codex-reports/2026-10-04-{map_id}-gif-recipe.json').read_text())
 manifest=json.loads((r/f'{map_id}-cave-gifs.json').read_text())
 routes=json.loads((r/f'{map_id}-exploration.json').read_text())['routes']
 expected={x['id'] for x in routes if x['artifactIDs']}
 assert {g['routeID'] for g in manifest}==expected,(map_id,expected)
 assert len(manifest)==len(expected)
 count=0; durations=[]
 for g,rg in zip(manifest,recipe['guides']):
  assert g['routeID']==rg['routeID']
  ids=set()
  for s,rs in zip(g['sections'],rg['sections']):
   assert s['id']==rs['id'] and len(s['steps'])==len(rs['steps'])
   for step,source in zip(s['steps'],rs['steps']):
    assert step['id'] not in ids; ids.add(step['id'])
    assert source['visuallyReviewed'] and step['gif']==source['gif']
    assert step.get('direction')==source.get('direction')
    key=hashlib.sha256(json.dumps([source['videoID'],source['start'],source['end'],source.get('speed',1),'512x288/8fps/64colors/bayer5'],sort_keys=True).encode()).hexdigest()
    assert source['renderKey']==key
    gif=r/'CaveGIFs'/(step['gif']+'.gif'); jpg=r/'CaveGIFs'/(step['poster']+'.jpg')
    assert gif.name not in all_assets;all_assets.update([gif.name,jpg.name])
    with Image.open(jpg) as im: im.load(); assert im.size==(640,360)
    with Image.open(gif) as im:
     assert im.n_frames>1 and im.size==(512,288) and im.info.get('loop')==0
     duration=0
     for i in range(im.n_frames):
      im.seek(i);im.load();duration+=im.info['duration']
     seconds=duration/1000
     assert 0<seconds<=16.25,(gif,seconds)
     target=(source['end']-source['start'])/source.get('speed',1)
     assert abs(seconds-target)<.3,(gif,seconds,target)
     durations.append(seconds)
    count+=1
 summary[map_id]={'routes':len(manifest),'gifs':count,'maxSeconds':max(durations)}
assert all_assets=={p.name for p in (r/'CaveGIFs').iterdir() if p.is_file()}, 'Orphan or missing asset'
summary['totalGIFs']=sum(x['gifs'] for x in summary.values())
summary['assetBytes']=sum(p.stat().st_size for p in (r/'CaveGIFs').iterdir())
(root/'docs/codex-reports/2026-10-04-cave-gif-validation.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
