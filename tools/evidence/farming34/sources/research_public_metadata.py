import urllib.request,json,re,pathlib,concurrent.futures
P=pathlib.Path(__file__).parent
ids=['0U6X4YdAHRU','__4ZCCW0cyA','HFuh4mqiPRU','aiWzwkiW5No','WMq8x8V5CBE','bbPcUcWjWZ8','MmsMM2W8AjE','MGyKk5tHrNQ','-hGqRvxKjg4','1jxA9B4l3nw','balRyHvmX1Y','nA5ZKpH87D0','vtgZLVyfAIY','CkxQqpDhsKU','surbuXTdTEU','CVq9atQWVU4','9GhzctIGY7g','CDyfhWGI4dg','FOKRZNiQcqM','1jKvi74kCXk','hp37sof-YOE','IwAWlpqJ5kw','iGOhD975Wdo','1MOtJ_UtZaI','lldf_pYOdsw','K47KjpQUPeM','7-TpuLb1KNI','483rnalfWas','oVsTDDYddQs','iol7TfSw_lw','j0jU5sigiMA','4egH7mrg7eA','4I8kXKswPaI','EfLBgAbyUQo','3zy7ph1VL_M','Yx7qTHpA3x4','w7zX9U0-RoA','fG1npFzdrzU','XGPByd8vWmI','95w_DRId0xQ','lkJWlZJDclE','JQnEEp2IA44','TUoB8ouWPYk','YwU72bDxZog','NE4q4JEhcGQ','fHl7hHMjnUM','Ok7S7hp4Rk0','fpHQ6TUJnk4','Oxyw-jv19xQ','y_Q23dYEVNQ','YeGPkRHsOwU','NvNWqxnWrcA','c_sopE-Z27E']
def find(x,k):
 if isinstance(x,dict):
  if k in x:yield x[k]
  for v in x.values():yield from find(v,k)
 elif isinstance(x,list):
  for v in x:yield from find(v,k)
def text(x):return x.get('simpleText') or ''.join(v.get('text','') for v in x.get('runs',[]))
def run(i):
 if P.joinpath('public-metadata-'+i+'.json').exists():return
 try:
  s=urllib.request.urlopen('https://www.youtube.com/watch?v='+i,timeout=45).read().decode();x=json.loads(re.search(r'(?:var\s+)?ytInitialData\s*=\s*(\{.*?\});',s).group(1))
  main=next(find(x,'videoPrimaryInfoRenderer'),{});header=next(find(x,'videoDescriptionHeaderRenderer'),{});body=next(find(x,'expandableVideoDescriptionBodyRenderer'),{});desc=body.get('attributedDescriptionBodyText',{}).get('content') or text(body.get('descriptionBodyText',{}))
  out={'videoId':i,'url':'https://www.youtube.com/watch?v='+i,'title':text(main.get('title',{})),'channel':text(header.get('channel',{})),'publishDateText':text(header.get('publishDate',{})),'description':desc,'viewCount':next(find(main,'originalViewCount'),None),'chapters':[{'title':text(v.get('title',{})),'timeDescription':text(v.get('timeDescription',{})),'startSeconds':v.get('onTap',{}).get('watchEndpoint',{}).get('startTimeSeconds')} for v in find(x,'macroMarkersListItemRenderer')],'source':'public YouTube watch-page text metadata; media player may be gated; no media access attempted'}
  P.joinpath('public-metadata-'+i+'.json').write_text(json.dumps(out,indent=2));print(i,out['publishDateText'],len(desc),len(out['chapters']))
 except Exception as e:print(i,type(e).__name__)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as p:list(p.map(run,ids))
