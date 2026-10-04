import json,math
from pathlib import Path
root=Path(__file__).resolve().parents[1];kit=json.loads((root/'native/Ascended/Resources/stone-building-kit.json').read_text())
assert kit['schema']==1 and kit['approximate'] is True
models=kit['models'];assert len(models)==11 and len({m['id'] for m in models})==11
for m in models:
 n=len(m['positions'])//3
 assert n>3 and n%3==0
 assert len(m['positions'])==len(m['normals']) and len(m['colors'])==4*n and len(m['uv'])==2*n
 assert all(math.isfinite(v) for k in ['positions','normals','colors','uv'] for v in m[k])
 assert all(abs(sum(v*v for v in m['normals'][i:i+3])-1)<.01 for i in range(0,3*n,3))
 assert m['asset'] and (root/'native/Ascended/Assets.xcassets'/(m['asset']+'.imageset')).exists()
 assert all(v>0 for v in m['ingredients'].values()) and m['sourceURL'].startswith('https://wikily.gg/ark-survival-ascended/items/')
byid={m['id']:m for m in models}
for m in json.loads((root/'native/Ascended/Resources/base-building-recipes.json').read_text())['items']:
 if m['id'] in byid:assert byid[m['id']]['ingredients']=={i['name']:i['amount'] for i in m['ingredients']}
roof=byid['sloped-stone-roof']['positions']
run=max(roof[2::3])-min(roof[2::3]);rise=max(roof[1::3])-min(roof[1::3])
assert .95<run<1.10 and .95<rise<1.10, (run,rise)
assert 'stone-builder-grain.png' in (root/'native/Ascended/Ascended.xcodeproj/project.pbxproj').read_text()
totals={k:2*byid['stone-foundation']['ingredients'][k]+byid['stone-wall']['ingredients'][k] for k in ['Stone','Wood','Thatch']}
assert totals=={'Stone':200,'Wood':100,'Thatch':75}
assert byid['stone-triangle-foundation']['ingredients']=={'Stone':40,'Wood':20,'Thatch':15}
assert byid['stone-railing']['ingredients']=={'Stone':20,'Wood':10,'Thatch':7}
print({'models':11,'triangles':sum(len(m['positions'])//9 for m in models),'finiteNormalsUVColors':True,'artworkReferences':True,'ASARecipeCompatibility':True,'twoFoundationOneWall':totals})
