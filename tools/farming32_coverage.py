"""Audit the user's 14-resource / every-map / three distinct filmed spots target."""
import json, collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
RES=ROOT/'native/Ascended/Resources'
MAPS=['ragnarok','the-island','the-center','scorched-earth','aberration','extinction','lost-colony','genesis-part-1','genesis-part-1-ocean','valguero','astraeos']
RESOURCES=['Black Pearls','Cementing Paste','Chitin','Crystal','Giant Bee Honey','Metal','Obsidian','Oil','Organic Polymer','Rare Flowers','Rare Mushrooms','Rich Metal','Sap','Silica Pearls']

def coverage():
    spots=json.loads((RES/'verified-resource-spots.json').read_text())['spots']
    guides={g['spotID']:g for g in json.loads((RES/'resource-guides.json').read_text())['guides']}
    rows=[]
    for map_id in MAPS:
        for resource in RESOURCES:
            matches=[s for s in spots if s['verified'] and s['map']==map_id and resource in s['resources']]
            # Nearby distinct videos of the same waypoint never count as multiple places.
            distinct=[]
            for s in matches:
                if not any(abs(s['lat']-o['lat'])<.05 and abs(s['lon']-o['lon'])<.05 for o in distinct): distinct.append(s)
            filmed=[s for s in distinct if s['id'] in guides and len(guides[s['id']]['steps'])==1 and all((RES/'ResourceClips'/(guides[s['id']]['steps'][0][k]+ext)).is_file() for k,ext in [('loop','.mp4'),('poster','.jpg')])]
            rows.append(dict(map=map_id,resource=resource,target=3,verifiedDistinctSpots=len(filmed),spotIDs=[s['id'] for s in filmed],missingToTarget=max(0,3-len(filmed)),status='target-met' if len(filmed)>=3 else 'needs-source-footage',absenceClaim=False))
    return dict(schemaVersion=1,reviewedAt='2026-10-08',target='At least 3 independently located source-filmed farming spots for every user-curated resource on every applicable map',maps=len(MAPS),resources=len(RESOURCES),mapResourcePairs=len(rows),targetMet=sum(r['status']=='target-met' for r in rows),verifiedSpots=len(spots),remainingSpots=sum(r['missingToTarget'] for r in rows),rows=rows,limitations=['A zero count means no verified bundled footage, not proven absence of this resource on this map.','Source film waypoints identify farming regions, not permanent individual actors.','Creature drops and tame production need actual acquisition evidence; nearby mineral footage cannot establish them.'])
if __name__=='__main__':
    output=coverage();(ROOT/'tools/evidence/farming32/coverage.json').write_text(json.dumps(output,indent=2)+'\n');print({k:v for k,v in output.items() if k not in ('rows','limitations')})
