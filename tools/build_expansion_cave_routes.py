"""Build navigable cards from source-confirmed ASA entrance records, not cave centers."""
import json,re,html
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'native/Ascended/Resources';catalogPath=R/'map-reference-locations.json';catalog=json.loads(catalogPath.read_text());CACHE=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/reference-locations-20261005')
VIDEO={'scorched-earth':{'crag':('RP7bA_veAYc',50),'gatekeeper':('RP7bA_veAYc',121),'destroyer':('RP7bA_veAYc',182)}}
for mapID in ['scorched-earth','aberration','lost-colony','astraeos']:
 data=json.loads((R/(mapID+'-exploration.json')).read_text());refs=[x for x in catalog['locations'] if x['mapID']==mapID and x['kind']=='caveEntrance'];source=json.loads((CACHE/(mapID+'-wiki-asa-markers.json')).read_text());routes=[]
 for ref,entry in zip(refs,source['markers']['cave-entrance']):
  rid=ref['id'];ref['routeID']=rid;desc=entry[2].get('desc','');artifactIDs=list(dict.fromkeys(re.sub('[^a-z0-9]+','-',html.unescape(a).lower()).strip('-') for a in re.findall('title="Artifact of the ([^"<]+)"',desc)));ref['artifactIDs']=artifactIDs
  availableIDs={a['id'] for a in data['artifacts']};artifactIDs=[a for a in artifactIDs if a in availableIDs]
  for a in data['artifacts']:
   if a['id'] in artifactIDs:a['routeID']=rid
  photo=ref.get('imageAsset');video=VIDEO.get(mapID,{}).get(ref.get('artifactID'));videoURL=('https://www.youtube.com/watch?v='+video[0]+'&t='+str(video[1])+'s') if video else ('https://www.youtube.com/watch?v=IzKTaVjnciA' if mapID=='aberration' and 'Surface entrance' in ref['name'] else None)
  ref['walkthroughURL']=videoURL;ref['walkthroughStatus']='externalLinkOnly' if videoURL else 'notRetrieved'
  note='Match the opening to the surrounding terrain. Artifact pickup coordinates mark a different point deeper inside. '
  note+='Offline walkthrough unavailable.'
  if not photo:note+=' Terrain overview shown.'
  routes.append(dict(id=rid,name=ref['name'],artifactIDs=artifactIDs,entrances=[dict(id=rid,label='Entrance',lat=ref['lat'],lon=ref['lon'],kind='entrance')],boss='',notes=note,kit=['Food and water','Spare armor and healing supplies','Weapons and ammunition','Light source; identify a return route'],sourceURL=ref['source']['url'],entranceSourceURL=ref['source']['dataURL'],imageAsset=photo or 'Map-'+mapID,imageCaption='ASA Wiki source entrance photograph.' if photo else 'Map terrain overview; entrance photograph has not been downloaded.',photoURL=ref.get('photoURL'),videoURL=videoURL,walkthroughStatus=ref['walkthroughStatus']))
 data['reviewedAt']='05/10/2026';data['routes']=routes;(R/(mapID+'-exploration.json')).write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n');print(mapID,len(routes),'routes')
catalogPath.write_text(json.dumps(catalog,indent=2,ensure_ascii=False)+'\n')
