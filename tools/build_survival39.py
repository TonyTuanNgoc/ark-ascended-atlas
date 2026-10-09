"""Expand the existing route without changing milestone IDs or saved progress."""
import runpy, json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
b=runpy.run_path(str(root/'tools/build_survival38.py'))
pack=b['pack'];g=b['goal'];source=b['source']; phases=pack['phases']
for id,title,url,note in [
 ('wiki-moschops','Moschops','Moschops','Early versatile gatherer; check its requested passive-tame food.'),
 ('wiki-trike','Triceratops','Triceratops','Early berries/thatch and defence option; not a required second starter.'),
 ('wiki-mammoth','Mammoth','Mammoth','Wood specialist; northern taming requires cold and predator preparation.'),
 ('wiki-thyla','Thylacoleo','Thylacoleo','Climbing ground explorer. Cave entrances restrict access; not an Island arena fighter.'),
 ('wiki-rex','Rex','Rex','Guardian army alternative. A Rex team is not automatically a Dragon-ready replacement.')]:
 source(id,'ARK Wiki · '+title,'https://ark.wiki.gg/wiki/'+url,'Mechanics reference',note)
for s in pack['sources']:
 if s['id'].startswith('wiki-') and s['id'] in ['wiki-moschops','wiki-trike','wiki-mammoth','wiki-thyla','wiki-rex']:s['reviewedAt']='2026-10-09'
by={p['id']:p for p in phases}
def add(phase,group,id,title,visual,detail,refs,count=None):
 by[phase]['groups'][next(i for i,v in enumerate(by[phase]['groups']) if v['id']==group)]['goals'].append(g(id,title,visual,detail,refs,True,count))
add('shore','creatures','trike-option','Berry gatherer','Dino-triceratops','Triceratops: berries, thatch and early defence. A later starter alternative; do not risk an unprepared knockout just to finish this phase.',['wiki-trike','player-start'])
add('shore','equipment','cloth-kit','Light armour','Cloth Shirt','Cloth Shirt: an inexpensive early clothing option. Add matching pieces as materials allow.',['player-start'])
add('shore','equipment','torch-kit','Night trips','Torch','Torch: light for the coast and your starter shelter. Keep food and an escape path ready.',['player-start'])
add('flight','creatures','trike-upgrade','Berry supply','Dino-triceratops','Triceratops can keep supplying berries while your flyers and mineral gatherers come online.',['wiki-trike'])
add('flight','equipment','rifle-kit','Later taming upgrade','Longneck Rifle','Longneck Rifle + Tranquilizer Dart: a later alternative to the Crossbow. Check target health and its suitable knockout method.',['player-route'])
add('flight','base','preserving','Food storage','Preserving Bin','Preserving Bin: an intermediate storage option before reliable generator power and a refrigerator.',['player-route'])
add('home','creatures','mammoth-option','Wood alternative','Dino-mammoth','Mammoth: wood specialist instead of Castoroides. Prepare for the northern climate; choose based on your own base route.',['wiki-mammoth'])
add('home','creatures','theri-gatherer','Multi-resource alternative','Dino-therizinosaur','Therizinosaur: a versatile gatherer if you prefer one multi-purpose animal to another specialist. Keep breeding parents safe.',['player-balance','wiki-breeding'])
add('home','base','cooker-option','Cooking upgrade','Industrial Cooker','Industrial Cooker is an optional production upgrade. A Cooking Pot can make cakes before you build a larger kitchen.',['cake-recipe'])
add('home','equipment','sap-kit','Sap setup','Tree Sap Tap','Tree Sap Tap: build a safe collection route to your taps. Add honey and crops to the supply loop for cakes.',['cake-recipe'])
add('explore','creatures','thyla-option','Ground explorer','Dino-thylacoleo','Thylacoleo: climbing and ground travel. Check the exact cave entrance; do not assume cryopod deployment or arena eligibility.',['wiki-thyla'])
add('explore','creatures','mega-chitin','Chitin farmer','Dino-megatherium','Megatherium: an insect/chitin alternative to the frog paste route. Check access for the cave you plan to use.',['wiki-brood','wiki-caves'])
add('explore','equipment','grapple-kit','Route recovery','Grappling Hook','Grappling Hook + Crossbow + Parachute: optional movement/recovery kit where the route permits it. Test the route before relying on this escape.',['wiki-caves'])
add('army','creatures','rex-option','Guardian army alternative','Dino-rex','Rex: breed a separate guardian line if you enjoy Rexes. Choose a suitable team rather than adding a second army to every required task. Not a blanket Dragon recommendation.',['wiki-rex','wiki-monkey'], '19 + 1 Yuty')
add('army','equipment','rex-saddles','Rex team kit','Saddle','Rex Saddle: use only with your Rex alternative. Each fighter needs its matching saddle; the illustration is the generic saddle reference.',['wiki-rex'])
add('guardians','creatures','mega-specialist','Spider specialist','Dino-megatherium','Megatherium: an alternative Broodmother roster with insect buff. Use matching saddles and a Yuty; stay within the ordinary 20-tame arena cap.',['wiki-brood'])
add('guardians','equipment','monkey-fur','Cold protection','Fur Chestpiece','Fur Chestpiece: a rider clothing option for the Megapithecus arena. Plan protection for the actual weather and equipment quality.',['wiki-monkey'])
add('dragon','equipment','rider-backup','Rider supplies','Medical Brew','Medical Brew + Pump-Action Shotgun + Simple Shotgun Ammo: rider emergency supplies, kept separate from cakes on the Therizinos.',['wiki-dragon'])
add('ascend','equipment','spare-armour','Spare armour kit','Flak Chestpiece','Flak Chestpiece + Medical Brew: spare protection and recovery for the route. Temperature protection remains a separate requirement.',['wiki-tek'])
# Exact named contents of illustrated kits. All names are visible on cards, not hidden in detail.
kits={
'shore/starter':['Moschops','Parasaur'], 'shore/parasaur':['Parasaur'],
'shore/shore-home':['Wooden Foundation','Storage Box'], 'shore/bed':['Simple Bed'], 'shore/fire':['Campfire'],
'shore/starter-tools':['Stone Pick','Stone Hatchet'],'shore/bola':['Bola','Bow'],
'flight/workshop':['Stone Foundation','Refining Forge'],'flight/smithy':['Smithy'],
'flight/metal-tools':['Metal Pick','Metal Hatchet'],'flight/taming-kit':['Crossbow','Tranq Arrow','Narcotic'],'flight/spyglass':['Spyglass'],
'flight/rifle-kit':['Longneck Rifle','Tranquilizer Dart'],
'home/main-home':['Stone Foundation','Storage Box'], 'home/fabricator':['Fabricator','Power Generator','Refrigerator'],
'home/greenhouse':['Large Crop Plot','Rockarrot','Savoroot','Longrass'], 'home/nursery':['Feeding Trough'],
'home/hatch':['Air Conditioner'], 'home/cake-supply':['Giant Bee Honey','Sap','Cooking Pot','Stimulant'],
'explore/outpost':['Hide Sleeping Bag','Storage Box'],'explore/loot-store':['Storage Box'],
'explore/cave-kit':['Flak Chestpiece','Medical Brew','Simple Shotgun Ammo'],
'explore/gas-mask':['Gas Mask'],'explore/scuba':['SCUBA Tank','SCUBA Flippers'],'explore/fur':['Fur Chestpiece'],
'explore/grapple-kit':['Grappling Hook','Crossbow','Parachute'],
'army/army-yard':['Feeding Trough'],'army/saddles':['Therizinosaurus Saddle','Yutyrannus Saddle'],
'army/cakes':['Sweet Vegetable Cake'],'army/backup-gun':['Pump-Action Shotgun','Simple Shotgun Ammo','Medical Brew'],
'army/rex-saddles':['Rex Saddle'], 'guardians/after-fight':['Feeding Trough'], 'guardians/boss-storage':['Storage Box'],
'dragon/restock':['Sweet Vegetable Cake','Medical Brew'],'dragon/rider-backup':['Medical Brew','Pump-Action Shotgun','Simple Shotgun Ammo'],
'ascend/three-trophies':['Gamma Broodmother Trophy','Gamma Megapithecus Trophy','Gamma Dragon Trophy'],
'ascend/tek-kit':['Fur Chestpiece','Medical Brew','Pump-Action Shotgun'],'ascend/tek-ammo':['Simple Shotgun Ammo'],
'ascend/spare-armour':['Flak Chestpiece','Medical Brew']}
items=b['items']+b['facts']
explicit={'Moschops':'Dino-moschops','Parasaur':'Dino-parasaur','Savoroot':'FarmResource-savoroot','Longrass':'FarmResource-longrass','Sap':'Equipment-sap','Therizinosaurus Saddle':'Item-saddle','Yutyrannus Saddle':'Item-saddle','Rex Saddle':'Item-saddle'}
def visual(name):
 asset=explicit.get(name) or next((i['asset'] for i in items if i['name'].lower()==name.lower() and i.get('asset')),None)
 if not asset or not (root/'native/Ascended/Assets.xcassets'/(asset+'.imageset')).exists():raise ValueError(name)
 return dict(name=name,asset=asset)
roster=json.loads((b['resources']/'the-island-creatures.json').read_text()) if (b['resources']/'the-island-creatures.json').exists() else None
for p in phases:
 for goal in [v for group in p['groups'] for v in group['goals']]:
  key=p['id']+'/'+goal['id'];asset=goal['asset']
  if key in kits:goal['contents']=[visual(n) for n in kits[key]]
  elif asset.startswith('Dino-'):
   names={'therizinosaur':'Therizinosaur','yutyrannus':'Yutyrannus','castoroides':'Castoroides','beelzebufo':'Beelzebufo','megatherium':'Megatherium','triceratops':'Triceratops'}
   n=names.get(asset[5:],asset[5:].replace('-',' ').title());goal['contents']=[dict(name=n,asset=asset)]
  elif asset.startswith(('Equipment-','Item-','FarmResource-')):
   n=next((i['name'] for i in items if i.get('asset')==asset),None)
   goal['contents']=[dict(name=n or goal['title'],asset=asset)]
  elif asset.startswith('Artifact-'):goal['contents']=[dict(name='Artifact of the '+asset[9:].title(),asset=asset)]
  elif asset.startswith('Cutout-Boss-'):goal['contents']=[dict(name=goal['title'].removeprefix('Defeat '),asset=asset)]
  else:goal['contents']=[]
  if any(v['asset']=='Item-saddle' for v in goal['contents']):goal['detail']+=' Saddle artwork is a generic reference; the names identify the required matching saddles.'
pack['reviewedAt']='2026-10-09'
(b['resources']/'the-island-survival-guide.json').write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
print(sum(len(p['groups'][i]['goals']) for p in phases for i in range(4)), 'goals;',len(pack['sources']),'sources')
