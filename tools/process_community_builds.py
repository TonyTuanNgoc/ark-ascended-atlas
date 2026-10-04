import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1];res=root/'native/Ascended/Resources'
rows=json.loads((root/'docs/codex-reports/2026-10-05-house-gallery-sources.json').read_text())
models={m['id']:m for f in ['stone-building-kit','construction-models'] for m in json.loads((res/(f+'.json')).read_text())['models']}
items={m['id']:m for m in json.loads((res/'build-crafting.json').read_text())['items']}
titles=['Viking cottage','Frontier porch house','Triangular roof starter','Timber workshop','Bunkhouse workshop','Stone workshop','Sorting warehouse','Trading store','Machiya store','Compact greenhouse','Flower greenhouse','Garden house','Viking smithy','The Bent Nail','Cinder Forge']
def phase(name):
 s=name.split('.')[-1].lower()
 if any(x in s for x in ['scaffolding','lamp','light','torch']):return 3
 if 'beam' in s:return 2
 if any(x in s for x in ['foundation','floor','pillar']):return 0
 if any(x in s for x in ['roof','ceiling','ramp','stair']):return 2
 if any(x in s for x in ['wall','door','window','railing','gate','fence','beam']):return 1
 return 3
def model(e):
 s=e['structure'].split('.')[-1].lower().removesuffix('_c');material=next((x for x in ['greenhouse','metal','stone','adobe','tek','thatch','wood'] if x in s),None)
 prefix='wooden' if material=='wood' else material
 families=[('trifoundation','triangle-foundation'),('triceiling','triangle-ceiling'),('foundation','foundation'),('floor','foundation'),('doubledoorframe','double-doorframe'),('doubledoor','double-door'),('doorframe','doorframe'),('windowwall','windowframe'),('window','window'),('door','door'),('railing','railing'),('pillar','pillar'),('ceiling','ceiling'),('wall','wall'),('ramp','ramp'),('stair','stairs')]
 if material:
  if 'roof' in s or ('sloped' in s and 'ceiling' in s):k='sloped-'+str(prefix)+'-roof'
  else:k=next((str(prefix)+'-'+f for token,f in families if token in s),'')
  if material=='stone' and k=='stone-door':k='reinforced-wooden-door'
  if k in models:return k
 aliases={'storagebox_anvilbench':'smithy','storagebox_chembench':'chemistry-bench','storagebox_fabricator':'fabricator','storagebox_huge':'vault','storagebox_large':'large-storage-box','storagebox_small':'storage-box','industrialforge':'industrial-forge','forge':'refining-forge','electricgenerator':'power-generator','feedingtrough':'feeding-trough','cryofridge':'cryofridge','simplebed':'simple-bed','preservingbin':'preserving-bin','cookingpot':'cooking-pot','bookshelf':'bookshelf','woodtable':'wooden-table','walltorch':'wall-torch','fireplace':'fireplace'}
 k=next((v for token,v in aliases.items() if s==token or s==token+'_bp'),'')
 return k if k in models else None
out=[]
for row,title in zip(rows,titles):
 entries=row['entries']; xs=[e['loc']['x'] for e in entries];ys=[e['loc']['y'] for e in entries];zs=[e['loc']['z'] for e in entries];cx=(min(xs)+max(xs))/2;cy=(min(ys)+max(ys))/2;base=min(zs)
 parts=[]
 for i,e in enumerate(entries):
  parts.append(dict(id=str(i),modelID=model(e),x=(e['loc']['x']-cx)/300,y=(e['loc']['z']-base)/300,z=-(e['loc']['y']-cy)/300,pitch=e['rot']['pitch'],yaw=e['rot']['yaw'],roll=e['rot']['roll'],phase=phase(e['structure']),suggested=False,sourceClass=e['structure'].split('.')[-1]))
 req=[]
 for i,r in enumerate(row['requirements']):
  slug=r.get('item',{}).get('slug','');item=items.get(slug) or next((v for v in items.values() if v.get('sourceURL','').rstrip('/').split('/')[-1]==slug and v['recipeVerified']),None);req.append(dict(id=slug or str(i),name=r['name'],count=r['count'],asset=item.get('asset') if item else None,ingredients=item['ingredients'] if item and item['recipeVerified'] else {},stations=item['stations'] if item else [],verified=bool(item and item['recipeVerified']),suggested=False,phase=phase(r['name'])))
 fitouts={'home':['simple-bed','storage-box','mortar-and-pestle','campfire'],'workshop':['smithy','fabricator','chemistry-bench','power-generator'],'storage':['large-storage-box','vault','preserving-bin'],'garden':['large-crop-plot','large-crop-plot','large-crop-plot','compost-bin'],'forge':['refining-forge','smithy','industrial-forge']}
 for i,k in enumerate(fitouts[row['zone']]):
  if any(p['modelID']==k and not p['suggested'] for p in parts):continue
  if k not in models or k not in items:continue
  item=items[k]
  parts.append(dict(id='suggested-'+str(i),modelID=k,x=(i%2)*1.6-0.8,y=0.3,z=(i//2)*1.6-0.8,pitch=0,yaw=0,roll=0,phase=3,sourceClass='App suggested fit-out',suggested=True))
  existing=next((r for r in req if r['id']=='suggested-'+k),None)
  if existing:existing['count']+=1
  else:req.append(dict(id='suggested-'+k,name=item['name'],count=1,asset=item.get('asset'),ingredients=item['ingredients'],stations=item['stations'],verified=item['recipeVerified'],phase=3,suggested=True))
 out.append(dict(id=row['id'],zone=row['zone'],title=title,creator=row['creator'],sourceURL=row['sourceURL'],videoURL=row['videoURL'],parts=parts,requirements=req,skins=bool(row['skinsUsed']),extent=max(max(xs)-min(xs),max(ys)-min(ys),max(zs)-min(zs))/300))
 row['title']=title
 print(row['id'],len(parts),'mapped',sum(p['modelID'] is not None for p in parts),'cost',sum(r['verified'] for r in req),'/',len(req))
(res/'community-builds.json').write_text(json.dumps({'builds':out},ensure_ascii=False,separators=(',',':'))+'\n')
(root/'docs/codex-reports/2026-10-05-house-gallery-sources.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
