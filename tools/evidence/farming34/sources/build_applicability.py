import json,pathlib,collections
P=pathlib.Path(__file__).parent
cov=json.loads((P.parents[1]/'farming33'/'coverage.json').read_text())
queue=json.loads((P/'prioritized-fresh-source-queue.json').read_text())['sources']
W='https://ark.wiki.gg/wiki/'
mapname={'the-island':'The_Island','the-center':'The_Center','ragnarok':'Ragnarok','scorched-earth':'Scorched_Earth','aberration':'Aberration','extinction':'Extinction','valguero':'Valguero','astraeos':'Astraeos','lost-colony':'Lost_Colony','genesis-part-1':'Genesis:_Part_1','genesis-part-1-ocean':'Genesis:_Part_1'}
base={'Metal','Rich Metal','Crystal','Obsidian','Oil','Silica Pearls'}
node={m:set(base) for m in mapname};node['scorched-earth'].discard('Oil');node['scorched-earth'].add('Rare Flowers');node['extinction'].discard('Silica Pearls');node['genesis-part-1-ocean']={'Crystal','Metal','Rich Metal','Oil','Silica Pearls'}
for m in ['ragnarok','aberration','valguero','genesis-part-1','astraeos','lost-colony']:node[m].add('Black Pearls')
for m in ['valguero','astraeos','lost-colony']:node[m].add('Organic Polymer')
for m in ['valguero','astraeos']:node[m].add('Rare Flowers')
rows=[]
def method(kind,status,detail,url,edition='wiki mechanics may mix ASE/ASA; verify current ASA footage'):
 return {'kind':kind,'status':status,'detail':detail,'sourceUrl':url,'checkedDate':'2026-10-08','editionLimit':edition}
for r in cov['rows']:
 m=r['map'];res=r['resource'];methods=[];warnings=[];sources=[]
 if res in node[m]:
  url=W+'Resource_Map/'+mapname[m]
  if m=='genesis-part-1-ocean':url=W+'Ocean_(Genesis:_Part_1)'
  if m=='astraeos':url='https://server.nitrado.net/en-GB/ark-survival-ascended-wiki/map/astraeos'
  methods.append(method('natural-node','primary-wiki-or-partner-positive', 'Resource marker or biome prose explicitly supports this node class; exact ASA GPS/three regions are not established',url))
 if res=='Chitin':methods.append(method('creature-harvest','general-mechanic-confirmed','Harvest insect/crustacean corpses; map fauna and regions need local ASA proof',W+'Gathering_and_Weight_Reduction'))
 if res=='Cementing Paste':
  methods.append(method('craft','recipe-confirmed','Chitin/Keratin/Shell Fragment plus Stone at Mortar/Chemistry Bench; a craft recipe does not create three geographic paste nodes',W+'Cementing_Paste'))
  methods.append(method('craft-substitute','general-mechanic-confirmed-local-fauna-unresolved','Achatina Paste is an explicitly distinct substitute produced by snails; do not rename it Cementing Paste node loot',W+'Cementing_Paste_or_Achatina_Paste'))
  methods.append(method('creature-production','general-mechanic-confirmed-local-fauna-unresolved','Beelzebufo eating Meganeura/Titanomyrma converts insects into paste; local frog acquisition may require transfer',W+'Cementing_Paste'))
  if m not in ['scorched-earth','aberration','genesis-part-1-ocean']:methods.append(method('natural-cache','source-candidate-not-location-proof','Beaver dam loot can supply actual paste; local ASA dam regions must be filmed',W+'Castoroides'))
  else:warnings.append('No local beaver-dam absence conclusion made; no source currently establishes three dam regions on this plane. Craft/frog/snail methods remain separate.')
 if res=='Sap':
  details={'scorched-earth':'Joshua trees in Badlands/High Desert','aberration':'Sap taps on local redwood trees; tree-platform support is separate','extinction':'Desert biome Joshua trees near Desert Titan cave; Sunken Forest redwoods described as inaccessible','valguero':'Tree stumps/broken trees on small lake islands plus redwood taps','the-island':'Redwood sap taps','the-center':'Redwood sap taps','ragnarok':'Redwood sap taps near red obelisk'}
  if m in details:methods.append(method('plant-harvest-or-tap','primary-wiki-positive',details[m],W+'Sap'))
  if m=='extinction':methods.append(method('creature-production','primary-wiki-positive','A Gacha configured to produce Sap provides a distinct passive method',W+'Sap'))
  if m.startswith('genesis-part-1'):
   methods.append(method('purchase','primary-wiki-positive','HLN-A Hexagon Exchange sells Sap; purchase is not three geographic natural farms',W+'Sap'))
   if m=='genesis-part-1':methods.append(method('plant-harvest','primary-wiki-positive','Poisonous trees in Toxic Mire yield actual Sap, not Cactus/Crystalized Sap',W+'Toxic_Mire_(Genesis:_Part_1)'))
   else:methods.append(method('outside-plane-acquisition','primary-wiki-positive','Sap harvest documented in Toxic Mire bog; does not prove local ocean sap or transfer-only',W+'Toxic_Mire_(Genesis:_Part_1)'))
  warnings.append('Sap is distinct from Cactus Sap, Red Crystalized Sap and Blue Crystalized Sap; none prove plain Sap farm.')
 if res=='Giant Bee Honey':
  if m=='genesis-part-1-ocean':methods.append(method('outside-plane-acquisition','primary-wiki-positive','Honey documented in Canopy bog; local ASA ocean hives remain unknown, not absent',W+'Canopy_(Genesis:_Part_1)'))
  else:methods.append(method('hive-harvest-or-creature-production','primary-wiki-positive-or-creator-candidate','Wild hive harvest and domesticated queen hive production are separate from mineral nodes',W+'Giant_Bee'))
 if res in ['Rare Flowers','Rare Mushrooms']:
  methods.append(method('plant-harvest-or-natural-cache','general-mechanic-confirmed','Rare flowers from appropriate vegetation/dams; Rare Mushrooms from swamp roots/crystal drops/dams/mushroom vegetation depending map',W+'Gathering_and_Weight_Reduction'))
  if m=='genesis-part-1-ocean':methods.append(method('creature-production','primary-wiki-positive','Tamed Megachelon passively produces actual rare flowers and rare mushrooms; production farm is not three wild plant nodes',W+'Rare_Flower'))
 if res=='Black Pearls':
  if m=='scorched-earth':
   methods.append(method('creature-loot','ASA-patch-positive','ASA patch41.23 guarantees Alpha Deathworm75 BlackPearls; ordinary Deathworms and Phoenix are documented sources',W+'Deathworm','Explicit ASA changelog41.23'))
   warnings.append('Do not invent sea-floor BlackPearl clam nodes on Scorched. Published Deathworm page explicitly identifies Deathworm/Phoenix methods.')
  elif m=='extinction':methods.append(method('creature-loot-or-production','primary-wiki-positive','Large corrupted creatures/Gacha can supply actual BlackPearls; no natural-node presence asserted',W+'Black_Pearl'))
  elif m in ['the-island','the-center','genesis-part-1-ocean']:methods.append(method('creature-harvest','primary-wiki-positive','Eurypterid/Tusoteuthis/etc corpse loot, not proof of ground clams',W+'Black_Pearl'))
 if res=='Organic Polymer':
  methods.append(method('creature-harvest','general-mechanic-confirmed','Kairuku/Hesperornis/Mantis/Karkinos/other suitable corpses depending local spawns',W+'Polymer'))
  if m=='extinction':
   methods.append(method('creature-harvest','primary-wiki-positive','Mantis in Desert cave drop actual OrganicPolymer and Chitin; separate from corrupted creatures',W+'Mantis'))
   methods.append(method('craft-substitute','primary-wiki-positive','Corrupted Nodule is a distinct material from corrupted creature bodies, substituting Polymer/OrganicPolymer in eligible recipes',W+'Corrupted_Nodule'))
 if res=='Silica Pearls' and m=='extinction':
  methods.append(method('craft-substitute-natural-node','primary-wiki-positive','Silicate clumps in ForbiddenZone are distinct material, substitute only in eligible recipes',W+'Silicate'))
  methods.append(method('creature-production-or-urban-harvest','creator-candidate','Gacha and destructible city object yield methods require footage proving actual item identity; cannot infer no pearls from absent node marker',W+'Silica_Pearls'))
 if m=='genesis-part-1-ocean':warnings.append('Ocean is a Genesis1 subplane, not independent map. Wiki explicitly says ASA islands/biome heavily changed; ASE coordinates/omissions cannot establish current local absence.')
 if m=='astraeos':warnings.append('Current map has Feb25 and Aug27 2026 expansions; old coordinates need current correspondence, see astraeos-revision-audit.json')
 if m=='the-island':warnings.append('Wiki warns ASA full map/waypoint plane differs from mini-map/Tek/TPCoords; GPS display mode must be recorded')
 qmap={'lost-colony':'LostColony','genesis-part-1':'Genesis1','genesis-part-1-ocean':'Genesis1Ocean'}.get(m,m.title())
 creators=[{'videoId':s['videoId'],'publishedDate':s['publishedDate'],'title':s['title'],'proofStatus':s['proofStatus']} for s in queue if s['map']==qmap and res.replace(' ','') in s['resourceMentions']]
 direct=any(x['kind'] in ['natural-node','plant-harvest-or-tap','plant-harvest','creature-loot','creature-harvest'] and x['status'] not in ['general-mechanic-confirmed'] for x in methods)
 rows.append({'map':m,'resource':res,'methods':methods,'unknownLocalMethods':not direct and not r['verifiedDistinctSpots'],'transferOnly':'unconfirmed','wholeResourceAbsence':'not-established','naturalNodeAbsence':'not-established','priorAcceptedAsaSpotIds':r['spotIDs'],'priorFootageLimit':'From farming33 accepted coverage ledger; research agent did not re-review prior footage','freshMetadataCandidates':creators,'threeRegionPolicy':'Require three distinct filmed applicable harvest regions; craft/purchase/passive-production cannot be counted as invented natural nodes. If only nongeographic methods verified, report method and natural-location applicability unresolved.','warnings':warnings})
out={'schema':'farming34-applicability154-v1','checkedDate':'2026-10-08','rawPairs':len(rows),'confirmedWholeResourceAbsenceCount':0,'confirmedTransferOnlyCount':0,'principle':'No map-resource pair removed merely to improve coverage. No omission-based absence. Positive mixed-edition wiki mechanics plus footage candidates cannot be represented as current GPS proof.','rows':rows}
(P/'map-resource-applicability-154.json').write_text(json.dumps(out,indent=2));print('rows',len(rows),'unknownlocal',sum(r['unknownLocalMethods'] for r in rows),'absence0')
