"""Acquire verified gallery artwork from each exact creature page, retaining provenance."""
import json,re,urllib.request,urllib.parse,hashlib,io,concurrent.futures,argparse
parser=argparse.ArgumentParser();parser.add_argument("--only",nargs="*");args=parser.parse_args()
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1];native=root/'native/Ascended';assets=native/'Assets.xcassets'
records={}
for path in (native/'Resources').glob('*-creatures.json'):
 for d in json.loads(path.read_text())['creatures']: records['Dino-'+d['id']]=(d['name'],'https://ark.wiki.gg/wiki/'+urllib.parse.quote(d['name'].replace(' ','_')))
# Exact boss pages. Combined Spirit gallery retains both spirits, never ordinary animals.
records.update({'Boss-broodmother':('Broodmother Lysrix','https://ark.wiki.gg/wiki/Broodmother_Lysrix'),'Boss-megapithecus':('Megapithecus','https://ark.wiki.gg/wiki/Megapithecus'),'Boss-dragon':('Dragon','https://ark.wiki.gg/wiki/Dragon'),'Boss-overseer':('Overseer','https://ark.wiki.gg/wiki/Overseer'),'Boss-lava-elemental':('Lava Elemental','https://ark.wiki.gg/wiki/Lava_Elemental'),'Boss-iceworm-queen':('Iceworm Queen','https://ark.wiki.gg/wiki/Iceworm_Queen'),'Boss-spirit-dire-bear':('Spirit Dire Bear','https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear'),'Boss-spirit-direwolf':('Spirit Direwolf','https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear')})
def get(url):
 return urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'AscendedPersonalFieldGuide/1.0'}),timeout=25).read()
def acquire(record):
 asset,(name,page)=record
 try:
  html=get(page).decode()
  galleries=re.findall(r'<li class="gallerybox".*?</li>',html,re.S)
  candidates=[]
  for g in galleries:
   m=re.search(r'<img[^>]+src="([^"]+)"',g)
   if not m:continue
   src=m.group(1);filename=src.split('/thumb/')[-1].split('/')[0]
   if re.search('paintregion|dossier|map|icon|logo|concept|skeletal|bone_|costume',filename,re.I):continue
   if any(v in name.lower().split() and v not in filename.lower() for v in ['aberrant','alpha','spirit','fire','ice','lightning','poison']):continue
   score=3 if re.search(r'ASA|Ascended',filename,re.I) else 2 if re.search(r'Render',filename,re.I) else 1
   candidates.append((score,src,filename))
  # Named render or full creature image can occur in an infobox instead of gallery.
  for src in re.findall(r'<img[^>]+src="([^"]+)"',html):
   filename=src.split('/thumb/')[-1].split('/')[0]
   if filename.lower().startswith('render_') or '_Image.' in filename:
    if re.search('concept|skeletal|bone_|costume|mod_',filename,re.I):continue
    if not any(v in name.lower().split() and v not in filename.lower() for v in ['aberrant','alpha','spirit','fire','ice','lightning','poison']):candidates.append((4 if '_Image.' in filename else 2,src,filename))
  if not candidates:
   provenance=root/'docs/codex-reports/2026-10-04-game-portrait-sources.json'
   previous=next((x for x in json.loads(provenance.read_text()) if x['asset']==asset and x.get('sourceVideo')),None) if provenance.exists() else None
   if previous:
    folder=assets/(previous['gameAsset']+'.imageset')
    if (folder/'image.jpg').exists() and hashlib.sha256((folder/'image.jpg').read_bytes()).hexdigest()==previous['sha256']:return previous
   folder=assets/('Game-'+asset+'.imageset')
   if folder.exists():
    import shutil;shutil.rmtree(folder)
   return {'asset':asset,'name':name,'page':page,'status':'no_verified_gallery'}
  score,src,filename=sorted(candidates,key=lambda x:-x[0])[0]
  url='https://ark.wiki.gg/images/'+filename if src.startswith('/images/thumb/') else urllib.parse.urljoin(page,src)
  data=get(url);im=Image.open(io.BytesIO(data));im.load()
  if im.width<200 or im.height<150:raise ValueError('Gallery image too small')
  im.thumbnail((1200,1200));folder=assets/('Game-'+asset+'.imageset');folder.mkdir(exist_ok=True)
  im.convert('RGBA').save(folder/'image.png')
  (folder/'Contents.json').write_text(json.dumps({'images':[{'filename':'image.png','idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2)+'\n')
  return {'asset':asset,'gameAsset':'Game-'+asset,'name':name,'page':page,'imageURL':url,'sha256':hashlib.sha256(data).hexdigest(),'dimensions':[im.width,im.height],'edition':'ASA' if score==3 else 'game gallery, edition unconfirmed','status':'ready'}
 except Exception as e:return {'asset':asset,'name':name,'page':page,'status':'unavailable','error':str(e)}
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
 results=list(pool.map(acquire,[(k,v) for k,v in records.items() if not args.only or k in args.only]))
if args.only:
 previous=json.loads((root/'docs/codex-reports/2026-10-04-game-portrait-sources.json').read_text())
 ids={x['asset'] for x in results};results=[x for x in previous if x['asset'] not in ids]+results
(root/'docs/codex-reports/2026-10-04-game-portrait-sources.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print('Verified game images:',sum(x['status']=='ready' for x in results),'/',len(results))
print('Missing:',[(x['name'],x['status']) for x in results if x['status']!='ready'])
