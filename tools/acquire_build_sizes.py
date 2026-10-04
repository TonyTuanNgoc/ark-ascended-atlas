"""Archive first-party wiki item sizing notes; mark legacy clearance separately from ASA mesh size."""
import json,re,html,subprocess,concurrent.futures
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'native/Ascended/Resources';cache=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/build-research/wiki-sizes');cache.mkdir(exist_ok=True)
items=json.loads((R/'equipment-library.json').read_text())['items']
def read(item):
 p=cache/(item['id']+'.html');url=item['sourceURL']+'?useskin=vector'
 if not p.exists():
  r=subprocess.run(['curl','-fLs','--max-time','30',url],capture_output=True)
  if r.returncode==0:p.write_bytes(r.stdout)
 s=p.read_text() if p.exists() else ''
 text=html.unescape(re.sub('<[^>]+>',' ',s));text=re.sub(r'\s+',' ',text)
 notes=[]
 for pattern in [r'Dimensions.{0,180}',r'[^.]{0,100}(?:\d+x\d+x\d+|\d+×\d+×\d+)[^.]{0,180}',r'[^.]{0,80}(?:foundations? (?:wide|long)|walls? (?:high|tall))[^.]{0,180}']:
  notes+=re.findall(pattern,text,re.I)
 return {'id':item['id'],'sourceURL':url,'notes':list(dict.fromkeys(notes))[:5],'asaMeshMeasured':False,'pageRetrieved':bool(s),'status':'historical-wiki-notes' if notes else 'no-measured-size-found'}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:records=list(pool.map(read,[i for i in items if i['category']=='machines']))
(ROOT/'docs/codex-reports/2026-10-04-build-size-research.json').write_text(json.dumps({'unit':'foundation/wall modules; no metre conversion claimed','records':records},ensure_ascii=False,indent=2)+'\n')
print('size pages',len(records),'with notes',sum(bool(i['notes']) for i in records))
