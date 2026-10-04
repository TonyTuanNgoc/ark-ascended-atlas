"""Read ASA item recipes and source size notes; never infer an exact game mesh bound."""
import json,re,subprocess,hashlib,concurrent.futures
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'native/Ascended/Resources';cache=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/build-research');cache.mkdir(exist_ok=True)
def fetch(url,path):
 if not path.exists():
  out=subprocess.run(['curl','-fLs','--max-time','40',url],capture_output=True)
  if out.returncode==0:path.write_bytes(out.stdout)
 return path.read_text() if path.exists() else ''
def flight(s):
 vals=[]
 for m in re.finditer(r'<script>self\.__next_f\.push\((.*?)\)</script>',s):
  try:
   v=json.loads(m[1]);vals.append(v[1] if len(v)>1 and isinstance(v[1],str) else '')
  except (ValueError,TypeError):pass
 return ''.join(vals)
s=flight(Path('/tmp/asa-items.html').read_text());i=s.index('"items":')+8;items=json.JSONDecoder().raw_decode(s[i:])[0];bySlug={a['slug']:a for a in items}
catalog=json.loads((R/'equipment-library.json').read_text())['items']
def source_slug(item):
 key=item['id']
 original=key
 if original in bySlug:return original
 key=key.replace('wooden-','wood-').replace('-dinosaur-','-')
 if key.startswith('large-'):
  bits=key.split('-');key=bits[1]+'-large-'+ '-'.join(bits[2:])
 if key.startswith('behemoth-'):
  bits=key.split('-');key=bits[1]+'-behemoth-'+ '-'.join(bits[2:])
 if key.startswith('sloped-') and (key.endswith('-left') or key.endswith('-right')):
  key=key.split('-')[1]+'-sloped-wall'
 aliasesExtra={'reinforced-gate':'stone-reinforced-gate','reinforced-double-door':'stone-reinforced-doors-windows','reinforced-window':'stone-reinforced-doors-windows','reinforced-behemoth-gate':'stone-reinforced-behemoth-gate','stone-behemoth-gateway':'stone-behemoth-gateway','dinosaur-gate':'wood-gate','dinosaur-gateway':'wood-gateway','cloning-chamber':'tek-cloning-chamber','large-storage-box':'large-storage-box-bookshelf','metal-irrigation-pipe-intake':'metal-water-intake','metal-irrigation-pipe-tap':'metal-water-tap','stone-irrigation-pipe-intake':'stone-water-intake','stone-irrigation-pipe-tap':'stone-water-tap','metal-water-reservoir':'metal-water-tank','hide-sleeping-bag':'sleeping-bag','sloped-greenhouse-roof':'greenhouse-roof','sloped-wood-roof':'wood-roof-ramp-stairs','sloped-thatch-roof':'thatch-roof-ramp-stairs','battlerig':'craft-battlerig','frontier-lamp':'frontier-lamps','pet-display':'pet-displays','homing-underwater-mine':'underwater-mine','vacuum-compartment':'vacuum-compartment-moonpool','tek-thalassian-hoversail':'tek-hoversail'}
 key=aliasesExtra.get(key,aliasesExtra.get(original,key))
 if key in bySlug:return key
 # ASA combines wall/door/ceiling variants into an engram; matched family only.
 aliases={'power-generator':'electrical-generator','fireplace':'stone-fireplace','stone-doorframe':'stone-wall-doorways-windowframe','reinforced-wooden-door':'stone-reinforced-doors-windows'}
 alias=aliases.get(original,aliases.get(key))
 if alias in bySlug:return alias
 for material in ['stone','wood','wooden','metal','adobe','tek','greenhouse','thatch']:
  prefix=material+'-'
  if key.startswith(prefix):
   tail=key[len(prefix):]
   candidates={'wall':'wall','doorframe':'wall','double-doorframe':'wall','windowframe':'wall','ceiling':'ceiling-hatchframe','hatchframe':'ceiling-hatchframe','railing':'quarter-wall-railing','quarter-wall':'quarter-wall-railing','triangle-ceiling':'quarter-triangle-ceiling','triangle-foundation':'triangle-quarter-foundation','stairs':'roof-ramp-stairs','ramp':'roof-ramp-stairs','sloped-roof':'roof-ramp-stairs','door':'doors-window','double-door':'doors-window','window':'doors-window','fence-foundation':'fence-foundation-support','fence-support':'fence-foundation-support','triangle-roof':'triangle-roof-corner','sign':'sign-wall-sign','wall-sign':'sign-wall-sign'}
   token=candidates.get(tail)
   if token:
    possible=[k for k in bySlug if k.startswith(prefix+token)]
    if len(possible)==1:return possible[0]
 return None
slugs=sorted({v for item in catalog if item['category'] in ['structures','machines','tools','resources'] and (v:=source_slug(item))})
# Include craft intermediates even when outside original catalogue.
slugs=sorted(set(slugs)|{'metal-ingot','cementing-paste','sparkpowder','gunpowder','polymer','electronics','gasoline','clay'})
def read(slug):
 url='https://wikily.gg/ark-survival-ascended/items/'+slug+'/'
 text=fetch(url,cache/(slug+'.html'));f=flight(text)
 try:
  j=f.index('"requirements":')+15;requirements=json.JSONDecoder().raw_decode(f[j:])[0]
  k=f.index('"craftableIn":',j)+14;stations=json.JSONDecoder().raw_decode(f[k:])[0]
  return slug,{'ingredients':{v['resource_name']:v['count'] for v in requirements},'stations':stations,'sourceURL':url,'sourceSHA256':hashlib.sha256(text.encode()).hexdigest()}
 except (ValueError,KeyError):return slug,None
recipes={}
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for n,(slug,row) in enumerate(pool.map(read,slugs)):
  if row:recipes[slug]=row
  if n%40==0:print(n,len(slugs),len(recipes),flush=True)
records=[]
for item in catalog:
 slug=source_slug(item)
 row={'id':item['id'],'name':item['name'],'category':item['category'],'asset':item.get('asset'),'ingredients':{},'stations':[],'recipeVerified':False,'sizeStatus':'unmeasured','sourceURL':item.get('sourceURL','')}
 if 'staircase' not in item['id'] and not item['id'].endswith('trapdoor') and item['id'] not in ['behemoth-gate','behemoth-gateway'] and slug in recipes and all(isinstance(v,int) and v>0 for v in recipes[slug]['ingredients'].values()):row.update(recipes[slug]);row['recipeVerified']=True
 records.append(row)
# Standalone standard processing recipes: output count matters (sparkpowder yields2, gasoline5).
processes=[('Metal Ingot',1,{'Metal':2},'Refining Forge'),('Cementing Paste',1,{'Chitin or Keratin':4,'Stone':8},'Mortar and Pestle'),('Sparkpowder',2,{'Flint':2,'Stone':1},'Mortar and Pestle'),('Gunpowder',1,{'Charcoal':1,'Sparkpowder':1},'Mortar and Pestle'),('Polymer',1,{'Obsidian':2,'Cementing Paste':2},'Fabricator'),('Electronics',1,{'Silica Pearls':3,'Metal Ingot':1},'Fabricator'),('Gasoline',5,{'Hide':5,'Oil':6},'Refining Forge'),('Clay',1,{'Sand':2,'Cactus Sap':1},'Mortar and Pestle'),('Charcoal',1,{'Wood':1},'Campfire')]
processRows=[]
for name,output,ingredients,station in processes:
 slug=name.lower().replace(' ','-');found=recipes.get(slug)
 # Keep individually reviewed standard batch recipe; ASA source retained for comparison.
 processRows.append({'name':name,'output':output,'ingredients':ingredients,'station':station,'sourceURL':'https://ark.wiki.gg/wiki/'+name.replace(' ','_'),'asaSourceURL':(found or {}).get('sourceURL'),'variant':'standard process; no Chemistry Bench discount or fuel included'})
(R/'build-crafting.json').write_text(json.dumps({'items':records,'processes':processRows},ensure_ascii=False,separators=(',',':'))+'\n')
print('DONE',len(records),'verified',sum(x['recipeVerified'] for x in records),'source recipes',len(recipes),flush=True)
