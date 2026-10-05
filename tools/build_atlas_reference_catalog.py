"""Reproduce source-only ASA references. Never infer entrances from cave actors."""
import hashlib, html, json, re, collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
CACHE=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/reference-locations-20261005')
IDS={'the-island':22,'ragnarok':14,'the-center':21,'scorched-earth':16,'aberration':1,'extinction':8,'lost-colony':12,'genesis-part-1':26,'genesis-part-1-ocean':27,'valguero':24,'astraeos':6}
ROUTES={'Central Cave':'central','North West Cave':'north-west','Lower South Cave':'lower-south','North East Cave':'north-east','Upper South Cave':'upper-south','South East Cave':'lava','Swamp Cave':'swamp','Snow Cave':'snow','The Caverns of Lost Faith':'lost-faith','The Caverns of Lost Hope':'lost-hope','Tek Cave':'tek'}
def slug(s):return re.sub(r'[^a-z0-9]+','-',s.lower()).strip('-')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
locations=[];coverage=[]
for mapID,mapSourceID in IDS.items():
 wiki=CACHE/(mapID+'-wiki-asa-markers.json');hasWiki=wiki.exists();points=[]
 if hasWiki:
  d=json.loads(wiki.read_text())
  for group,entries in d['markers'].items():
   labelCounts=collections.Counter(e[2].get('label','') if len(e)>2 else '' for e in entries)
   for index,entry in enumerate(entries):
    lat,lon=entry[:2];meta=entry[2] if len(entry)>2 else {};name=meta.get('label') or d['configuration']['groups'][group]['name'];kind='caveEntrance' if group=='cave-entrance' else 'obelisk' if group.startswith('obelisk-') else 'terminal'
    if kind=='caveEntrance' and not meta.get('label'):name='Underwater Cave Entrance'
    artifacts=re.findall(r'title="Artifact of the ([^"<]+)"',meta.get('desc',''));artifact=slug(html.unescape(artifacts[0])) if artifacts else None
    ident='reference-'+mapID+'-'+slug(name)+('-'+str(index+1) if 'Underwater Cave' in name or 'Surface' in name or labelCounts.get(name,0)>1 else '')
    p=dict(id=ident,mapID=mapID,name=name,lat=lat,lon=lon,kind=kind,granularity='entrance' if kind=='caveEntrance' else 'terminal',verification='asaSourceConfirmed',coordinatePlane='asaWikiAtlas',geometryStatus='insideAtlas' if 0<=lat<=100 and 0<=lon<=100 else 'outsideAtlas',note='ASA Wiki entrance reference; identify the opening using terrain.' if kind=='caveEntrance' else 'ASA Wiki terminal reference. Arena coordinates are separate from summon points.',routeID=ROUTES.get(name) if mapID=='the-island' else None,artifactID=artifact,bossIDs={'rockwell-terminal':['rockwell'],'lost-colony-terminal':['lost-king','lost-queen'],'minotaur-terminal':['minotarchos'],'abyssanthos-terminal':['abyssalus'],'kalydonios-terminal':['kalydonios','erymanthian'],'colossus-terminal':['colossus'],'kroaratos-terminal':['kroaratos'],'shallocis-terminal':['shallocis']}.get(group,[]) if group.endswith('terminal') else ['overseer'] if name=='Tek Cave' else [],color=group.split('-')[1] if group.startswith('obelisk-') else None,source=dict(url=d['sourceURL'],dataURL=d['requests'][0]['url'],revisionID=d['revisionID'],cacheSHA256=digest(wiki),sourceKind='asaWikiDataMap'))
    if meta.get('image'):
     p['photoURL']='https://ark.wiki.gg'+meta['image'][0];p['photoStatus']='sourceReferenceOnly'
    points.append(p)
 # Source actors are terminals, never entrance proxies. Retain explicit outside-plane points.
 if not hasWiki:
  f=CACHE/(mapID+'-obelisks.json')
  for i,a in enumerate(json.loads(f.read_text())):
   name=a['name'];lat=a['lat'];lon=a['lon'];kind='obelisk' if name.endswith('Obelisk') else 'terminal'
   points.append(dict(id='reference-'+mapID+'-'+slug(name)+'-'+str(i+1),mapID=mapID,name=name if kind=='obelisk' else name+' '+str(i+1),lat=lat,lon=lon,kind=kind,granularity='actorTerminal',verification='asaSourceConfirmed',coordinatePlane='wikilyAtlas',geometryStatus='insideAtlas' if 0<=lat<=100 and 0<=lon<=100 else 'outsideAtlas',note='ASA extracted terminal actor. Color, boss association and arena approach are not identified by this source.' if kind=='terminal' else 'ASA extracted obelisk actor; summon point, not arena coordinates.',bossIDs=[],source=dict(url='https://wikily.gg/ark-survival-ascended/maps/'+('genesis' if mapID.startswith('genesis') else mapID)+'/',dataURL='https://wikily.gg/api/ark/maps/v2/layer-data/?mapId='+str(mapSourceID)+'&layer=obelisks',cacheSHA256=digest(f),sourceKind='asaExtractedActor')))
 if mapID=='extinction':
  f=CACHE/(mapID+'-artifacts.json')
  for a in json.loads(f.read_text()):
   if a['lat']<0 or a['lat']>100 or a['lon']<0 or a['lon']>100:
    points.append(dict(id='reference-extinction-artifact-'+slug(a['name']),mapID=mapID,name=a['name'],lat=a['lat'],lon=a['lon'],kind='artifactSite',granularity='actorSite',verification='asaSourceConfirmed',coordinatePlane='wikilyAtlas',geometryStatus='outsideAtlas',note='Source actor lies outside the 0–100 atlas plane. Retained without clamping; a calibrated extended plane is required.',artifactID=slug(re.sub(r'^Artifact of (?:the )?', '', a['name'])),bossIDs=[],source=dict(url='https://wikily.gg/ark-survival-ascended/maps/extinction/',dataURL='https://wikily.gg/api/ark/maps/v2/layer-data/?mapId=8&layer=artifacts',cacheSHA256=digest(f),sourceKind='asaExtractedActor')))
 locations+=points
 caveCount=sum(p['kind']=='caveEntrance' for p in points)
 coverage.append(dict(mapID=mapID,sourceMapID=mapSourceID,entranceCount=caveCount,terminalCount=sum(p['kind'] in ('obelisk','terminal') for p in points),status='partial',limitations=[] if caveCount else ['No independently retrieved ASA entrance coordinates in this addition. Cave actor centers are excluded.'],videoGPSStatus='notVerified'))
 if mapID in ['lost-colony','astraeos'] and not hasWiki:coverage[-1]['limitations'].append('ASA Wiki DataMap configuration retrieved, but marker API returned rate limiting (HTTP 429). Generic extracted terminals retain their source names.')
 if mapID=='astraeos':coverage[-1]['limitations'].append('Wiki terminal coordinates match the unflipped source atlas orientation at shared obelisks. Shallocis remains outside longitude 100; no latitude inversion is assumed.')
 if mapID=='extinction':coverage[-1]['limitations'].append('Several terminal actors and Artifact of the Chaos are outside 0–100; no normalized-plane pin is emitted.')
 if mapID.startswith('genesis'):coverage[-1]['limitations'].append('The source terminal layer is empty. Mission/HLN-A initiation is not represented as invented static GPS pins.')
result=dict(schemaVersion=1,acquiredAt='2026-10-05',coordinateDisclosure='Coordinates are ASA source atlas references, not independently calibrated in-game GPS readings. Cave centers and legacy Evolved coordinates are excluded.',locations=locations,coverage=coverage)
existing=ROOT/'native/Ascended/Resources/map-reference-locations.json'
if existing.exists():
 old={x['id']:x for x in json.loads(existing.read_text())['locations']}
 for point in locations:
  for key in ('imageAsset','photoStatus','photoSHA256','routeID','artifactIDs','walkthroughURL','walkthroughStatus'):
   if key in old.get(point['id'],{}) and old[point['id']].get('photoURL') == point.get('photoURL'):point[key]=old[point['id']][key]
(ROOT/'native/Ascended/Resources/map-reference-locations.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
print(len(locations),'references',sum(p['kind']=='caveEntrance' for p in locations),'entrances')
