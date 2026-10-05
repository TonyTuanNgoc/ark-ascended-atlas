"""Read ASA-only Wiki DataMaps and extracted atlas actor registries; never call centers entrances."""
import concurrent.futures, hashlib, html, json, re, subprocess, urllib.parse
from pathlib import Path
CACHE=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/reference-locations-20261005')
MAPS={'the-island':'The_Island','ragnarok':'Ragnarok','the-center':'The_Center','scorched-earth':'Scorched_Earth','aberration':'Aberration','extinction':'Extinction','lost-colony':'Lost_Colony','genesis-part-1':'Genesis:_Part_1','valguero':'Valguero','astraeos':'Astraeos'}
def fetch(url):
 p=subprocess.run(['curl','-fLs','--max-time','40',url],capture_output=True)
 if p.returncode:raise RuntimeError(f'Public source request failed: {url} ({p.returncode})')
 return p.stdout

def acquire(pair):
 slug,title=pair;url='https://ark.wiki.gg/wiki/Explorer_Map/'+title
 raw=fetch(url);(CACHE/(slug+'-wiki-explorer.html')).write_bytes(raw);text=raw.decode()
 containers=re.findall(r'<div data-datamap-id="(\d+)"[^>]*class="[^"]*map-([^ "]+)[^"]*">(.*?)(?=<div data-datamap-id=|\Z)',text,re.S)
 results=[]
 for pageid,className,body in containers:
  if not className.endswith('_ASA'):continue
  configMatch=re.search(r'<script type="application/datamap\+json" data-purpose="config">(.*?)</script>',body,re.S)
  if not configMatch:continue
  config=json.loads(configMatch[1]);layers=[g for g in config['groups'] if any(k in g for k in ('cave-entrance','obelisk','terminal','teleport','surface-entrance'))]
  args={'action':'queryDataMap','pageid':int(pageid),'revid':config['version'],'format':'json','layers':'|'.join(layers)}
  chunks=[];markers={}
  while True:
   api='https://ark.wiki.gg/api.php?'+urllib.parse.urlencode(args)
   response=fetch(api);data=json.loads(response);chunks.append({'url':api,'sha256':hashlib.sha256(response).hexdigest()})
   if 'query' not in data:raise ValueError(data)
   for group,entries in data['query'].get('markers',{}).items():markers.setdefault(group,[]).extend(entries)
   if not data['query'].get('continue'):break
   args['continue']=data['query']['continue']
  record={'mapID':slug,'sourceURL':url,'pageID':int(pageid),'title':data['query']['title'],'revisionID':config['version'],'configuration':config,'markers':markers,'requests':chunks,'pageSHA256':hashlib.sha256(raw).hexdigest()}
  (CACHE/(slug+'-wiki-asa-markers.json')).write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n');results.append({k:record[k] for k in ('mapID','sourceURL','pageID','title','revisionID','requests','pageSHA256')})
 return slug,results
if __name__=='__main__':
 CACHE.mkdir(exist_ok=True);manifest=[]
 with concurrent.futures.ThreadPoolExecutor(4) as pool:
  futures={pool.submit(acquire,p):p[0] for p in MAPS.items()}
  for f in concurrent.futures.as_completed(futures):
   try:
    slug,records=f.result();manifest+=records;print(slug,'ASA datasets',len(records),flush=True)
   except Exception as e:print(futures[f],'ERROR',str(e),flush=True)
 (CACHE/'wiki-asa-acquisition-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
