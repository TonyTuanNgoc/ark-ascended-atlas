import pathlib,json,re
P=pathlib.Path(__file__).parent
prior=set(json.loads((P/'prior-video-ids.json').read_text()));search={}
for f in P.glob('*search.ndjson'):
 for l in f.read_text().splitlines():
  x=json.loads(l);search[x['id']]=x
mapids={'Astraeos':['balRyHvmX1Y','nA5ZKpH87D0','vtgZLVyfAIY','surbuXTdTEU','9GhzctIGY7g','CVq9atQWVU4','K47KjpQUPeM','7-TpuLb1KNI','483rnalfWas','oVsTDDYddQs','j0jU5sigiMA','4egH7mrg7eA','EfLBgAbyUQo','3zy7ph1VL_M','Yx7qTHpA3x4','w7zX9U0-RoA','XGPByd8vWmI','y_Q23dYEVNQ'],'Valguero':['bbPcUcWjWZ8','MmsMM2W8AjE','lldf_pYOdsw','95w_DRId0xQ','lkJWlZJDclE','JQnEEp2IA44'],'Aberration':['4I8kXKswPaI','TUoB8ouWPYk','YwU72bDxZog','fHl7hHMjnUM','YeGPkRHsOwU','NvNWqxnWrcA','c_sopE-Z27E'],'Extinction':['0U6X4YdAHRU','aiWzwkiW5No','HFuh4mqiPRU','WMq8x8V5CBE','iGOhD975Wdo','1MOtJ_UtZaI','iol7TfSw_lw','NE4q4JEhcGQ'],'LostColony':['-hGqRvxKjg4','1jxA9B4l3nw','fG1npFzdrzU','Ok7S7hp4Rk0','fpHQ6TUJnk4','Oxyw-jv19xQ']}
res={'BlackPearls':['black pearl','blackpearl'],'CementingPaste':['cementing paste'],'Chitin':['chitin'],'Crystal':['crystal'],'GiantBeeHoney':['honey','bees'],'Metal':['metal'],'Obsidian':['obsidian'],'Oil':['oil'],'OrganicPolymer':['organic polymer','organic polymere'],'RareFlowers':['rare flower'],'RareMushrooms':['rare mushroom'],'RichMetal':['rich metal'],'Sap':['sap'],'SilicaPearls':['silica pearl','silicia pearl','silicia pearls','pearls/blackpearls']}
queue=[]
for map,ids in mapids.items():
 for i in ids:
  x=json.loads((P/('public-metadata-'+i+'.json')).read_text());flat=search[i];x['map']=map;x['duration']=flat.get('duration');x['views']=int(x['viewCount']) if x['viewCount'] else flat.get('view_count');x.pop('viewCount',None);m=re.search(r'(\d+) thg (\d+), (\d+)',x['publishDateText']);x['publishedDate']=f'{m[3]}-{int(m[2]):02}-{int(m[1]):02}' if m else None;x['freshAgainstPriorLedgers']=i not in prior;x['edition']='ARK Survival Ascended explicitly named in source title or description';x['gpsInCreatorDescription']=[{'latitude':float(m[1]),'longitude':float(m[2]),'line':line} for line in x['description'].splitlines() for m in [re.search(r'Lat\s+(\d+(?:\.\d+)?)\s+Lon\s+(\d+(?:\.\d+)?)',line,re.I)] if m]
  seen=set();cs=[]
  for c in x['chapters']:
   key=(c['title'],c['startSeconds'])
   if key in seen:continue
   seen.add(key);c['provenance']='creator-description timestamp' if c['timeDescription'] in x['description'] or (c['startSeconds'] is not None and str(int(c['startSeconds'])//60)+':'+str(int(c['startSeconds'])%60).zfill(2) in x['description']) else 'YouTube chapter metadata; may be auto-generated'
   c['candidateResources']=[r for r,terms in res.items() if any(t in c['title'].lower() for t in terms)];cs.append(c)
  cs.sort(key=lambda c:c['startSeconds'] or 0)
  for n,c in enumerate(cs):c['endSeconds']=cs[n+1]['startSeconds'] if n+1<len(cs) else x['duration']
  x['chapters']=cs;x['resourceMentions']=[r for r,terms in res.items() if any(t in (x['title']+' '+x['description']).lower() for t in terms)];x['priority']=1 if x['duration']<350 else 2;x['revisionCaution']='Astraeos launch/Pyranthos updates can relocate or add nodes; compare filmed region against current map before import' if map=='Astraeos' and x['publishedDate']<'2026-01-01' else None;x['proofStatus']='metadata-only; no visual/GPS farm region verified';queue.append(x)
for x in queue:
 if x['videoId']=='iol7TfSw_lw':x['substituteWarning']='Silicate substitute; do not label natural SilicaPearls nodes.'
 if x['videoId']=='0U6X4YdAHRU':x['edition']='Published after ASA Extinction launch, but title/description lacks explicit ASA identification; visual proof required';x['priority']=3
 if x['videoId']=='483rnalfWas':x['revisionCaution']='Preofficial October2024 Astraeos mod revision; current ASA coordinate correspondence required';x['priority']=4
 if x['videoId'] in ['balRyHvmX1Y','nA5ZKpH87D0']:x['priority']=3;x['role']='PostAug27 latest-map orientation; resource farm proof not established'
queue.sort(key=lambda x:(x['priority'],x['duration']))
(P/'prioritized-fresh-source-queue.json').write_text(json.dumps({'schema':'farming34-source-research-v1','priorExcludedCount':len(prior),'sources':queue,'note':'Metadata is a candidate queue only. Creature drops, silicate/corrupted-nodule substitutes, RichMetal node classification require explicit visual verification. No absence inference.'},indent=2))
print('Fresh curated sources',len(queue),'chapters',sum(len(x['chapters']) for x in queue))
