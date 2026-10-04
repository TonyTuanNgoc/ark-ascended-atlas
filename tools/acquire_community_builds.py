import re,json,subprocess,hashlib,concurrent.futures
from pathlib import Path
root=Path(__file__).resolve().parents[1];cache=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/build-research/house-gallery');cache.mkdir(exist_ok=True)
choices=[('home', 274, 'Viking cottage'), ('home', 199, 'Frontier porch house'), ('home', 262, 'Triangular roof starter'), ('workshop', 2629, 'Timber workshop'), ('workshop', 405, 'Bunkhouse workshop'), ('workshop', 1307, 'Stone workshop'), ('storage', 879, 'Sorting warehouse'), ('storage', 468, 'Trading store'), ('storage', 757, 'Machiya store'), ('garden', 61, 'Compact greenhouse'), ('garden', 709, 'Flower greenhouse'), ('garden', 400, 'Garden house'), ('forge', 2239, 'Viking smithy'), ('forge', 2883, 'The Bent Nail'), ('forge', 2874, 'Cinder Forge')]
def fetch(url,p,data=None):
 if p.exists():return p.read_text()
 cmd=['curl','-fLs','--max-time','35']
 if data:cmd+=['-X','POST','-H','Content-Type: application/json','--data',json.dumps(data)]
 out=subprocess.run(cmd+[url],capture_output=True)
 if out.returncode:raise Exception(url+' unavailable')
 p.write_bytes(out.stdout);return p.read_text()
def flight(s):
 f=''
 for m in re.finditer(r'<script>self\.__next_f\.push\((.*?)\)</script>',s):
  try:d=json.loads(m[1]);f+=d[1] if len(d)>1 and isinstance(d[1],str) else ''
  except:pass
 return f
def one(choice):
 zone,tid,title=choice;url=f'https://wikily.gg/ark-survival-ascended/building-templates/templates/{tid}/';html=fetch(url,cache/f'{tid}.html');f=flight(html)
 req=[]
 for m in re.finditer(r'"requirements":\[',f):
  try:arr=json.JSONDecoder().raw_decode(f[m.start()+15:])[0]
  except:continue
  if arr and 'count' in arr[0]:req=arr;break
 resp=json.loads(fetch(f'https://wikily.gg/api/ark/building-templates/{tid}/json/download/',cache/f'{tid}-download.json',{'buildingIndex':0}))
 raw=json.loads(fetch(resp['download_url'],cache/f'{tid}.json'))
 metas=[]
 # Main template title/video is server-rendered before similar templates; inspect direct video URLs separately.
 videos=re.findall(r'https?://(?:www\.)?(?:youtube\.com/(?:watch\?v=|embed/)|youtu\.be/)([\w-]{11})',html)
 # Use creator metadata from search records to avoid accidentally taking a similar-template video.
 meta=next((r for r in json.loads((root/'docs/codex-reports/2026-10-05-house-gallery-sources.json').read_text()) if r['id']==str(tid)),{})
 video=meta.get('videoURL')
 m=re.search(r'(?:v=|youtu\.be/|embed/)([\w-]{11})',video or '')
 linked=('https://www.youtube.com/watch?v='+m[1]) if m else None
 return {'id':str(tid),'zone':zone,'title':title,'creator':raw.get('creator',''),'originalTitle':raw['name'],'sourceURL':url,'videoURL':linked,'videoRole':'creator-linked' if linked else 'reference-only','count':len(raw['entries']),'requirements':req,'entries':raw['entries'],'sourceSHA256':hashlib.sha256(html.encode()).hexdigest(),'templateSHA256':hashlib.sha256((cache/f'{tid}.json').read_bytes()).hexdigest(),'captionStatus':'unavailable: YouTube HTTP429','skinsUsed':sorted({e.get('skin') for e in raw['entries'] if e.get('skin')})}
rows=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 for result in pool.map(one,choices):rows.append(result);print(result['id'],result['title'],result['count'],len(result['requirements']),result['videoURL'],flush=True)
(root/'docs/codex-reports/2026-10-05-house-gallery-sources.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
print('DONE',len(rows))
