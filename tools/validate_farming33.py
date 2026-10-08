"""Validate the actual Farming roster, aliases, verified pins and packaged clip evidence."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];APP=ROOT/'native/Ascended';RES=APP/'Resources'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
roster=read(RES/'farming-resources.json');icons=read(RES/'farming-resource-icons.json')['assets']
spots=read(RES/'verified-resource-spots.json')['spots'];guides=read(RES/'resource-guides.json')['guides']
assert len(roster['maps'])==11
excluded={'Wood','Thatch','Fiber','Stone','Flint'};names=set()
for m in roster['maps']:
 r=[x['name'] for x in m['resources']];assert len(set(r))==len(r);assert excluded.isdisjoint(r);names.update(r)
 for n in r:
  a=APP/'Assets.xcassets'/(icons[n]+'.imageset');assert a.is_dir(),n
  content=read(a/'Contents.json');assert any((a/i['filename']).is_file() for i in content['images'] if i.get('filename')),n
assert names==set(icons)
assert len(set(s['id'] for s in spots))==len(spots)==len(guides)
assert all(s['verified'] and 0<=s['lat']<=100 and 0<=s['lon']<=100 for s in spots)
assert set(s['id'] for s in spots)==set(g['spotID'] for g in guides)
curated={'Black Pearls','Cementing Paste','Chitin','Crystal','Giant Bee Honey','Metal','Obsidian','Oil','Organic Polymer','Rare Flowers','Rare Mushrooms','Rich Metal','Sap','Silica Pearls'}
reviewed_ids=set()
for folder in ('genesis','story','colony','root'):
 for filename in ('reviewed-additions.json','more-additions.json'):
  path=ROOT/'tools/evidence/farming33'/folder/filename
  if path.is_file():
   data=read(path); rows=data if isinstance(data,list) else data.get('candidates',data.get('entries',[])); reviewed_ids.update(row['id'] for row in rows)
for spot in spots:
 if spot['id'] in reviewed_ids:
  assert set(spot['resources']).issubset(curated),spot['id']
  guide=next(g for g in guides if g['spotID']==spot['id'])
  assert 6<=guide['steps'][0]['endSeconds']-guide['steps'][0]['startSeconds']<=10.001,spot['id']

clips=[]
for g in guides:
 assert len(g['steps'])==1,g['spotID']
 s=g['steps'][0];assert s['mapOverlayVisible'] is False
 assert 0<s['endSeconds']-s['startSeconds']<=10.001
 movie=RES/'ResourceClips'/(s['loop']+'.mp4');poster=RES/'ResourceClips'/(s['poster']+'.jpg')
 assert poster.is_file();assert sha(movie)==s['sha256'],g['spotID']
 p=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(movie)]))
 streams=p['streams'];v=next(x for x in streams if x['codec_type']=='video');duration=float(p['format']['duration'])
 assert v['codec_name']=='h264' and duration<=10.05 and not any(x['codec_type']=='audio' for x in streams)
 clips.append({'spotID':g['spotID'],'duration':duration,'width':v['width'],'height':v['height'],'sha256':s['sha256']})
result={'maps':11,'mapResourceEntries':sum(len(m['resources']) for m in roster['maps']),'resourceFamilies':len(names),'iconMappings':len(icons),'verifiedRegions':len(spots),'clips':len(clips),'allPassed':True,'clipResults':clips}
(ROOT/'tools/evidence/farming33/validation.json').write_text(json.dumps(result,indent=2)+'\n')
print({k:v for k,v in result.items() if k!='clipResults'})
