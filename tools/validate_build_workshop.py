import json,math,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1];r=root/'native/Ascended/Resources'
kit=json.loads((r/'stone-building-kit.json').read_text())['models'];new=json.loads((r/'construction-models.json').read_text())['models'];models=kit+new
craft=json.loads((r/'build-crafting.json').read_text());items=craft['items'];byid={m['id']:m for m in models}
assert len(models)==378 and len(byid)==378
assert len(items)==728 and len({i['id'] for i in items})==728
for m in models:
 assert (root/'native/Ascended/Assets.xcassets'/(m['asset']+'.imageset')).exists(),m['id']
 if m.get('referenceOnly'):assert not m['positions'];continue
 n=len(m['positions'])//3
 assert n>0 and n%3==0 and len(m['normals'])==n*3 and len(m['uv'])==n*2 and len(m['colors'])==n*4,m['id']
 assert all(math.isfinite(v) for k in ['positions','normals','uv','colors'] for v in m[k]),m['id']
 assert all(abs(sum(v*v for v in m['normals'][i:i+3])-1)<.01 for i in range(0,n*3,3)),m['id']
for i in items:
 if i['recipeVerified']:assert all(isinstance(v,int) and v>0 for v in i['ingredients'].values()),i['id']
wall=byid['greenhouse-wall']['positions'];ceil=byid['greenhouse-ceiling']['positions']
assert max(wall[0::3])-min(wall[0::3])==1 and max(wall[1::3])-min(wall[1::3])==1
assert max(ceil[1::3])-min(ceil[1::3])<.2
sizes=json.loads((root/'docs/codex-reports/2026-10-04-build-size-research.json').read_text())['records']
out={'version':'0.17.0','build':18,'catalogueItems':len(items),'constructionMachineEntries':len(models),'reconstructedModels':sum(not m.get('referenceOnly',False) for m in models),'inventoryReferences':sum(bool(m.get('referenceOnly')) for m in models),'verifiedRecipeEntries':sum(i['recipeVerified'] for i in items),'standardProcesses':len(craft['processes']),'sizePagesAttempted':len(sizes),'sizePagesRetrieved':sum(i['pageRetrieved'] for i in sizes),'historicalSizeNotes':sum(bool(i['notes']) for i in sizes),'exactASAMeshBoundsVerified':False,'finiteGeometryAndNormalizedNormals':True,'greenhouseModuleBounds':True,'sourceHashes':{f:hashlib.sha256((r/f).read_bytes()).hexdigest() for f in ['build-crafting.json','construction-models.json']}}
(root/'docs/codex-reports/2026-10-04-build-workshop-validation.json').write_text(json.dumps(out,indent=2)+'\n');print(out)
