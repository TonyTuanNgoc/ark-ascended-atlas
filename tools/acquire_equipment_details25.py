"""Acquire structured factual item details, with explicit ASA/ASE edition boundaries.
Only writes equipment-details.json and the equipment25 source audit. HTML remains
in an external research cache; no article prose is redistributed. Standard-library only.
"""
import argparse, concurrent.futures, hashlib, html, json, re, subprocess
from collections import Counter
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / 'native/Ascended/Resources'
CACHE = Path('/Volumes/TONY SSD/ASCENDED_MEDIA/equipment25-wiki')
CHECKED = datetime.now(timezone.utc).isoformat(timespec='seconds')
VOID = {'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'}
class Node:
 def __init__(self, tag='', attrs=()): self.tag=tag; self.attrs=dict(attrs); self.children=[]
 def text(self): return re.sub(r'\s+',' ',''.join(c.text() if isinstance(c,Node) else c for c in self.children).replace('\u00ad','')).strip()
 def walk(self):
  yield self
  for c in self.children:
   if isinstance(c,Node): yield from c.walk()
 def has(self, token): return token in self.attrs.get('class','').split()
class Parser(HTMLParser):
 def __init__(self): super().__init__(convert_charrefs=True); self.root=Node(); self.stack=[self.root]
 def handle_starttag(self,tag,attrs):
  n=Node(tag,attrs);self.stack[-1].children.append(n)
  if tag not in VOID:self.stack.append(n)
 def handle_endtag(self,tag):
  for i in range(len(self.stack)-1,0,-1):
   if self.stack[i].tag==tag:del self.stack[i:];break
 def handle_data(self,data):self.stack[-1].children.append(data)
def slug(s):return re.sub(r'[^a-z0-9]+','-',s.lower()).strip('-')
def field_text(node):
 def render(n):
  if not isinstance(n,Node):return n
  if n.tag=='br':return '; '
  if n.tag=='img':
   return {'ARK: Survival Ascended':' (ASA) ', 'ARK: Survival Evolved':' (ASE) '}.get(n.attrs.get('alt',''),'')
  value=''.join(render(c) for c in n.children)
  return value+('; ' if n.tag=='li' else '')
 return re.sub(r'\s+',' ',render(node).replace('\u00ad','')).strip(' ;')
def parse(raw):
 p=Parser();p.feed(raw);boxes=[n for n in p.root.walk() if n.has('info-framework')]
 stats=[];recipes=[];stations=[];out=None
 labels={'Weight':'weight','Stack size':'stackSize','Durability':'durability','Required level':'requiredLevel','Engram points':'engramPoints','Melee damage':'meleeDamage','Ranged damage':'rangedDamage','Armor rating':'armor','Armor':'armor','Health':'health','Hypothermal insulation':'hypothermalInsulation','Hyperthermal insulation':'hyperthermalInsulation','Storage slots':'storageSlots','Water capacity':'waterCapacity','Spoils in':'spoilTime','Food':'food','Water':'water','Crafting time':'craftingTime','Crafting XP':'craftingXP','Item slots':'storageSlots','Cold protection':'coldProtection','Heat protection':'heatProtection','Explosive damage':'explosiveDamage','Magazine size':'magazineSize','Reload time':'reloadTime','Rate of fire':'rateOfFire','DPS':'damagePerSecond','Ammo used':'ammoUsed','Fuel':'fuel','Induced Torpor':'inducedTorpor','Torpidity':'torpidity','Stamina':'stamina','Renewable':'renewable','Refineable':'refineable','Combustible':'combustible','Decay time':'decayTime','Decomposes in':'decomposeTime'}
 for box in boxes:
  for row in box.walk():
   if not row.has('info-unit-row'):continue
   left=next((n for n in row.walk() if n.has('info-arkitex-left')),None);right=next((n for n in row.walk() if n.has('info-arkitex-right')),None)
   if left is None or right is None:continue
   label=left.text();value=field_text(right)
   if label in labels and value and len(value)<240:
    datum={'key':labels[label],'label':label,'value':value}
    if datum not in stats:stats.append(datum)
   if label=='Crafted in':
    names=[n.text().strip() for n in right.walk() if n.tag=='a' and not n.attrs.get('href','').startswith('/wiki/File:') and n.text().strip()]
    stations.extend(names or [value])
   if label in ('Crafting yields','Produces'):
    m=re.search(r'\d+',value)
    if m:out=int(m[0])
  for module in box.walk():
   if not module.has('info-module'):continue
   captionNode=next((n for n in module.walk() if n.has('info-unit-caption')),None)
   caption=captionNode.text() if captionNode else ''
   editions=[n.attrs.get('alt','') for n in captionNode.walk() if n.tag=='img'] if captionNode else []
   edition='ASA' if 'ARK: Survival Ascended' in editions else ('ASE' if 'ARK: Survival Evolved' in editions else 'mixed-or-unspecified')
   if not caption.startswith('Ingredients'):continue
   ing={}
   for n in module.walk():
    if n.tag!='b':continue
    m=re.match(r'^([\d,]+)\s*[×x]\s*(.+)$',n.text())
    if m:ing[m[2].strip()]=int(m[1].replace(',',''))
   if ing:recipes.append({'label':caption,'edition':edition,'ingredients':ing})
 return stats,recipes,list(dict.fromkeys(stations)),out,len(boxes)
def canonical(ingredients):
 return {k.split(' or ')[0].split(',')[0].replace('Organic Polymer','Polymer').replace('Achatina Paste','Cementing Paste'):v for k,v in ingredients.items()}
def alternatives(name):
 return {x.strip().lower() for x in re.split(r',\s*|\s+or\s+|/',name) if x.strip()}
def comparable(a,b,ratio=1):
 if len(a)!=len(b):return False
 remaining=list(b.items())
 for name,amount in a.items():
  i=next((i for i,(other,count) in enumerate(remaining) if alternatives(name)&alternatives(other) and count==amount*ratio),None)
  if i is None:return False
  remaining.pop(i)
 return True
def flight(raw):
 parts=[]
 for m in re.finditer(r'<script>self\.__next_f\.push\((.*?)\)</script>',raw):
  try:
   v=json.loads(m[1]);parts.append(v[1] if len(v)>1 and isinstance(v[1],str) else '')
  except (ValueError,TypeError):pass
 return ''.join(parts)
def asa_extra(item):
 # Exact slug only: family alias matching belongs to existing reviewed build-crafting.
 f=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/build-research')/(item['id']+'.html')
 if not f.exists():return None
 raw=f.read_text();s=flight(raw);i=s.find('"requirements":')
 if i<0:return None
 try:
  req=json.JSONDecoder().raw_decode(s[i+15:])[0];j=s.find('"craftableIn":',i)
  stations=json.JSONDecoder().raw_decode(s[j+14:])[0] if j>=0 else []
  if not req or not all(isinstance(x['count'],int) and x['count']>0 for x in req):return None
  return {'ingredients':{x['resource_name']:x['count'] for x in req},'stations':stations,'sourceURL':'https://wikily.gg/ark-survival-ascended/items/'+item['id']+'/', 'sourceSHA256':hashlib.sha256(raw.encode()).hexdigest()}
 except (ValueError,KeyError,TypeError):return None
def secondary_identity(source_url):
 path=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/build-research')/(source_url.rstrip('/').split('/')[-1]+'.html')
 if not path.exists():return {}
 raw=path.read_text();s=flight(raw);result={}
 for field in ['itemName','blueprintPath','fullname']:
  match=re.search('"'+field+'":"([^\"]+)"',s)
  if match:result[field]=match[1]
 match=re.search(r'"image":\["([^\"]+)"',raw)
 if match:result['imageURL']=match[1]
 return result
def acquire(item, existing, refresh):
 requested=item['sourceURL'];url='https://ark.wiki.gg/wiki/Charcoal' if item['id']=='wood-coal' else requested;path=CACHE/(item['id']+'.html');raw='';mode='unavailable';error=''
 if path.exists() and not refresh:raw=path.read_text();mode='cached-primary'
 else:
  p=subprocess.run(['curl','-fLsS','--max-time','18','--user-agent','AscendedPersonalFieldGuide/1.0',url],capture_output=True)
  if p.returncode==0 and b'info-framework' in p.stdout:raw=p.stdout.decode('utf-8');path.write_text(raw);mode='live-primary'
  else:error=p.stderr.decode()[:180] or 'No item infobox in response'
 stats,variants,stations,output,boxes=parse(raw) if raw else ([],[],[],None,0)
 base=existing.get(item['id']);asa=base if base and base.get('recipeVerified') and base.get('ingredients') else asa_extra(item)
 row={'id':item['id'],'name':item['name'],'category':item['category'],'ingredients':{},'stations':[],'stats':stats,'sourceURL':url,'checkedAt':CHECKED,'primaryPageStatus':mode,'recipeStatus':'unresolved','statsStatus':'wiki-reference-edition-review' if stats else 'unresolved','editionNote':'Wiki pages may mix ASE and ASA. Base stats are reference values; item quality and server settings can change values.','recipeVariants':variants}
 if raw:
  row['sourceSHA256']=hashlib.sha256(raw.encode()).hexdigest();row['primaryRetrievedAt']=datetime.fromtimestamp(path.stat().st_mtime,timezone.utc).isoformat(timespec='seconds')
 if url!=requested:row['requestedSourceURL']=requested;row['editionNote']+=' Legacy catalogue alias Wood Coal resolves to the Charcoal primary page.'
 if error:row['sourceError']=error
 if asa:
  row.update(ingredients=asa['ingredients'],stations=asa['stations'],recipeSourceURL=asa['sourceURL'],asaSourceSHA256=asa.get('sourceSHA256',''))
  match=any(comparable(asa['ingredients'],v['ingredients']) for v in variants)
  row['recipeStatus']='asa-cache-wiki-crosschecked' if match else ('asa-cache-wiki-difference' if variants else 'asa-cache-reference')
  row['comparisonKind']='matching-ingredient-options-and-amounts' if match else ('quantity-or-resource-difference' if variants else 'no-primary-ingredient-candidate')
  if not match and any(comparable(asa['ingredients'],v['ingredients'],4) for v in variants):
   row['comparisonKind']='chemistry-bench-four-times-input-batch'
   row['editionNote']+=' Wiki ingredients reflect the larger Chemistry Bench input batch; retained source uses base-batch inputs.'
  row['editionNote']+=' Recipe retained from the ASA-specific source; Wiki alternatives do not overwrite it.'
 elif any(v['edition']=='ASA' for v in variants):
  selected=next(v for v in variants if v['edition']=='ASA')
  row.update(ingredients=selected['ingredients'],stations=stations,recipeSourceURL=url,recipeStatus='wiki-asa-explicit')
  row['editionNote']+=' Ingredient section explicitly marked ASA; station list may include mixed-edition alternatives.'
 elif len(variants)==1:
  row.update(ingredients=variants[0]['ingredients'],stations=stations,recipeSourceURL=url,recipeStatus='wiki-reference-edition-review')
 elif len(variants)>1:
  row.update(ingredients=variants[0]['ingredients'],stations=stations,recipeSourceURL=url,recipeStatus='wiki-multiple-variants-review')
  row['editionNote']+=' First listed ingredient variant shown; review variant-specific stations and output before batch crafting.'
 elif raw:row['recipeStatus']='no-infobox-recipe'
 if output is not None and len(variants)==1:
  row['output']=output;row['outputStatus']='wiki-reference-batch-review'
 elif output is not None:row['wikiInfoboxOutput']=output
 purposes={'metal-pick':'Harvest Metal and Flint from rocks; favor Thatch from trees and meat from bodies.', 'metal-hatchet':'Harvest Stone from rocks; favor Wood from trees and Hide from bodies.'}
 purposes.update({'chemistry-bench':'Craft chemical recipes in batches; check power and fuel requirements in the current game/server.', 'fabricator':'In ASA, a nearby Generator can power the Fabricator without fuel placed directly in it.', 'tek-replicator':'In ASA, power the Tek Replicator with a Tek Generator to use Element efficiently.'})
 if item['id'] in purposes:row['purpose']=purposes[item['id']];row['purposeSourceURL']=url
 row['stationStatus']='asa-secondary-cache-reference' if asa else 'wiki-mixed-edition-station-review'
 if item['id']=='cryofridge':row['editionNote']+=' Selected amounts match the explicitly marked ASA Wiki section: 12 Crystal, 7 Electronics, 115 Metal Ingot, 30 Polymer.'
 if item['id']=='cryopod':row['stationStatus']='wiki-mixed-edition-station-review';row['editionNote']+=' ASA ingredients are explicit; crafted-in stations are a mixed-edition list and require in-game confirmation.'
 if item['id']=='chemistry-bench':
  row['operationStatus']='edition-conflict-review';row['operationSources']=[url,'https://ark.wiki.gg/wiki/Charge_Battery']
  row['editionNote']+=' Wiki Chemistry Bench and Charge Battery pages list gasoline plus power, without explicit ASA scope. The prior electricity-only ASA purpose is not verified.'
 if item['id']=='fabricator':row['editionNote']+=' Wiki prose explicitly identifies nearby Generator power as an ASA option.'
 if item['id']=='tek-replicator':row['editionNote']+=' Wiki prose explicitly identifies Tek Generator power as an ASA option; generic Element fuel infobox is incomplete for ASA.'
 if item['id']=='explosive-arrow':
  row.update(stats=[],statsStatus='unresolved',recipeVariants=[],recipeStatus='asa-cache-reference',primaryPageStatus='source-parent-mismatch',comparisonKind='parent-page-is-tek-bow')
  row.pop('output',None);row.pop('outputStatus',None)
  row['editionNote']+=' Source URL redirects to the Tek Bow parent page. Bow ingredients and stats are excluded from this arrow; retained arrow recipe is secondary ASA evidence only.'
 if asa:row['secondaryIdentity']=secondary_identity(asa['sourceURL'])
 if item['id'] in ('water-reservoir','tek-thalassian-hoversail','absorbent-substrate','mutagen','mutagel'):
  row['rejectedSecondaryRecipe']={'ingredients':row['ingredients'],'stations':row['stations'],'sourceURL':row.get('recipeSourceURL'),'identity':row.get('secondaryIdentity',{})}
  row['editionNote']=row['editionNote'].replace('Recipe retained from the ASA-specific source; Wiki alternatives do not overwrite it.', 'Secondary extraction recorded for comparison; selected primary recipe uses the reviewed correction.').replace('Wiki ingredients reflect the larger Chemistry Bench input batch; retained source uses base-batch inputs.', 'Secondary raw class input costs differ from the actual Chemistry Bench batch.')
  row.update(ingredients=variants[0]['ingredients'],stations=stations,recipeSourceURL=url,recipeStatus='wiki-reference-edition-review',stationStatus='wiki-mixed-edition-station-review')
  if item['id']=='water-reservoir':
   row['comparisonKind']='secondary-wrong-frontier-item'
   row['editionNote']+=' Corrected selected recipe to standard reservoir: 30 Stone and 5 Cementing Paste. Secondary source is Frontier WaterTank_Large, not this standard item; discarded 500 Wood/100 Ingot/50 Paste formula.'
  elif item['id']=='tek-thalassian-hoversail':
   row['comparisonKind']='secondary-generic-hoversail-not-thalassian'
   row['editionNote']+=' Corrected material to 450 Hardened Steel Ingot. Secondary source is generic Genesis2 Tek Hoversail; no confirmed identity with the Thalassian variant.'
  else:
   row['comparisonKind']='selected-primary-chemistry-bench-batch'
   row['output']=output;row['outputStatus']='primary-batch-reference'
   row['editionNote']+=' Selected actual Chemistry Bench batch from primary page, including its output. Secondary raw class-default input is not a playable primitive recipe; no ASA availability or game verification asserted.'
 if item['id']=='bee-hive':
  row['rejectedSecondaryRecipe']={'ingredients':row['ingredients'],'stations':row['stations'],'sourceURL':row.get('recipeSourceURL'),'identity':row.get('secondaryIdentity',{})}
  row['editionNote']=row['editionNote'].replace('Recipe retained from the ASA-specific source; Wiki alternatives do not overwrite it.', 'Secondary extraction recorded for comparison; selected primary recipe uses the reviewed correction.').replace('Wiki ingredients reflect the larger Chemistry Bench input batch; retained source uses base-batch inputs.', 'Secondary raw class input costs differ from the actual Chemistry Bench batch.')
  row.update(ingredients={},stations=[],recipeSourceURL=url,recipeStatus='no-infobox-recipe',comparisonKind='secondary-default-blueprint-not-player-engram',recipeKind='acquisition')
  row['purpose']='Tame a Giant Queen Bee, then interact with it to obtain a placeable Bee Hive.';row['purposeSourceURL']=url
  row['acquisitionRequirements']={'Giant Bee':1}
  row['editionNote']+=' Hive is acquired by taming and converting a Giant Queen Bee; Wiki ingredient means that conversion. Raw secondary blueprint defaults are not a player crafting formula and are suppressed.'
 if row['recipeStatus']=='asa-cache-wiki-difference':row['editionNote']+=' Selected recipe remains an unconfirmed ASA secondary reference: primary ingredient amounts/resources differ; confirm in current-game engram before spending resources.'
 for stat in stats:stat.update(sourceURL=url,status='wiki-reference-edition-review')
 return row

def main():
 args=argparse.ArgumentParser();args.add_argument('--refresh',action='store_true');args.add_argument('--workers',type=int,default=6);opt=args.parse_args()
 CACHE.mkdir(parents=True,exist_ok=True)
 catalog=json.loads((RES/'equipment-library.json').read_text())['items'];craft=json.loads((RES/'build-crafting.json').read_text());existing={x['id']:x for x in craft['items']}
 rows=[]
 with concurrent.futures.ThreadPoolExecutor(max_workers=opt.workers) as pool:
  for i,row in enumerate(pool.map(lambda item:acquire(item,existing,opt.refresh),catalog)):
   rows.append(row)
   if i%40==0:print(i,len(catalog),dict(Counter(x['primaryPageStatus'] for x in rows)),flush=True)
 # Explicit batch output only where the existing process audit recorded it. Do not guess one.
 processes=craft['processes']
 for row in rows:
  process=next((x for x in processes if x['name']==row['name']),None)
  if process:
   row['processVariants']=[process];row['output']=process['output'];row['outputStatus']='existing-reviewed-standard-process';row['editionNote']+=' Standard process output excludes fuel and Chemistry Bench batch discounts.'
 document={'schemaVersion':1,'checkedAt':CHECKED,'scope':'728 catalogue items; primitive/base facts with explicit edition review status','items':rows,'processes':processes}
 (RES/'equipment-details.json').write_text(json.dumps(document,ensure_ascii=False,separators=(',',':'))+'\n')
 counts={'items':len(rows),'primaryPages':dict(Counter(x['primaryPageStatus'] for x in rows)),'recipes':dict(Counter(x['recipeStatus'] for x in rows)),'stats':dict(Counter(x['statsStatus'] for x in rows)),'withIngredients':sum(bool(x['ingredients']) for x in rows),'withStats':sum(bool(x['stats']) for x in rows),'statFacts':sum(len(x['stats']) for x in rows),'withExplicitOutput':sum('output' in x for x in rows),'primaryRetrievedOnAuditDate':sum(x.get('primaryRetrievedAt','').startswith(CHECKED[:10]) for x in rows)}
 audit={'checkedAt':CHECKED,'counts':counts,'acquisition':'curl GET, per-item source URLs and SHA256; web browsing independently returned 403 for Metal Pick/Hatchet','editionPolicy':'ASA-specific cached recipes take precedence; mixed Wiki facts always marked edition-review. No claim of all728 ASA game verification. No absent recipe inferred as uncraftable.','pages':[{'id':x['id'],'sourceURL':x['sourceURL'],'checkedAt':x['checkedAt'],'status':x['primaryPageStatus'],'sourceSHA256':x.get('sourceSHA256'),'primaryRetrievedAt':x.get('primaryRetrievedAt'),'recipeStatus':x['recipeStatus'],'statCount':len(x['stats']),'error':x.get('sourceError')} for x in rows]}
 report=ROOT/'docs/codex-reports';report.mkdir(parents=True,exist_ok=True)
 (report/'2026-10-07-equipment25-source-audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2)+'\n')
 (report/'2026-10-07-equipment25-source-audit.md').write_text('# Equipment 25 source acquisition\n\n'+json.dumps(counts,indent=2)+'\n\nEvery item has an audit record. Direct Wiki GETs are factual primary evidence; cached ASA Wikily recipes are secondary edition-specific evidence. Mixed Wiki infobox values retain explicit edition-review status; recipe mismatches preserve ASA values. Missing recipes are unresolved or no-infobox-recipe, never automatically labeled uncraftable. Output count is optional unless explicitly sourced. Alternative ingredient names and multi-recipe variants are retained. No Wiki article prose is packaged.\n\nSchema: `items` keyed by `id`; `ingredients` dictionary, `stations` string array, optional `output`, `stats` key/label/value/sourceURL/status objects; `recipeStatus`, `statsStatus`, `primaryPageStatus`, `checkedAt`, source hashes, and `editionNote`. `recipeVariants` retain primary ingredient candidates; `processVariants` retain reviewed processing recipes including batch outputs.\n')
 print(json.dumps(counts,indent=2),flush=True)
if __name__=='__main__':main()
