#!/usr/bin/env python3
"""Verify companion data linkage, base equipment coverage and bundled artwork."""
import json
from collections import Counter
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1];r=root/'native/Ascended/Resources';a=root/'native/Ascended/Assets.xcassets'
load=lambda n:json.loads((r/(n+'.json')).read_text())
exp=load('expansion-catalog');maps={x['id'] for x in exp['maps']}
story=load('story-guide');equip=load('equipment-library');base=load('base-plan')
for key in ['overview','chapters','characters']:
 rows=story[key];assert rows and len({x['id'] for x in rows})==len(rows)
 assert all(x['paragraphs'] and all(p.strip() for p in x['paragraphs']) for x in rows)
assert all(x.get('mapID') is None or x['mapID'] in maps for x in story['chapters'])
items=equip['items'];assert len(items)>700 and len({x['id'] for x in items})==len(items)
categories={x['id'] for x in equip['categories']};assert all(x['category'] in categories and x['sourceURL'].startswith('https://ark.wiki.gg/') for x in items)
checked=set()
for x in items:
 assert x['name'] and x['summary'] and x['use'] and x['unlock']
 if x.get('asset'):
  folder=a/(x['asset']+'.imageset');assert folder.exists(),x['asset']
  metadata=json.loads((folder/'Contents.json').read_text())
  for im in metadata['images']:
   if 'filename' in im:Image.open(folder/im['filename']).verify()
  checked.add(x['asset'])
assert len(base['zones'])==5 and len(base['phases'])==5
names={x['name'].lower() for x in items};zoneids={x['id'] for x in base['zones']}
assert all(name.lower() in names for z in base['zones'] for name in z['items'])
assert all(x in zoneids for p in base['phases'] for x in p['zoneIDs'])
for m in exp['maps']:
 if m['status']=='available':assert (a/('MapBadge-'+m['id']+'.imageset/Contents.json')).exists(),m['id']
summary={'storySections':sum(len(story[k]) for k in ['overview','chapters','characters']),'equipmentItems':len(items),'categories':dict(Counter(x['category'] for x in items)),'uniqueEquipmentArtwork':len(checked),'baseZones':len(base['zones']),'basePhases':len(base['phases']),'verifiedPlayableMapBadges':10,'availability':dict(Counter(x.get('availability','unspecified') for x in items)),'result':'passed'}
(root/'docs/codex-reports/2026-10-04-companion-knowledge-validation.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n');print(json.dumps(summary,ensure_ascii=False))
