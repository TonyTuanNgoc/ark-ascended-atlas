#!/usr/bin/env python3
"""Copy finished loop pairs and push bounded media-only commits; final UI commit follows QA."""
import argparse,shutil,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('stage',type=Path);a=p.parse_args();root=Path(__file__).resolve().parents[1];dest=root/'native/Ascended/Resources/CaveGIFs'
branch=subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip();assert branch=='codex/ascended-ipad-dev-20261003'
tracked=set(subprocess.check_output(['git','ls-files','native/Ascended/Resources/CaveGIFs'],cwd=root,text=True).splitlines())
files=[x for x in sorted(a.stage.glob('*.mp4')) if not x.name.endswith('.tmp.mp4') and x.with_suffix('.key').exists() and str((dest/x.name).relative_to(root)) not in tracked]
batches=[];batch=[];size=0
for movie in files:
 if batch and size+movie.stat().st_size>1_200_000_000:batches.append(batch);batch=[];size=0
 batch.append(movie);size+=movie.stat().st_size
if batch:batches.append(batch)
for i,batch in enumerate(batches,1):
 paths=[]
 for movie in batch:
  for source in [movie,movie.with_suffix('.jpg')]:
   target=dest/source.name;shutil.copy2(source,target);paths.append(str(target.relative_to(root)))
 subprocess.run(['git','-c','core.compression=0','add','--',*paths],cwd=root,check=True)
 subprocess.run(['git','commit','-m',f'Add source-quality cave loops: {batch[0].stem} through {batch[-1].stem}'],cwd=root,check=True)
 subprocess.run(['git','-c','core.compression=0','push','origin',branch],cwd=root,check=True)
 print(f'PUSHED batch {i}/{len(batches)} {len(batch)} loops',flush=True)
