"""Acquire ASA public map registries and original terrain tiles, never infer entrances."""
import subprocess,re,json,urllib.parse,urllib.request,concurrent.futures,hashlib,copy,io
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]; OUT=ROOT/'native/Ascended/Resources'; CACHE=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/new-map-data'); CACHE.mkdir(parents=True,exist_ok=True)
ASSETS=ROOT/'native/Ascended/Assets.xcassets'
def fetch(url): return subprocess.check_output(['curl','--retry','2','--max-time','45','-fLs',url])
def sha(b): return hashlib.sha256(b).hexdigest()
def put(path,d): path.write_text(json.dumps(d,ensure_ascii=False,separators=(',',':'))+'\n')
profiles={}
for filename in ['the-island','the-center','ragnarok']:
 for c in json.loads((OUT/(filename+'-creatures.json')).read_text())['creatures']:
  if c['id'] not in profiles or c['detailAvailable']:profiles[c['id']]=c

def acquire_artifact_icons():
 def wiki_fetch(url):return urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'AscendedPersonalFieldGuide/1.0'}),timeout=25).read()
 records={}
 names=['Artifact of the Crag','Artifact of the Gatekeeper','Artifact of the Destroyer','Artifact of the Shadows','Artifact of the Stalker','Artifact of the Lost','Artifact of the Depths','Artifact of Growth','Artifact of the Void']
 for title in names:
  aid=title.lower().replace('artifact of the ','').replace('artifact of ','').replace(' ','-');page='https://ark.wiki.gg/wiki/'+urllib.parse.quote(title.replace(' ','_'))
  html=wiki_fetch(page).decode();(CACHE/(aid+'-artifact-page.html')).write_text(html)
  filename=title.replace(' ','_')+'.png'
  matches=[u for u in re.findall(r'<img[^>]+src="([^"]+)"',html) if '/'+filename+'/' in u or u.split('?')[0].endswith('/'+filename)]
  if not matches:raise ValueError('No exact artifact image on '+page)
  url='https://ark.wiki.gg/images/'+filename if matches[0].startswith('/images/thumb/') else urllib.parse.urljoin(page,matches[0])
  raw=wiki_fetch(url);im=Image.open(io.BytesIO(raw));im.load();assert im.width>=128 and im.height>=128
  asset=ASSETS/('Artifact-'+aid+'.imageset');asset.mkdir(exist_ok=True);im.convert('RGBA').save(asset/'image.png')
  put(asset/'Contents.json',{'images':[{'filename':'image.png','idiom':'universal'}],'info':{'author':'xcode','version':1}})
  records[aid]={'title':title,'page':page,'imageURL':url,'sourceSHA256':sha(raw),'nativeSHA256':sha((asset/'image.png').read_bytes()),'pixels':[im.width,im.height],'transparent':im.mode=='RGBA' and im.getextrema()[-1][0]<255}
 return records

def acquire(pair):
 slug,web=pair; page='https://wikily.gg/ark-survival-ascended/maps/'+web+'/'
 raw=fetch(page);(CACHE/(web+'.html')).write_bytes(raw)
 t=''.join(json.loads(m)[1] for m in re.findall(r'self\.__next_f\.push\((\[.*?\])\)</script>',raw.decode()) if json.loads(m)[0]==1)
 # each mapData belongs to one coordinate plane (Genesis has main + Ocean)
 planes=[]
 for m in re.finditer('"mapData":',t):
  d=json.JSONDecoder().raw_decode(t[m.end():])[0]
  image=json.JSONDecoder().raw_decode(t[t.index('"mapImage":',m.end())+11:])[0]
  if d['map']['id'] not in [x[0]['map']['id'] for x in planes]:planes.append((d,image))
 results=[]
 for ix,(d,image) in enumerate(planes):
  name=slug if ix==0 else slug+'-ocean';mapid=d['map']['id'];put(CACHE/(name+'-mapData.json'),d)
  types=list(d['resourceCounts']);url='https://wikily.gg/api/ark/maps/v2/resources/?'+urllib.parse.urlencode({'mapId':mapid,'types':','.join(types)})
  resourceRaw=fetch(url);(CACHE/(name+'-resources-source.json')).write_bytes(resourceRaw);allnodes=json.loads(resourceRaw)
  nodes=[n for n in allnodes if 0<=n['lat']<=100 and 0<=n['lon']<=100];put(OUT/(name+'-resources.json'),nodes)
  creatures=[];missing=[]
  for species in sorted(d['dinoSpawnCounts']):
   cid=re.sub(r'[^a-z0-9]+','-',species.lower()).strip('-')
   if cid in profiles:c=copy.deepcopy(profiles[cid])
   else:
    missing.append(species); c={'id':cid,'name':species,'aliases':[],'group':'Alpha' if species.startswith('Alpha ') else 'Chưa phân loại','dlc':'','sourceURL':page,'rosterSource':'','reviewedAt':'04/10/2026','detailAvailable':False,'tameable':None,'diet':'','method':'','foods':[],'drops':[],'immobilizedBy':[],'stats':[],'iconURL':'','archive':None,'updateNote':'Chưa có hồ sơ chi tiết được xác minh; tên lấy từ spawn registry ASA.'}
   c['rosterSource']='Wikily '+d['map']['name'];c['reviewedAt']='04/10/2026';creatures.append(c)
  put(OUT/(name+'-creatures.json'),{'reviewedAt':'2026-10-04','sourceDump':d['map']['dump_time'],'spawnRegistryEntries':len(creatures),'wikiSupplementEntries':0,'countIncludesVariants':True,'excluded':[],'creatures':creatures})
  artifactURL='https://wikily.gg/api/ark/maps/v2/layer-data/?'+urllib.parse.urlencode({'mapId':mapid,'layer':'artifacts'})
  ar=fetch(artifactURL);(CACHE/(name+'-artifacts-source.json')).write_bytes(ar);artifacts=[]
  for a in json.loads(ar):
   title=a.get('name',a.get('artifact_name',''));aid=title.lower().replace('artifact of the ','').replace('artifact of ','').replace(' ','-')
   if title and a.get('lat') is not None and a.get('lon') is not None and 0<=a['lat']<=100 and 0<=a['lon']<=100: artifacts.append({'id':aid,'name':title,'lat':a['lat'],'lon':a['lon'],'routeID':'','imageAsset':('Artifact-'+aid) if (ASSETS/('Artifact-'+aid+'.imageset')).exists() else '','sourceURL':artifactURL})
  put(OUT/(name+'-exploration.json'),{'reviewedAt':'04/10/2026','artifacts':artifacts,'routes':[],'obelisks':[]})
  terrain={};
  if '{z}' in image:
   def tile(pos):
    x,y=pos;u=image.replace('{z}','3').replace('{x}',str(x)).replace('{y}',str(y));b=fetch(u);p=CACHE/(name+'-tiles');p.mkdir(exist_ok=True);(p/f'{x}-{y}.png').write_bytes(b);return x,y,b
   with concurrent.futures.ThreadPoolExecutor(8) as p: tiles=list(p.map(tile,[(x,y) for x in range(8) for y in range(8)]))
   canvas=Image.new('RGB',(2048,2048))
   for x,y,b in tiles:
    im=Image.open(io.BytesIO(b));assert im.size==(256,256);canvas.paste(im,(x*256,y*256))
   asset=ASSETS/('Map-'+name+'.imageset');asset.mkdir(parents=True,exist_ok=True);canvas.save(asset/'terrain.jpg',quality=95)
   put(asset/'Contents.json',{'images':[{'filename':'terrain.jpg','idiom':'universal'}],'info':{'author':'xcode','version':1}})
   terrain={'template':image,'nativePixels':[2048,2048],'tileZoom':3,'tileCount':64,'sha256':sha((asset/'terrain.jpg').read_bytes()),'sourceTileHashes':{f'{x}/{y}':sha(b) for x,y,b in tiles}}
  results.append({'map':name,'page':page,'mapID':mapid,'dump':d['map']['dump_time'],'pageSHA256':sha(raw),'resourceAPI':url,'nativeFileHashes':{kind:sha((OUT/(name+'-'+kind+'.json')).read_bytes()) for kind in ['creatures','resources','exploration']},'resourceAPISHA256':sha(resourceRaw),'resources':len(nodes),'outsideMapExcluded':len(allnodes)-len(nodes),'resourceTypes':types,'coordinateBounds':{'latitude':[0,100],'longitude':[0,100],'origin':'northwest','latitudeDirection':'down','longitudeDirection':'right'},'detailAvailableCount':sum(c['detailAvailable'] for c in creatures),'unreviewedDetailSpecies':[c['name'] for c in creatures if not c['detailAvailable']],'creatures':len(creatures),'missingDetailSpecies':missing,'artifacts':len(artifacts),'artifactAPI':artifactURL,'artifactAPISHA256':sha(ar),'terrain':terrain,'gaps':['Cave actor centers are not entrances; routes omitted without verified entrance coordinates.','Spawn registry membership counts variants; boss summoning progression lives in map guide.']})
  print(name,len(creatures),len(nodes),len(artifacts),flush=True)
 return results
if __name__=='__main__':
 pairs=[(x,x) for x in ['scorched-earth','aberration','extinction','lost-colony','valguero','astraeos']]+[('genesis-part-1','genesis')]
 artifactIcons=acquire_artifact_icons()
 records=[]
 with concurrent.futures.ThreadPoolExecutor(3) as pool:
  for r in pool.map(acquire,pairs): records+=r
 for r in records:r['artifactAssets']={a['id']:artifactIcons[a['id']] for a in json.loads((OUT/(r['map']+'-exploration.json')).read_text())['artifacts'] if a['id'] in artifactIcons}
 put(ROOT/'docs/codex-reports/2026-10-04-new-map-data-sources.json',records)
