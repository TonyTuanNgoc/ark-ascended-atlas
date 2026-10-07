#!/usr/bin/env python3
"""Build map-specific farm categories. No coordinates or yields inferred."""
import json, pathlib, urllib.parse
ROOT=pathlib.Path(__file__).resolve().parents[1]
P=ROOT/'native/Ascended/Resources'
MAPS=['ragnarok','the-island','the-center','scorched-earth','aberration','extinction','lost-colony','genesis-part-1','genesis-part-1-ocean','valguero','astraeos']
EXCLUDE={'Wood','Thatch','Fiber','Stone','Flint'}
ALIASES={'Black Pearl':'Black Pearls','Rare Flower':'Rare Flowers','Rare Mushroom':'Rare Mushrooms','Element Shards':'Element Shard','Polymer':'Organic Polymer','Carrots':'Rockarrot','Corn':'Longrass','Potatoes':'Savoroot','Honey':'Giant Bee Honey','Cactus':'Cactus Sap','Cactus with few berries':'Cactus Sap','Sandpile':'Sand'}
WIKI_ALIASES={'Black Pearls':'Black_Pearl','Rare Flowers':'Rare_Flower','Rare Mushrooms':'Rare_Mushroom','Mushrooms':'Mushroom','Eggs':'Eggs','Berries':'Berries','Feces':'Feces','Rich Metal':'Metal'}
def wiki(n):return 'https://ark.wiki.gg/wiki/'+urllib.parse.quote(WIKI_ALIASES.get(n,n.replace(' ','_')),safe='_')
# Raw type labels which are ambiguous or describe a source rather than an item.
SKIP_NODES={'Gem','Gem Bio','Gem Element','Gem Light','City Prop','City Lights','Gargoyle Statue','Death Kiss Plant','Toxic Plant','Plant Proto Species R','Wood Coal','Bones','Dino Corpse','Oil Meat','Clay','Rich Oil','Plant Species X','Mushrooms'}
SKIP_DROPS={'Captains Hat','Rex Bone Helmet','Umbra Apex Drop','Umbra Scale','Berries','Mushrooms'}
COMMON_BERRIES=['Amarberry','Azulberry','Tintoberry','Mejoberry','Narcoberry','Stimberry','Cianberry','Magenberry','Verdberry']
CROPS=['Citronal','Longrass','Rockarrot','Savoroot']
evidence=[]
out=[]
for mid in MAPS:
 creatures=json.load(open(P/(mid+'-creatures.json')))['creatures']
 nodes=json.load(open(P/(mid+'-resources.json')))
 byname={c['name']:c for c in creatures}
 resources={}
 def add(n,a,m,src=None,basis=None):
  n=ALIASES.get(n,n)
  if n in EXCLUDE:return
  if n in resources:
   if a=='gatherable' and resources[n]['availability']=='production':
    m+=' Alternative production: '+resources[n]['method']
   else:return
  resources[n]={'name':n,'sourceURL':src or wiki(n),'availability':a,'method':m}
  evidence.append({'map':mid,'resource':n,'basis':basis or 'Shared official-community-wiki mechanic; applicability inferred from the existing ASA map catalog.','sourceURL':src or wiki(n)})
 def species(part):return [c['name'] for c in creatures if part.lower() in c['name'].lower() and 'ghost' not in c['name'].lower()]
 for n in nodes:
  typ=n['resource_type']
  if typ in SKIP_NODES:continue
  if typ=='Beaver Dam':
   for r in ['Cementing Paste','Rare Flowers','Rare Mushrooms','Silica Pearls']:
    add(r,'gatherable','Loot a wild Giant Beaver Dam; remove all remaining contents so the dam can respawn.',wiki('Giant Beaver Dam'),f'ASA {mid}-resources.json contains Beaver Dam nodes; Wiki lists contents.')
  elif typ=='Bee Hive':add('Giant Bee Honey','gatherable','Collect from a wild bee hive; bees defend their honey.',wiki('Giant Bee Honey'),f'ASA {mid}-resources.json contains Bee Hive nodes.')
  else:add(typ,'gatherable','Harvest the corresponding natural resource node with an appropriate tool or creature.',basis=f'Unambiguous ASA node type {typ} in {mid}-resources.json; shared Wiki item mechanic.')
 if any(n['resource_type']=='Plant Species X' for n in nodes) or mid in ['aberration','genesis-part-1']:
  add('Plant Species X Seed','gatherable','Harvest a wild X plant or appropriate swamp vegetation.',wiki('Plant Species X'),basis='Local ASA X-plant nodes or primary Wiki map-specific X-seed locations.')
 if mid in ['ragnarok','astraeos'] and any(n['resource_type']=='Clay' for n in nodes):
  add('Clay','gatherable','Harvest a natural clay pile; crafted clay is a separate obtaining route.',wiki('Clay'),basis='Wiki Clay confirms natural Ragnarok clay piles; local ASA catalog contains explicit Clay nodes, including Astraeos. Astraeos applicability is local catalog evidence.')
 if mid in ['ragnarok','the-center','valguero']:
  add('Charcoal','gatherable','Harvest burnt trees in the volcanic area; this entry is for natural burnt trees, not burning Wood in a forge.',wiki('Charcoal'),basis='Wiki Charcoal explicitly lists natural burnt-tree gathering on these three maps.')
 # Use explicit local ASA species drops, never an all-map presumed creature list.
 for c in creatures:
  if any(x in c['name'].lower() for x in ['ghost','zombie','skeletal','bunny','party','gachaclaus','boss']):continue
  for n in c.get('drops',[]):
   if n in SKIP_DROPS:continue
   n=n.replace(' (chance)','')
   add(n,'creature',f'Harvest or loot {c["name"]}; this is a creature source, not a fixed mineral node.',basis=f'{mid}-creatures.json lists {c["name"]} and this drop. ASA species occurrence comes from the existing map catalog; item/corpse mechanic uses Wiki. Not separately measured in game.')
 # Hydration is a naturally collected resource, not a craft-only container.
 water_method = ('Water is scarce: drink from groundwater veins and place a Water Well on a vein to refill containers; Water Jug Bugs and Morellatops provide additional sources.' if mid=='scorched-earth' else 'Drink from natural rivers, lakes or the ocean, or refill a Waterskin, Water Jar or Canteen at suitable water; establish an intake and tap for a base water supply.')
 add('Water','gatherable',water_method,wiki('Water Well') if mid=='scorched-earth' else wiki('Water'),basis='Primary Wiki Water hydration/refill mechanic applies to natural map water. Scorched Earth overview and Water Well page document scarce water, groundwater veins and ASA wireless irrigation. No GPS inferred.')
 # Shared wild vegetation and survivor production, applicable on each playable plane.
 add('Berries','gatherable','Harvest berry bushes by hand or with a berry-harvesting creature.',basis='Shared Wiki vegetation mechanic; general vegetation applies to each playable map, not a coordinate claim.')
 for n in COMMON_BERRIES:
  add(n,'gatherable','Harvest wild berry bushes or grow the corresponding berry seed in a crop plot.',wiki('Berries'),basis='Shared Wiki berry family mechanic; ordinary vegetation applies to all maps.')
  add(n+' Seed','gatherable','Harvest berry bushes for seeds.',wiki('Seeds'),basis='Shared Wiki seed mechanic; ordinary vegetation applies to all maps.')
 for n in CROPS:
  if n not in resources:add(n,'production','Grow the corresponding seed in an irrigated, fertilized crop plot; no wild crop patch is claimed.',wiki('Farming'),basis='Shared Wiki crop-plot production; wild patch availability is only claimed when an explicit node type exists.')
  add(n+' Seed','gatherable','Harvest wild vegetation for crop seeds, then plant in a crop plot.',wiki('Farming'),basis='Shared Wiki wild-vegetation seed mechanic; no specific crop-patch coordinate inferred.')
 add('Eggs','production','Collect eggs laid by local egg-laying creatures; tame females provide repeatable production. Fertilized nest eggs are listed separately.',wiki('Eggs'),basis='Shared Wiki egg mechanic; category intentionally groups ordinary species eggs, not a claim every species occurs on the map.')
 add('Blood Pack','production','Use a Blood Extraction Syringe to collect survivor blood; each extraction costs Health.',wiki('Blood Extraction Syringe'),basis='Wiki syringe mechanic applies to survivors on all maps; no crafting of the Blood Pack itself.')
 add('Feces','production','Collect human or non-aquatic-creature feces from the ground for crop fertilizer.',wiki('Feces'),basis='Wiki explicitly states humans and non-aquatic creatures produce feces; every plane supports survivors.')
 if species('Coelacanth') or species('Piranha'):
  add('Raw Fish Meat','creature','Harvest a local fish corpse.',wiki('Coelacanth'),basis='Local ASA fish roster + Wiki confirms Aberrant variant shares normal fish drops.')
 if species('Salmon'):
  add('Raw Prime Fish Meat','creature','Harvest a local Sabertooth Salmon corpse using a suitable tool.',wiki('Raw Prime Fish Meat'),basis='Local ASA Salmon roster + shared Wiki prime-fish harvesting mechanic.')
 if species('Archelon'):add('Archelon Algae','production','Collect algae passively produced by a tamed Archelon.',wiki('Archelon'),basis='Local ASA Archelon roster + primary Wiki Algae Production mechanic.')
 if species('Gigantoraptor'):add('Gigantoraptor Feather','production','Collect a feather from a tamed Gigantoraptor for breeding stat inheritance.',wiki('Breeding'),basis='Local ASA Gigantoraptor roster + Wiki ASA breeding improvement describes produced feathers.')
 if species('Ovis'):
  add('Raw Mutton','creature','Harvest a local Ovis corpse.',wiki('Raw Mutton'),basis='Local map ASA Ovis roster + Wiki Ovis/mutton mechanic.')
  add('Wool','production','Shear a tamed local Ovis with Scissors; wool regrows.',wiki('Wool'),basis='Local map ASA Ovis roster + Wiki Wool shearing mechanic.')
 if species('Achatina'):add('Achatina Paste','production','Collect paste produced by a tamed Achatina set to wander.',wiki('Achatina Paste'),basis='Local ASA Achatina roster + Wiki passive production mechanic.')
 if species('Snow Owl'):add('Snow Owl Pellet','production','Collect pellets produced by a local Snow Owl; useful for farming and Gacha feeding.',wiki('Snow Owl Pellet'),basis='Local ASA Snow Owl roster + Wiki pellet production mechanic.')
 if species('Hesperornis'):add('Golden Hesperornis Egg','production','Have a tamed Hesperornis catch fish and collect a golden egg when produced.',wiki('Golden Hesperornis Egg'),basis='Local ASA Hesperornis roster + Wiki production mechanic.')
 if species('Gacha'):
  add('Gacha Crystal','production','Collect a crystal dropped by a wild or tamed Gacha; contents depend on that Gacha.',wiki('Gacha'),basis='Local ASA Gacha roster + Wiki natural/production crystal mechanic.')
  for material in ['Fragmented Green Gem','Corrupted Wood','Raw Salt','Sand','Blue Crystalized Sap','Clay','Congealed Gas Ball','Crystal','Oil','Silica Pearls','Silk','Black Pearls','Metal','Obsidian','Organic Polymer','Red Crystalized Sap','Sap','Sulfur','Element Dust']:
   add(material,'production','Collect and open a Gacha Crystal; that Gacha must have the corresponding resource in its production list.',wiki('Gacha'),basis='Primary Wiki Gacha production list plus local ASA Gacha occurrence. Conditional creature production, not a mineral/gas node claim.')
 if species('Desmodus'):add('Blood Pack','creature','Use Desmodus blood collection when attacking suitable creatures.',wiki('Desmodus'),basis='Local ASA Desmodus roster + Wiki blood collection mechanic.')
 for creature,egg in [('Wyvern','Wyvern Egg'),('Rock Drake','Rock Drake Egg'),('Deinonychus','Deinonychus Egg'),('Magmasaur','Magmasaur Egg')]:
  if species(creature) and mid not in ['extinction','genesis-part-1-ocean']:
   add(egg,'gatherable','Steal a fertilized egg from a wild '+creature+' nest; nearby adults can defend the nest.',wiki(egg),basis='Local ASA species roster plus shared Wiki nest mechanic. Corrupted variants are explicitly not used as evidence of nests.')
 if species('Wyvern') and mid not in ['extinction','genesis-part-1-ocean']:
  add('Wyvern Milk','creature','Knock out a wild adult female Wyvern and loot its inventory, or kill an Alpha Fire Wyvern.',wiki('Breeding'),basis='Local ordinary ASA Wyvern occurrence + Wiki milk obtaining mechanic; excludes Corrupted Wyverns.')
 # Sap has map-specific mechanics absent from coarse node catalogs.
 if mid in ['the-island','the-center','ragnarok','aberration','scorched-earth','valguero','astraeos']:
  add('Sap','gatherable','Use Tree Sap Taps on suitable redwoods; Scorched Earth uses harvestable Joshua trees and Valguero also has sap stumps.',wiki('Sap'),basis='Wiki Sap map-specific gathering sections; Astraeos ASA overview explicitly contains redwood areas.')
 # Primary wiki-backed expansion specials. Values remain resource categories, not GPS points.
 specials={
 'aberration':['Green Gem','Blue Gem','Red Gem','Congealed Gas Ball','Element Ore','Fungal Wood','Aggeravic Mushroom','Aquatic Mushroom','Ascerbic Mushroom','Auric Mushroom'],
 'valguero':['Green Gem','Blue Gem','Red Gem','Congealed Gas Ball','Fungal Wood','Aggeravic Mushroom','Aquatic Mushroom','Ascerbic Mushroom','Auric Mushroom','Raw Salt','Cactus Sap'],
 'astraeos':['Green Gem','Blue Gem','Red Gem','Congealed Gas Ball'],
 'genesis-part-1-ocean':['Green Gem','Blue Gem','Red Gem','Fungal Wood'],
 'extinction':['Blue Crystalized Sap','Red Crystalized Sap','Fragmented Green Gem','Condensed Gas','Silicate','Corrupted Nodule','Corrupted Wood','Raw Salt'],
 'genesis-part-1':['Ambergris','Green Gem','Blue Gem','Red Gem','Congealed Gas Ball','Condensed Gas','Raw Salt','Element Shard'],
 'scorched-earth':['Sand','Raw Salt','Cactus Sap','Silk','Sulfur'],
 'ragnarok':['Sand','Raw Salt','Cactus Sap','Silk','Sulfur']}
 for n in specials.get(mid,[]):
  method='Harvest the natural '+n+' source in the map’s relevant biome.'
  if n=='Congealed Gas Ball':method='Place a Gas Collector on a Gas Vein, or pick up gas balls after an eruption.'
  if n=='Ambergris':method='Mine green-lined lunar rocks or harvest an Astrocetus; not available from the Ocean plane.'
  if n=='Element Shard':method='Mine volcanic red crystals or appropriate lunar rocks; not an Ocean resource.'
  if mid=='genesis-part-1-ocean':
   add(n,'gatherable',method,wiki('Terrarium (Genesis: Part 1)'),basis='Primary Wiki Terrarium region page lists Blue Gem, Green Gem, Red Gem and Fungal Wood in the Genesis Ocean biome.')
   continue
  add(n,'gatherable',method,basis='Official community Wiki expansion resource/gathering or resource-map page confirms map availability; shared ASA/ASE mechanics except explicit edition distinctions.')
 if mid in ['extinction','astraeos']:
  for n in ['Element','Element Shard','Element Dust']:
   add(n,'gatherable','Defend an Element Node through its waves, then harvest surviving nodes; yield varies.',wiki('Element Node'),basis='Wiki Element Node explicitly lists Extinction and Astraeos and the three outputs.')
  for n in ['Scrap Metal','Electronics']:
   add(n,'creature','Harvest naturally spawning Tek creatures; do not confuse ASA spawn scope with ASE all-map Tek spawns.',wiki('Tek Creatures'),basis='Wiki Tek Creatures explicitly restricts natural ASA Tek spawns to Extinction and Astraeos.')
 if species('Ferox'):add('Element Dust','production','A tamed small Ferox can dig up small amounts of Element Dust.',wiki('Ferox'),basis='Local ASA Ferox roster + Wiki Element Dust Producer mechanic.')
 if mid in ['the-island','the-center','ragnarok','scorched-earth','aberration','valguero']:
  add('Element','boss','Defeat the applicable map boss and collect its Element reward; ASA Rockwell rewards Element, unlike the ASE mechanic.',wiki('Element'),basis='Wiki Element boss/reward mechanics; explicit ASA Rockwell note retained.')
 if mid=='lost-colony':
  add('Common Mushroom','gatherable','Harvest mushroom/blue polymer plants in the Aberrant Spread.',wiki('Common Mushroom'),basis='Wiki Common Mushroom gathering section plus local ASA Mushrooms nodes; source page contains a typo repeating Rare Mushrooms.')
  add('Blood Sap','gatherable','Harvest Blood Sap vegetation; no yield or exact plant identity is asserted.',wiki('Lost Colony'),basis='Wiki Lost Colony lists Blood Sap; local ASA map node catalog explicitly contains Blood Sap.')
  add('Pristine Vulpite','creature','With a companion Veilwyn, perform a wild Solwyn’s required emote until curiosity reaches 100%, then claim the Vulpite.',wiki('Pristine Vulpite'),basis='Wiki Pristine Vulpite explicitly explains the Lost Colony obtaining interaction.')
  add('Red Element','boss','Complete Lost Colony outposts or defeat the Lost King and Queen; crafting routes are outside this wild-resource roster.',wiki('Red Element'),basis='Wiki Red Element Gathering section explicitly gives boss and mission rewards.')
 # Do not mislabel broad node Mushrooms as a universal edible mushroom; ordinary maps yield Rare Mushrooms.
 if any(n['resource_type']=='Mushrooms' for n in nodes) and mid not in ['aberration','lost-colony','valguero']:
  add('Rare Mushrooms','gatherable','Harvest the appropriate mushroom-bearing vegetation or crystals.',wiki('Rare Mushroom'),basis='ASA map has coarse Mushrooms nodes; canonical raw resource is Rare Mushrooms, not unspecified generic Mushrooms.')
 # Specific safe mushroom families only where confirmed; Bio Toxin from Aberration/Valguero poisonous mushrooms.
 if mid in ['aberration','genesis-part-1']:
  add('Plant Species Z Seed','gatherable','Stand near a wild Plant Species Z and collect its expelled seed.',wiki('Plant Species Z'),basis='Wiki Plant Species Z lists Aberration and Genesis Part 1 and explains natural seed production.')
  add('Plant Species Z Fruit','production','Grow Plant Species Z in a large crop plot and harvest its fruit.',wiki('Plant Species Z'),basis='Wiki Plant Species Z production mechanic; seed obtainable locally on these maps.')
 if mid in ['aberration','valguero']:
  add('Bio Toxin','gatherable','Harvest poisonous mushrooms; avoid their spores or use suitable protection.',wiki('Rare Flower'),basis='Wiki Rare Flower and Valguero ASA overview explicitly give Bio Toxin from poisonous mushrooms.')
 # Remove any source category accidentally treated as a material.
 out.append({'map':mid,'resources':sorted(resources.values(),key=lambda x:x['name'].lower())})
limitations=[
 'Resource families are usable selector categories: Berries, Eggs and Feces intentionally group species/size variants, while common berries and seeds also retain individual canonical names.',
 'ASA local node and species catalogs establish map applicability; Wiki provides shared resource mechanics. These combinations are documented in per-resource evidence as inference, not measured gameplay proof.',
 'No GPS coordinates, yields, spawn rates or creature effectiveness are invented by this roster. The separate verified-resource-spots catalogue controls location evidence.',
 'Only Wood, Thatch, Fiber, Stone and Flint are user-excluded basics. Cosmetic skins, artifacts, crafted equipment, cooked food and recipes are outside resource-farming scope.',
 'Craft-only outputs (Metal Ingot, Gasoline, Polymer, Gunpowder, Preserving Salt, Corrupted Vulpite and unstable Element variants) are excluded. Items obtainable directly in the wild remain included even when an alternate recipe exists.',
 'Genesis Ocean is a separate plane; lunar Ambergris, volcanic/lunar Element Shard, lunar/volcanic gas specials are not copied to its roster; Terrarium gems and Fungal Wood have their own primary region evidence. Existing local Ocean species catalog establishes creature presence.',
 'Ordinary Eggs is a family; hundreds of species egg variants are not separate row cards. Special wild nest eggs are separate where map-specific species/nest evidence exists.',
 'Ambiguous internal mesh labels Gem/Gem Bio/Gem Element/Gem Light/City Prop/Wood Coal do not establish a material by themselves. Specialized gems use primary map references instead.',
 'Newer Lost Colony Red Element Dust/Shard harvesting and Plant Proto Species R seed subtype mappings are not sufficiently verified in this review; omitted pending source confirmation.',
 'Sources were researched on 2026-10-07. Wiki direct opens can return HTTP 403; indexed official-community-Wiki text was consulted where this happened.'
]
(P/'farming-resources.json').write_text(json.dumps({'schemaVersion':1,'reviewedAt':'2026-10-07','excludedResources':sorted(EXCLUDE),'limitations':limitations,'maps':out},ensure_ascii=False,indent=2)+'\n')
ev={'schemaVersion':1,'reviewedAt':'2026-10-07','scope':'Map-specific ASA gatherable, creature, natural-production and boss resources; no crafted-only outputs.','counts':{m['map']:len(m['resources']) for m in out},'limitations':limitations,'primaryReviewedSources':[wiki(n) for n in ['Gathering and Weight Reduction','Blood Extraction Syringe','Gacha','Human Hair','Eggs','Feces','Farming','Sap','Raw Salt','Ambergris','Mutagel','Congealed Gas Ball','Condensed Gas','Green Gem','Element','Element Shard','Element Node','Tek Creatures','Silicate','Clay','Charcoal','Berries','Seeds','Archelon','Breeding','Coelacanth','Plant Species X','Plant Species Z','Terrarium (Genesis: Part 1)','Extinction','Valguero','Astraeos','Lost Colony','Common Mushroom','Pristine Vulpite','Red Element']],'rejectedCandidates':[{'resource':'Mutagel','reason':'Wiki specifies Genesis Part 2; none of the 11 supported planes is Genesis Part 2.'},{'map':'aberration','resources':['Cactus Sap','Raw Salt','Sulfur'],'reason':'Existing spot candidates are unverified; no map-specific natural availability verified. Not copied.'},{'map':'extinction','resource':'Congealed Gas Ball','reason':'No wild gas-vein claim: Wiki gives a processing route from Condensed Gas, but local Gacha enables conditional crystal production, which is retained.'},{'resources':['Polymer','Human Hair','Preserving Salt','Corrupted Vulpite','Red Element Dust','Red Element Shard'],'reason':'Processed or insufficient natural-source confirmation; Human Hair is unavailable under default ASA hair-growth settings.'},{'resources':['Umbra Apex Drop','Umbra Scale'],'reason':'Local dump labels need canonical primary mechanic confirmation.'}],'entries':evidence}
(ROOT/'tools/evidence/farming26-roster.json').write_text(json.dumps(ev,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(ev['counts'],indent=2));print('total',sum(ev['counts'].values()))
