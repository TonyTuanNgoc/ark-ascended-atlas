#!/usr/bin/env python3
"""Acquire highest verified original Wikily tiles without resampling or changing bounds.
Tile z5 exists and z6 is 404 at sampled origin for all supported maps.
An 8192 canvas is a source tile pixel count, not proof of 8192 terrain detail.
Ragnarok retains its sharper ASA Wiki image; the tile raster adds no verified detail.
"""
import concurrent.futures, hashlib, io, json, subprocess
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
CACHE=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/map-quality24')
ASSETS=ROOT/'native/Ascended/Assets.xcassets'
REPORT=ROOT/'docs/codex-reports/2026-10-07-map-quality24-sources.json'
def fetch(url):
 return subprocess.check_output(['curl','-fLs','--retry','2','--max-time','35',url])
def acquire(record):
 name=record['map']; template=record['terrain']['template']; cache=CACHE/name;cache.mkdir(parents=True,exist_ok=True)
 def tile(pos):
  x,y=pos;p=cache/f'{x}-{y}.png'
  if not p.exists():p.write_bytes(fetch(template.replace('{z}','5').replace('{x}',str(x)).replace('{y}',str(y))))
  b=p.read_bytes();im=Image.open(io.BytesIO(b));im.load();assert im.size==(256,256)
  return x,y,im.convert('RGB'),hashlib.sha256(b).hexdigest()
 canvas=Image.new('RGB',(8192,8192));hashes={}
 with concurrent.futures.ThreadPoolExecutor(16) as pool:
  for x,y,im,digest in pool.map(tile,[(x,y) for y in range(32) for x in range(32)]):
   canvas.paste(im,(x*256,y*256));hashes[f'{x}/{y}']=digest
 path=ASSETS/f'Map-{name}.imageset/terrain.jpg'
 canvas.save(path,quality=94,subsampling=2)
 print(name,'8192x8192',path.stat().st_size,flush=True)
 return {'map':name,'sourceTemplate':template,'sourceZoom':5,'sourceTileCount':1024,'canvasPixels':[8192,8192],'outputSHA256':hashlib.sha256(path.read_bytes()).hexdigest(),'sourceTileSHA256':hashes,'calibration':'Original x/y tile order; identical 0-100 full atlas plane; no crop/pad/rotation/resample','detailCaution':'Source tile pixels; underlying map textures can remain pixelated. No AI or interpolation creates extra terrain.'}
if __name__=='__main__':
 records=json.loads((ROOT/'docs/codex-reports/2026-10-04-new-map-data-sources.json').read_text())
 results=[]
 with concurrent.futures.ThreadPoolExecutor(2) as pool:
  for result in pool.map(acquire,records):
   results.append(result);REPORT.write_text(json.dumps(results,indent=2)+'\n')
