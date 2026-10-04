import subprocess,re,json,urllib.parse,concurrent.futures,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1];out=root/'native/Ascended/Resources';records=[]
def acquire(slug):
 page='https://wikily.gg/ark-survival-ascended/maps/'+slug+'/'
 s=subprocess.check_output(['curl','-fLs',page]).decode()
 t=''.join(json.loads(m)[1] for m in re.findall(r'self\.__next_f\.push\((\[.*?\])\)</script>',s) if json.loads(m)[0]==1)
 d=json.JSONDecoder().raw_decode(t[t.index('"mapData":')+10:])[0]
 types=list(d['resourceCounts'])
 url='https://wikily.gg/api/ark/maps/v2/resources/?'+urllib.parse.urlencode({'mapId':d['map']['id'],'types':','.join(types)})
 raw=subprocess.check_output(['curl','-fLs',url]);nodes=json.loads(raw)
 assert isinstance(nodes,list) and len(nodes)>100
 outside=sum(not (0<=n['lat']<=100 and 0<=n['lon']<=100) for n in nodes)
 nodes=[n for n in nodes if 0<=n['lat']<=100 and 0<=n['lon']<=100]
 (out/(slug+'-resources.json')).write_text(json.dumps(nodes,separators=(',',':'))+'\n')
 return {'map':slug,'page':page,'api':url,'dump':d['map']['dump_time'],'types':types,'count':len(nodes),'outsideMapExcluded':outside,'apiSha256':hashlib.sha256(raw).hexdigest(),'nativeSha256':hashlib.sha256((out/(slug+'-resources.json')).read_bytes()).hexdigest()}
with concurrent.futures.ThreadPoolExecutor(3) as pool:
 for r in pool.map(acquire,['ragnarok','the-island','the-center']): records.append(r);print(r['map'],r['count'])
(root/'docs/codex-reports/2026-10-04-map-resource-sources.json').write_text(json.dumps(records,indent=2)+'\n')
