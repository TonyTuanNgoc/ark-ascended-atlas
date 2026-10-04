"""Source genuine large map title/DLC artwork; never substitute tiny letter icons."""
import hashlib,html,json,re,subprocess,time
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
MAPS=[('scorched-earth','Scorched_Earth'),('aberration','Aberration'),('extinction','Extinction'),('lost-colony','Lost_Colony'),('genesis-part-1','Genesis:_Part_1'),('genesis-part-2','Genesis:_Part_2'),('the-center','The_Center'),('ragnarok','Ragnarok'),('valguero','Valguero'),('astraeos','Astraeos')]
def fetch(url):return subprocess.check_output(['curl','-fLs','--retry','2','--retry-delay','65',url])
def candidates(page):
 urls=[html.unescape(x) for x in re.findall(r'(?:src|href)="([^"]+)"',page) if '/images/' in x]
 vals=[]
 for x in urls:
  if any(k in x.lower() for k in ['dlc.','logo.','cover.','header.']) and not any(k in x for k in ['Network_','Club_ARK','Logo_Mobile','Icon']):
   x=re.sub(r'/images/thumb/([^/]+)/[^?]+',r'/images/\1',x).split('?')[0]
   if x not in vals:vals.append(x)
 return sorted(vals,key=lambda x:('ASA_' not in x and 'Ascended' not in x,'DLC' not in x))
if __name__=='__main__':
 for slug,title in MAPS:
  path=Path('/tmp')/(slug+'-logo-page.html')
  if not path.exists():path.write_bytes(fetch('https://ark.wiki.gg/wiki/'+title+'?useskin=vector'));time.sleep(3)
  print(slug,candidates(path.read_text()),flush=True)
    # Selected infobox title art, preferring explicitly ASA editions.
FILES={'scorched-earth':'ASA_Scorched_Earth_DLC.jpg','aberration':'ASA_Aberration_DLC.jpg','extinction':'ASA_Extinction_DLC.jpg','lost-colony':'LostColony_W_Logo.png','genesis-part-1':'Genesis_Ascended_Key_Art.jpg','genesis-part-2':'Genesis_Part_2_DLC.jpg','the-center':'ASA_The_Center_DLC.jpg','ragnarok':'ASA_Ragnarok_DLC.jpg','valguero':'ASA_Valguero_DLC.jpg','astraeos':'ASA_Astraeos_DLC.jpg'}
def acquire_assets():
 records=[]
 for slug,filename in FILES.items():
  out=ROOT/'native/Ascended/Assets.xcassets'/('MapLogo-'+slug+'.imageset');out.mkdir(exist_ok=True)
  f=out/('image'+Path(filename).suffix)
  page_text=(Path('/tmp')/(slug+'-logo-page.html')).read_text()
  hit=re.search(re.escape(filename)+r'/[^?\"]+\?([^\"]+)',page_text)
  url='https://ark.wiki.gg/images/'+filename+('?' + html.unescape(hit.group(1)) if hit else '')
  if not f.exists(): f.write_bytes(fetch(url));time.sleep(7)
  with Image.open(f) as im:
   im.verify()
  with Image.open(f) as im:w,h=im.size
  assert w>=200 and h>=100
  (out/'Contents.json').write_text(json.dumps({'images':[{'filename':f.name,'idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2)+'\n')
  title=dict(MAPS)[slug]
  records.append({'mapID':slug,'asset':'MapLogo-'+slug,'sourcePage':'https://ark.wiki.gg/wiki/'+title,'filePage':'https://ark.wiki.gg/wiki/File:'+filename,'sourceURL':url,'width':w,'height':h,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'edition':'ASE title art (future Genesis Part 2 ASA logo unavailable)' if slug=='genesis-part-2' else 'ASA','transformation':'None; original full title art retained, no generated logo or terrain crop.','attribution':'ARK Official Community Wiki hosting official ARK artwork; Studio Wildcard and respective creators. See linked file page for rights.'})
  print(slug,w,h,flush=True)
 src=ROOT/'native/Ascended/Assets.xcassets/ArkLogo.imageset/image.png'
 out=ROOT/'native/Ascended/Assets.xcassets/MapLogo-the-island.imageset';out.mkdir(exist_ok=True);(out/'image.png').write_bytes(src.read_bytes());(out/'Contents.json').write_text(json.dumps({'images':[{'filename':'image.png','idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2)+'\n')
 with Image.open(src) as im:w,h=im.size
 records.append({'mapID':'the-island','asset':'MapLogo-the-island','sourceAsset':'ArkLogo','sourceURL':'https://ark.wiki.gg/wiki/ARK:_Survival_Ascended','width':w,'height':h,'sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'edition':'ASA','note':'The Island is the base game map. Reuses existing genuine ARK logo; no Island-specific title logo confirmed.'})
 src=ROOT/'native/Ascended/Assets.xcassets/MapLogo-genesis-part-1.imageset';dst=ROOT/'native/Ascended/Assets.xcassets/MapLogo-genesis-part-1-ocean.imageset';dst.mkdir(exist_ok=True)
 for f in src.iterdir():(dst/f.name).write_bytes(f.read_bytes())
 records.append(dict(next(x for x in records if x['mapID']=='genesis-part-1'),mapID='genesis-part-1-ocean',asset='MapLogo-genesis-part-1-ocean',note='Ocean biome uses parent Genesis Part 1 title art.'))
 (ROOT/'docs/codex-reports/2026-10-04-map-logo-sources.json').write_text(json.dumps({'checkedAt':'2026-10-04','count':len(records),'records':records},indent=2)+'\n')
if __name__=='__main__':acquire_assets()
