"""Integrate separately reviewed filmed regions; preserve coverage and older evidence."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
RES=ROOT/'native/Ascended/Resources'
def read(p):return json.loads(p.read_text())
def write(p,j):p.write_text(json.dumps(j,indent=2,ensure_ascii=False)+'\n')
a=read(ROOT/'tools/evidence/farming26-additions.json')
c=read(RES/'verified-resource-spots.json');g=read(RES/'resource-guides.json')
for key,doc,rows in [('id',c['spots'],a['spots']),('spotID',g['guides'],a['guides'])]:
 byid={r[key]:r for r in doc}
 for row in rows:byid[row[key]]=row
 doc[:]=list(byid.values())
for row in c['coverage']:
 matches=[s['id'] for s in c['spots'] if s['verified'] and s['map']==row['map'] and row['resource'] in s['resources']]
 if matches:
  row['spotIDs']=matches
  row['status']='verified'
  row['evidenceState']='filmed-region-verified'
for row in g.get('coverage',[]):
 row['verifiedRegions']=sum(s['map']==row['map'] for s in g['guides'])
write(RES/'verified-resource-spots.json',c);write(RES/'resource-guides.json',g)
print({'spots':len(c['spots']),'guides':len(g['guides'])})
