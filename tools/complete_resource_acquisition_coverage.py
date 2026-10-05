"""Reconcile acquisition coverage without turning raw actors into verified video pins.
Run after editing spot/source evidence. Unknown filmed coverage stays explicitly unknown.
"""
import json, collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];RES=ROOT/'native/Ascended/Resources';MEDIA=Path('/Volumes/TONY SSD/ASCENDED_MEDIA')
BASE=['Metal','Rich Metal','Crystal','Obsidian','Oil','Silica Pearls','Black Pearls','Cementing Paste','Organic Polymer','Polymer','Rare Flowers','Rare Mushrooms','Honey','Chitin','Keratin','Wood','Stone','Fiber','Thatch','Water','Flint','Element','Clay','Cactus Sap','Salt','Sandpile','Silk','Sulfur','Sap']
CRAFT={
'Polymer':('crafting','Use a powered Fabricator: 2 Obsidian + 2 Cementing Paste produce 1 Polymer. Organic Polymer is a separate gathered substitute.','Polymer'),
'Metal Ingot':('processing','Smelt 2 Metal into 1 Metal Ingot in a fueled Refining Forge or Industrial Forge.','Refining_Forge'),
'Gasoline':('processing','Refine 6 Oil + 5 Hide into 5 Gasoline in a fueled Refining Forge.','Refining_Forge'),
'Electronics':('crafting','Use a powered Fabricator: 3 Silica Pearls + 1 Metal Ingot produce Electronics. Extinction also has gathered sources, which need separate filmed verification.','Electronics'),
'Charcoal':('processing','Burn Wood or Fungal Wood as fuel in a Campfire, Cooking Pot or Forge and collect the Charcoal. Burnt-tree gathering is a separate regional method.','Charcoal'),
'Sparkpowder':('crafting','Grind 2 Flint + 1 Stone in a Mortar and Pestle to make Sparkpowder.','Mortar_and_Pestle'),
'Gunpowder':('crafting','Combine 1 Sparkpowder + 1 Charcoal in a Mortar and Pestle to make Gunpowder.','Mortar_and_Pestle')}
NATIVE_EXCLUDED={'Cactus Sap':'Cactus_Sap','Salt':'Raw_Salt','Sandpile':'Sand','Silk':'Silk','Sulfur':'Sulfur','Clay':'Clay'}
ALIAS={'Beaver Dam':'Cementing Paste','Bee Hive':'Honey','Cactus with few berries':'Cactus Sap','Cactus':'Cactus Sap','Rich Oil':'Oil','Polymer':'Organic Polymer','Wood Coal':'Charcoal','Carrots':'Rockarrot','Corn':'Longrass','Potatoes':'Savoroot','Mushrooms':'Mushrooms (type unverified)','Gem':'Gem (type unverified)','Gem Bio':'Blue Gem','Gem Element':'Red Gem','Gem Light':'Green Gem','Plant Species X':'Plant Species X Seed','Plant Proto Species R':'Plant Proto Species R Seed','Dino Corpse':'Creature carcass (drops unverified)','Oil Meat':'Oil source (actor unverified)','Bones':'Bone deposit (drops unverified)'}
MAPPLANES={'genesis-part-1':'Genesis Part 1: filmed Arctic biome; coordinates belong to the creator in-game map','genesis-part-1-ocean':'Genesis Part 1: Ocean biome, selected in the creator in-game map','aberration':'Aberration: green/blue-zone filmed region','astraeos':'Astraeos: Phokintos region in the source revision'}

def main():
 p=RES/'verified-resource-spots.json';doc=json.loads(p.read_text());guides=json.loads((RES/'resource-guides.json').read_text())['guides'];guideby={g['spotID']:g for g in guides};existing={(r['map'],r['resource']):r for r in doc['coverage']};rows=[]
 maps=[p.stem.removesuffix('-resources') for p in RES.glob('*-resources.json')]
 metadata=json.loads((MEDIA/'resource-acquisition-audit/source-metadata.json').read_text())
 for q in list((MEDIA/'resource-acquisition-audit').glob('*-inspect.json')) + list((MEDIA/'resource-acquisition-round2').glob('*-inspect.json')):
  try:d=json.loads(q.read_text());metadata[d['videoId']]=d
  except (ValueError,KeyError):pass
 for spot in doc['spots']:
  spot['sourcePlane']=MAPPLANES.get(spot['map'],spot['map']+' filmed region')
  spot['sourceCoordinateScope']='Filmed camera/waypoint region; not every actor or permanent spawn.'
 for map in sorted(maps):
  rawtypes={x['resource_type'] for x in json.loads((RES/(map+'-resources.json')).read_text())};required=set(BASE)|set(CRAFT)|{ALIAS.get(x,x) for x in rawtypes}
  if map=='aberration':required|={'Fungal Wood','Congealed Gas Ball','Element Ore','Green Gem','Blue Gem','Red Gem'}
  if map=='extinction':required|={'Element Dust','Condensed Gas','Corrupted Nodule','Blue Crystalized Sap','Red Crystalized Sap'}
  if map=='lost-colony':required|={'Blood Sap','Fungal Wood','Red Element','Red Element Dust','Red Element Shard','Pristine Vulpite','Corrupted Vulpite'}
  for resource in sorted(required):
   spots=[s for s in doc['spots'] if s['map']==map and any(resource == x or (resource == 'Honey' and x == 'Giant Bee Honey') for x in s['resources'])]; row=dict(existing.get((map,resource),{}))
   row.update(map=map,resource=resource,spotIDs=[s['id'] for s in spots])
   if spots:
    row.update(status='verified',reason='Source-video GPS region reviewed; open a region card for the actual filmed evidence.',evidenceState='gps-region-reviewed',acquisitionClass='creature-drop' if resource in ['Chitin','Keratin'] else 'production' if resource=='Sap' else 'region-harvest')
    row['harvestDemonstrated']=any(guideby.get(s['id'],{}).get('harvestDemonstrated',False) for s in spots)
    row['sourceURL']=spots[0]['sourceURL'];row['sourcePlane']=spots[0]['sourcePlane'];row['limitations']='A reviewed region does not establish every individual node, current respawn or fixed yield. Harvest actions are shown only when the region guide says so.'
   elif resource in CRAFT:
    status,method,wiki=CRAFT[resource];row.update(status=status,method=method,reason=method,sourceURL='https://ark.wiki.gg/wiki/'+wiki,evidenceState='mechanics-reference',acquisitionClass=status,harvestDemonstrated=False,limitations='Recipe/reference coverage only. No filmed local GPS, ingredient route or crafting clip is claimed.')
   elif map in ['the-island','the-center'] and resource in NATIVE_EXCLUDED:
    row.update(status='unavailable',reason='No native '+('Sand' if resource=='Sandpile' else 'Raw Salt' if resource=='Salt' else resource)+' harvest source is documented for the standard '+map+' map. Transfers, mods and imported crafting ingredients are separate.',sourceURL='https://ark.wiki.gg/wiki/'+NATIVE_EXCLUDED[resource],evidenceState='native-availability-reference',acquisitionClass='not-native',harvestDemonstrated=False,limitations='Applies to standard native gathering; does not assert that transferred items or modded sources are impossible.')
   elif resource in ['Longrass','Rockarrot','Savoroot','Citronal']:
    row.update(status='processing',reason='Grow '+resource+' from its seed in a Medium or Large Crop Plot with water and fertilizer, then collect the ripe crop from the plot inventory.',sourceURL='https://ark.wiki.gg/wiki/Farming',evidenceState='mechanics-reference',acquisitionClass='crop-production',harvestDemonstrated=False,limitations='Crop-production reference only. No filmed local seed route, wild plant GPS or crop-collection loop is claimed for this category.')
   elif resource=='Sap' and map in ['the-island','the-center','scorched-earth','aberration','extinction','valguero','genesis-part-1','genesis-part-1-ocean']:
    row.update(status='processing',reason='Use a Tree Sap Tap on a supported tree; Scorched Earth and Extinction also have Joshua-tree harvesting, Valguero has stump harvesting, and Genesis has the Hexagon Exchange. Verify the method appropriate to this map in the source reference.',sourceURL='https://ark.wiki.gg/wiki/Sap',evidenceState='mechanics-reference',acquisitionClass='production',harvestDemonstrated=False,limitations='No reviewed local GPS or three-clip sequence is available for this map/category.')
   elif row.get('status') in ['crafting','crafted','processing','creature','boss']:
    row.update(evidenceState='filmed-method' if row.get('videoID') else 'mechanics-reference',acquisitionClass='creature-drop' if row['status']=='creature' else row['status'],harvestDemonstrated=(map=='ragnarok' and resource=='Chitin'),limitations=row.get('limitations') or 'This acquisition entry does not supply a verified GPS pin or a three-clip local walkthrough.')
   elif resource=='Cementing Paste':
    row.update(status='crafting',reason='Combine 4 Chitin or Keratin + 8 Stone in a Mortar and Pestle. Beaver-dam loot and Achatina production are additional sources, requiring separate local verification.',sourceURL='https://ark.wiki.gg/wiki/Cementing_Paste',evidenceState='mechanics-reference',acquisitionClass='crafting',harvestDemonstrated=False,limitations='No filmed local dam GPS or acquisition clip is claimed.')
   elif resource=='Element' and map=='aberration':
    row.update(status='boss',reason='ARK: Survival Ascended Rockwell rewards Element. Charge Nodes also craft Element from Aberration materials; see the reference for the full recipe and charging restrictions.',sourceURL='https://ark.wiki.gg/wiki/Element',evidenceState='mechanics-reference',acquisitionClass='boss/processing',harvestDemonstrated=False,limitations='Boss/charge-node acquisition reference; no filmed acquisition loop or charge-node GPS is claimed.')
   elif resource=='Element' and map=='extinction':
    row.update(status='processing',reason='Craft Unstable Element from 1000 Element Dust and wait for it to convert. Defended Element Nodes are another source.',sourceURL='https://ark.wiki.gg/wiki/Element',evidenceState='mechanics-reference',acquisitionClass='processing/defense-event',harvestDemonstrated=False,limitations='No local filmed defense event or dust route is verified.')
   elif resource=='Element' and map.startswith('genesis-part-1'):
    row.update(status='processing',reason='The Genesis Hexagon Exchange sells Element; lunar and volcanic gathering supply Element Shards. Those gathering routes belong to their respective biomes.',sourceURL='https://ark.wiki.gg/wiki/Element',evidenceState='mechanics-reference',acquisitionClass='exchange/processing',harvestDemonstrated=False,limitations='No Ocean ore pin or same-plane gathering claim is inferred from a lunar/volcanic route.')
   else:
    row.update(status='unverified',reason='A source-backed acquisition walkthrough for this map/category has not yet been verified.',evidenceState='needs-source-verification',acquisitionClass='creature-drop' if resource in ['Chitin','Keratin','Organic Polymer','Black Pearls'] else 'region-harvest',harvestDemonstrated=False,limitations='No GPS, availability, yield or harvesting footage is inferred from raw node labels.')
   if row.get('status')=='boss' and not row.get('sourceURL'):row['sourceURL']='https://ark.wiki.gg/wiki/Element'
   rows.append(row)
 for row in rows:
  if row['status']=='unverified':
   candidates=[]
   aliases={'Metal':['metal'],'Rich Metal':['metal'],'Oil':['oil','aceite'],'Silica Pearls':['pearls','perlas'],'Crystal':['crystal','cristal'],'Obsidian':['obsidian','obsidiana'],'Salt':['salt','sal'],'Sulfur':['sulfur','sulphur','sulfuro'],'Silk':['silk','seda'],'Cementing Paste':['paste','beaver','cement'],'Organic Polymer':['polymer'],'Black Pearls':['black pearls'],'Rare Flowers':['rare flowers'],'Rare Mushrooms':['rare mushrooms'],'Sap':['sap'],'Element':['element']}
   for video in {s['videoID'] for s in doc['spots'] if s['map']==row['map']}:
    for chapter in metadata.get(video,{}).get('chapters',[]):
     if any(a in chapter.get('title','').lower() for a in aliases.get(row['resource'],[row['resource'].lower()])):
      candidates.append(dict(videoID=video,title=chapter['title'],startSeconds=chapter.get('start',0),endSeconds=chapter.get('end'),sourceURL='https://www.youtube.com/watch?v='+video+'&t='+str(int(chapter.get('start',0)))+'s',evidenceState='chapter-metadata-only'))
   if candidates:row['candidateSourceChapters']=candidates
 doc['coverage']=rows;doc['coverageScope']='Every existing acquisition category, common processing recipe and normalized raw-label candidate is tracked for every selectable map. Raw labels are audit candidates only. Unknown coverage stays unverified.';p.write_text(json.dumps(doc,indent=2)+'\n')
 sources=[]
 for video in sorted({s['videoID'] for s in doc['spots']}|{r.get('videoID') for r in rows if r.get('videoID')}):
  m=metadata.get(video,{});related=[s for s in doc['spots'] if s['videoID']==video];sources.append(dict(videoID=video,canonicalURL='https://www.youtube.com/watch?v='+video,title=m.get('title'),channel=m.get('channel'),publishDate=m.get('publishDate'),statistics=m.get('statistics'),chapters=m.get('chapters',[]),inspectedAt=m.get('inspectedAt'),sourceSpots=[s['id'] for s in related],rightsBasis='licensed',rightsApproval='User confirmed all source licenses',acquisitionState='partial-native-chunks/full-HTTP403' if video=='vGqngPRx6po' or any('403' in guideby.get(s['id'],{}).get('sourceAcquisition','') for s in related) else 'approved-complete-local-cache',metadataState='inspected' if m else 'metadata-unavailable'))
 ledger=dict(schemaVersion=1,scope=doc['coverageScope'],sourceCount=len(sources),sources=sources,rows=rows,mapSummary=[dict(map=m,categories=sum(r['map']==m for r in rows),states=dict(collections.Counter(r['evidenceState'] for r in rows if r['map']==m)),gpsRegions=sum(s['map']==m for s in doc['spots']),harvestClipGuides=sum(g['map']==m and g['harvestDemonstrated'] for g in guides)) for m in sorted(maps)],blockers=[dict(action='Alternative popular Island Plant Species X guide vGqngPRx6po',result='Licensed download received native1080pAV1 chunks through56.2s, thenHTTP403Forbidden. Reviewed opening footage has no readableGPS; no pin was added.',evidence='resource-acquisition-round2/vGqngPRx6po-download.log'),dict(action='Fresh licensed Scorched Earth full download',result='HTTP403 Forbidden',evidence='resource-acquisition-audit/scorched-retry.log'),dict(action='Fresh native YouTube metadata search',result='Official search.list and videos.list both returnHTTP400 INVALID_ARGUMENT, badRequest, API_KEY_INVALID with minimal valid parameters. Keychain key exists but is invalid; this is a credential configuration failure.',evidence='resource-acquisition-round2/api-diagnostic.json'),dict(action='Installed Cốc Cốc native media discovery',result='Public licensed source plays, but native Download video & audio panel remains Searching for Video/Audio with no formats/download control',restrictionBypass=False)])
 out=ROOT/'tools/evidence/resource-acquisition-ledger.json';out.parent.mkdir(exist_ok=True);out.write_text(json.dumps(ledger,indent=2)+'\n');print(json.dumps(dict(regions=len(doc['spots']),entries=len(rows),sources=len(sources),states=dict(collections.Counter(r['evidenceState'] for r in rows)))))
if __name__=='__main__':main()
