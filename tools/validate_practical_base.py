import json
from pathlib import Path
from collections import Counter
root=Path(__file__).resolve().parents[1];res=root/'native/Ascended/Resources';assets=root/'native/Ascended/Assets.xcassets'
houses=json.loads((res/'base-layout.json').read_text());assert len(houses)==5
for i,a in enumerate(houses):
 for b in houses[i+1:]:
  assert a['x']+a['width']<=b['x'] or b['x']+b['width']<=a['x'] or a['z']+a['depth']<=b['z'] or b['z']+b['depth']<=a['z']
counts=Counter()
for h in houses:
 counts['stone-foundation']+=h['width']*h['depth'];counts['stone-ceiling']+=h['width']*h['depth'];counts['stone-wall']+=2*(h['width']+h['depth'])*h['levels']-1;counts['stone-doorframe']+=1;counts['reinforced-wooden-door']+=1
recipes={r['id']:r for r in json.loads((res/'base-building-recipes.json').read_text())['items']};materials=Counter()
for key,n in counts.items():
 for ingredient in recipes[key]['ingredients']:materials[ingredient['name']]+=n*ingredient['amount']
assert dict(materials)=={'Stone':33860,'Wood':16950,'Thatch':12240}
items=json.loads((res/'equipment-library.json').read_text())['items'];assert len(items)==728
for item in items:
 folder=assets/(item['asset']+'.imageset');data=json.loads((folder/'Contents.json').read_text());assert all((folder/i['filename']).is_file() for i in data['images'] if 'filename' in i)
for asset in json.loads((res/'creature-silhouette-aliases.json').read_text())['aliases'].values():assert (assets/(asset+'.imageset')).is_dir()
assert len(list(assets.glob('MapLogo-*.imageset')))==12
print(json.dumps({'houses':5,'nonOverlapping':True,'frameMaterials':dict(materials),'itemArtwork':len(items),'mapLogos':12,'aliasTargetsValid':True}))
